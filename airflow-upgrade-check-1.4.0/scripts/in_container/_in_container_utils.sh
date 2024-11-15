#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#######################################################################################################
#
# Adds trap to the traps already set.
#
# Arguments:
#      trap to set
#      .... list of signals to handle
#######################################################################################################
function add_trap() {
    trap="${1}"
    shift
    for signal in "${@}"; do
        # adding trap to exiting trap
        local handlers
        handlers="$(trap -p "${signal}" | cut -f2 -d \')"
        # shellcheck disable=SC2064
        trap "${trap};${handlers}" "${signal}"
    done
}

function assert_in_container() {
    export VERBOSE=${VERBOSE:="false"}
    if [[ ! -f /.dockerenv ]]; then
        echo
        echo "${COLOR_RED_ERROR} You are not inside the Airflow docker container!  ${COLOR_RESET}"
        echo
        echo "You should only run this script in the Airflow docker container as it may override your files."
        echo "Learn more about how we develop and test airflow in:"
        echo "https://github.com/apache/airflow/blob/master/CONTRIBUTING.rst"
        echo
        exit 1
    fi
}

function in_container_script_start() {
    OUTPUT_PRINTED_ONLY_ON_ERROR=$(mktemp)
    export OUTPUT_PRINTED_ONLY_ON_ERROR
    readonly OUTPUT_PRINTED_ONLY_ON_ERROR

    if [[ ${VERBOSE=} == "true" ]]; then
        echo
        echo "Output is redirected to ${OUTPUT_PRINTED_ONLY_ON_ERROR} and will be printed on error only"
        echo
    fi

    if [[ ${VERBOSE_COMMANDS:="false"} == "true" ]]; then
        set -x
    fi
}

function in_container_script_end() {
    #shellcheck disable=2181
    EXIT_CODE=$?
    if [[ ${EXIT_CODE} != 0 ]]; then
        if [[ "${PRINT_INFO_FROM_SCRIPTS="true"}" == "true" ]]; then
            if [[ -f "${OUTPUT_PRINTED_ONLY_ON_ERROR}" ]]; then
                echo "###########################################################################################"
                echo
                echo "${COLOR_BLUE} EXIT CODE: ${EXIT_CODE} in container (See above for error message). Below is the output of the last action! ${COLOR_RESET}"
                echo
                echo "${COLOR_BLUE}***  BEGINNING OF THE LAST COMMAND OUTPUT *** ${COLOR_RESET}"
                cat "${OUTPUT_PRINTED_ONLY_ON_ERROR}"
                echo "${COLOR_BLUE}***  END OF THE LAST COMMAND OUTPUT ***  ${COLOR_RESET}"
                echo
                echo "${COLOR_BLUE} EXIT CODE: ${EXIT_CODE} in container. The actual error might be above the output!  ${COLOR_RESET}"
                echo
                echo "###########################################################################################"
            else
                echo "########################################################################################################################"
                echo "${COLOR_BLUE} [IN CONTAINER]   EXITING ${0} WITH EXIT CODE ${EXIT_CODE}  ${COLOR_RESET}"
                echo "########################################################################################################################"
            fi
        fi
    fi

    if [[ ${VERBOSE_COMMANDS} == "true" ]]; then
        set +x
    fi
}

#
# Cleans up PYC files (in case they come in mounted folders)
#
function in_container_cleanup_pyc() {
    set +o pipefail
    sudo find . \
        -path "./airflow/www/node_modules" -prune -o \
        -path "./airflow/www_rbac/node_modules" -prune -o \
        -path "./.eggs" -prune -o \
        -path "./docs/_build" -prune -o \
        -path "./build" -prune -o \
        -name "*.pyc" | grep ".pyc$" | sudo xargs rm -f
    set -o pipefail
}

#
# Cleans up __pycache__ directories (in case they come in mounted folders)
#
function in_container_cleanup_pycache() {
    set +o pipefail
    find . \
        -path "./airflow/www/node_modules" -prune -o \
        -path "./airflow/www_rbac/node_modules" -prune -o \
        -path "./.eggs" -prune -o \
        -path "./docs/_build" -prune -o \
        -path "./build" -prune -o \
        -name "__pycache__" | grep "__pycache__" | sudo xargs rm -rf
    set -o pipefail
}

#
# Fixes ownership of files generated in container - if they are owned by root, they will be owned by
# The host user. Only needed if the host is Linux - on Mac, ownership of files is automatically
# changed to the Host user via osxfs filesystem
#
function in_container_fix_ownership() {
    if [[ ${HOST_OS:=} == "Linux" ]]; then
        DIRECTORIES_TO_FIX=(
            "/tmp"
            "/files"
            "/root/.aws"
            "/root/.azure"
            "/root/.config/gcloud"
            "/root/.docker"
            "${AIRFLOW_SOURCES}"
        )
        if [[ ${VERBOSE} == "true" ]]; then
            echo "Fixing ownership of mounted files"
        fi
        sudo find "${DIRECTORIES_TO_FIX[@]}" -print0 -user root 2>/dev/null |
            sudo xargs --null chown "${HOST_USER_ID}.${HOST_GROUP_ID}" --no-dereference ||
            true >/dev/null 2>&1
        if [[ ${VERBOSE} == "true" ]]; then
            echo "Fixed ownership of mounted files"
        fi
    fi
}

function in_container_clear_tmp() {
    if [[ ${VERBOSE} == "true" ]]; then
        echo "Cleaning ${AIRFLOW_SOURCES}/tmp from the container"
    fi
    rm -rf /tmp/*
    if [[ ${VERBOSE} == "true" ]]; then
        echo "Cleaned ${AIRFLOW_SOURCES}/tmp from the container"
    fi
}

function in_container_go_to_airflow_sources() {
    pushd "${AIRFLOW_SOURCES}" &>/dev/null || exit 1
}

function in_container_basic_sanity_check() {
    assert_in_container
    in_container_go_to_airflow_sources
    in_container_cleanup_pyc
    in_container_cleanup_pycache
}

export DISABLE_CHECKS_FOR_TESTS="missing-docstring,no-self-use,too-many-public-methods,protected-access,do-not-use-asserts"

function start_output_heartbeat() {
    MESSAGE=${1:-"Still working!"}
    INTERVAL=${2:=10}
    echo
    echo "Starting output heartbeat"
    echo

    bash 2>/dev/null <<EOF &
while true; do
  echo "\$(date): ${MESSAGE} "
  sleep ${INTERVAL}
done
EOF
    export HEARTBEAT_PID=$!
}

function stop_output_heartbeat() {
    kill "${HEARTBEAT_PID}" || true
    wait "${HEARTBEAT_PID}" || true 2>/dev/null
}

function setup_kerberos() {
    FQDN=$(hostname)
    ADMIN="admin"
    PASS="airflow"
    KRB5_KTNAME=/etc/airflow.keytab

    sudo cp "${AIRFLOW_SOURCES}/scripts/in_container/krb5/krb5.conf" /etc/krb5.conf

    echo -e "${PASS}\n${PASS}" | \
        sudo kadmin -p "${ADMIN}/admin" -w "${PASS}" -q "addprinc -randkey airflow/${FQDN}" 2>&1 \
          | sudo tee "${AIRFLOW_HOME}/logs/kadmin_1.log" >/dev/null
    RES_1=$?

    sudo kadmin -p "${ADMIN}/admin" -w "${PASS}" -q "ktadd -k ${KRB5_KTNAME} airflow" 2>&1 \
          | sudo tee "${AIRFLOW_HOME}/logs/kadmin_2.log" >/dev/null
    RES_2=$?

    sudo kadmin -p "${ADMIN}/admin" -w "${PASS}" -q "ktadd -k ${KRB5_KTNAME} airflow/${FQDN}" 2>&1 \
          | sudo tee "${AIRFLOW_HOME}/logs``/kadmin_3.log" >/dev/null
    RES_3=$?

    if [[ ${RES_1} != 0 || ${RES_2} != 0 || ${RES_3} != 0 ]]; then
        echo
        echo "Error when setting up Kerberos: ${RES_1} ${RES_2} ${RES_3}}!"
        echo
        exit 1
    else
        echo
        echo "Kerberos enabled and working."
        echo
        sudo chmod 0644 "${KRB5_KTNAME}"
    fi
}

function dump_airflow_logs() {
    local dump_file
    dump_file=/files/airflow_logs_$(date "+%Y-%m-%d")_${CI_BUILD_ID}_${CI_JOB_ID}.log.tar.gz
    echo "###########################################################################################"
    echo "                   Dumping logs from all the airflow tasks"
    echo "###########################################################################################"
    pushd "${AIRFLOW_HOME}" || exit 1
    tar -czf "${dump_file}" logs
    echo "                   Logs dumped to ${dump_file}"
    popd || exit 1
    echo "###########################################################################################"
}

function install_airflow_from_wheel() {
    local extras
    extras="${1}"
    local airflow_package
    airflow_package=$(find /dist/ -maxdepth 1 -type f -name 'apache_airflow-[0-9]*.whl')
    echo
    echo "Found package: ${airflow_package}. Installing."
    echo
    if [[ -z "${airflow_package}" ]]; then
        >&2 echo
        >&2 echo "ERROR! Could not find airflow wheel package to install in dist"
        >&2 echo
        exit 4
    fi
    pip install "${airflow_package}${1}" >"${OUTPUT_PRINTED_ONLY_ON_ERROR}" 2>&1
}

function install_airflow_from_sdist() {
    local extras
    extras="${1}"
    local airflow_package
    airflow_package=$(find /dist/ -maxdepth 1 -type f -name 'apache-airflow-[0-9]*.tar.gz')
    echo
    echo "Found package: ${airflow_package}. Installing."
    echo
    if [[ -z "${airflow_package}" ]]; then
        >&2 echo
        >&2 echo "ERROR! Could not find airflow sdist package to install in dist"
        >&2 echo
        exit 4
    fi
    pip install "${airflow_package}${1}" >"${OUTPUT_PRINTED_ONLY_ON_ERROR}" 2>&1
}

function install_remaining_dependencies() {
    pip install apache-beam[gcp] >"${OUTPUT_PRINTED_ONLY_ON_ERROR}" 2>&1
}

function uninstall_airflow() {
    echo
    echo "Uninstalling airflow"
    echo
    pip uninstall -y apache-airflow || true
    echo
    echo "Remove all AIRFLOW_HOME remnants"
    echo
    find /root/airflow/ -type f -print0 | xargs -0 rm -f --
}

function install_released_airflow_version() {
    local version="${1}"
    local extras="${2}"
    echo
    echo "Installing released ${version} version of airflow with extras ${extras}"
    echo

    rm -rf "${AIRFLOW_SOURCES}"/*.egg-info
    pip install --upgrade "apache-airflow${extras}==${version}" >"${OUTPUT_PRINTED_ONLY_ON_ERROR}" 2>&1
}

function install_all_provider_packages_from_wheels() {
    echo
    echo "Installing all provider packages from wheels"
    echo
    pip install /dist/apache_airflow*providers_*.whl >"${OUTPUT_PRINTED_ONLY_ON_ERROR}" 2>&1
}

function install_all_provider_packages_from_tar_gz_files() {
    echo
    echo "Installing all provider packages from .tar.gz"
    echo
    pip install /dist/apache-airflow-*providers-*.tar.gz >"${OUTPUT_PRINTED_ONLY_ON_ERROR}" 2>&1
}


function verify_suffix_versions_for_package_preparation() {
    TARGET_VERSION_SUFFIX=""
    FILE_VERSION_SUFFIX=""

    VERSION_SUFFIX_FOR_PYPI=${VERSION_SUFFIX_FOR_PYPI:=""}
    readonly VERSION_SUFFIX_FOR_PYPI

    VERSION_SUFFIX_FOR_SVN=${VERSION_SUFFIX_FOR_SVN:=""}

    if [[ ${VERSION_SUFFIX_FOR_PYPI} != "" ]]; then
        echo
        echo "Version suffix for PyPI = ${VERSION_SUFFIX_FOR_PYPI}"
        echo
    fi
    if [[ ${VERSION_SUFFIX_FOR_SVN} != "" ]]; then
        echo
        echo "Version suffix for SVN  = ${VERSION_SUFFIX_FOR_SVN}"
        echo
    fi

    if [[ ${VERSION_SUFFIX_FOR_SVN} =~ ^rc ]]; then
        echo """
${COLOR_YELLOW_WARNING} The version suffix for SVN is used only for file names.
         The version inside the packages has no version suffix.
         This way we can just rename files when they graduate to final release.
${COLOR_RESET}
"""
        echo
        echo "This suffix is added '${VERSION_SUFFIX_FOR_SVN}' "
        echo
        FILE_VERSION_SUFFIX=${VERSION_SUFFIX_FOR_SVN}
        VERSION_SUFFIX_FOR_SVN=""
    fi
    readonly FILE_VERSION_SUFFIX
    readonly VERSION_SUFFIX_FOR_SVN

    export FILE_VERSION_SUFFIX
    export VERSION_SUFFIX_FOR_SVN
    export VERSION_SUFFIX_FOR_PYPI

    if [[ ${VERSION_SUFFIX_FOR_PYPI} != '' && ${VERSION_SUFFIX_FOR_SVN} != '' ]]; then
        if [[ ${VERSION_SUFFIX_FOR_PYPI} != "${VERSION_SUFFIX_FOR_SVN}" ]]; then
            echo
            echo "${COLOR_RED_ERROR} If you specify both PyPI and SVN version suffixes they must match  ${COLOR_RESET}"
            echo
            echo "However they are different: PyPI:'${VERSION_SUFFIX_FOR_PYPI}' vs. SVN:'${VERSION_SUFFIX_FOR_SVN}'"
            echo
            exit 1
        else
            if [[ ${VERSION_SUFFIX_FOR_PYPI} =~ ^rc ]]; then
                echo
                echo "${COLOR_RED_ERROR} If you prepare an RC candidate, you need to specify only PyPI suffix  ${COLOR_RESET}"
                echo
                echo "However you specified both: PyPI'${VERSION_SUFFIX_FOR_PYPI}' and SVN '${VERSION_SUFFIX_FOR_SVN}'"
                echo
                exit 2
            fi
            # Just use one of them - they are both the same:
            TARGET_VERSION_SUFFIX=${VERSION_SUFFIX_FOR_PYPI}
        fi
    else
        if [[ ${VERSION_SUFFIX_FOR_PYPI} == '' && ${VERSION_SUFFIX_FOR_SVN} == '' ]]; then
            # Preparing "official version"
            TARGET_VERSION_SUFFIX=""
        else

            if [[ ${VERSION_SUFFIX_FOR_PYPI} == '' ]]; then
                echo
                echo "${COLOR_RED_ERROR} You should never specify version for PyPI only.  ${COLOR_RESET}"
                echo
                echo "You specified PyPI suffix: '${VERSION_SUFFIX_FOR_PYPI}'"
                echo
                exit 3
            fi
            TARGET_VERSION_SUFFIX=${VERSION_SUFFIX_FOR_PYPI}${VERSION_SUFFIX_FOR_SVN}
            if [[ ! ${TARGET_VERSION_SUFFIX} =~ rc.* ]]; then
                echo
                echo "${COLOR_RED_ERROR} If you prepare an alpha/beta release, you need to specify both PyPI/SVN suffixes and they have to match.  ${COLOR_RESET}"
                echo
                echo "And they have to match. You specified only one suffix:  ${TARGET_VERSION_SUFFIX}."
                echo
                exit 4
            fi
        fi
    fi
    readonly TARGET_VERSION_SUFFIX
    export TARGET_VERSION_SUFFIX
}

function filename_to_python_module() {
    # Turn the file name into a python package name
    file="$1"
    no_leading_dotslash="${file#./}"
    no_py="${no_leading_dotslash/.py/}"
    no_init="${no_py/\/__init__/}"
    echo "${no_init//\//.}"
}

function import_all_provider_classes() {
    echo
    echo Importing all Airflow classes
    echo

    # We have to move to a directory where "airflow" is
    unset PYTHONPATH
    # We need to make sure we are not in the airflow checkout, otherwise it will automatically be added to the
    # import path
    cd /

    declare -a IMPORT_CLASS_PARAMETERS

    PROVIDER_PATHS=$(
        python3 <<EOF 2>/dev/null
import airflow.providers;
path=airflow.providers.__path__
for p in path._path:
    print(p)
EOF
    )
    export PROVIDER_PATHS

    echo "Searching for providers packages in:"
    echo "${PROVIDER_PATHS}"

    while read -r provider_path; do
        IMPORT_CLASS_PARAMETERS+=("--path" "${provider_path}")
    done < <(echo "${PROVIDER_PATHS}")

    python3 /opt/airflow/dev/import_all_classes.py "${IMPORT_CLASS_PARAMETERS[@]}"
}

function in_container_set_colors() {
    COLOR_BLUE=$'\e[34m'
    COLOR_GREEN=$'\e[32m'
    COLOR_GREEN_OK=$'\e[32mOK.'
    COLOR_RED=$'\e[31m'
    COLOR_RED_ERROR=$'\e[31mERROR:'
    COLOR_RESET=$'\e[0m'
    COLOR_YELLOW=$'\e[33m'
    COLOR_YELLOW_WARNING=$'\e[33mWARNING:'
    export COLOR_BLUE
    export COLOR_GREEN
    export COLOR_GREEN_OK
    export COLOR_RED
    export COLOR_RED_ERROR
    export COLOR_RESET
    export COLOR_YELLOW
    export COLOR_YELLOW_WARNING
}

export CI=${CI:="false"}
export GITHUB_ACTIONS=${GITHUB_ACTIONS:="false"}
