<!--
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
-->
# Updating Airflow

This file documents any backwards-incompatible changes in Airflow and
assists users migrating to a new version.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of contents**

- [Airflow 1.10.15](#airflow-11015)
- [Airflow 1.10.14](#airflow-11014)
- [Airflow 1.10.13](#airflow-11013)
- [Airflow 1.10.12](#airflow-11012)
- [Airflow 1.10.11](#airflow-11011)
- [Airflow 1.10.10](#airflow-11010)
- [Airflow 1.10.9](#airflow-1109)
- [Airflow 1.10.8](#airflow-1108)
- [Airflow 1.10.7](#airflow-1107)
- [Airflow 1.10.6](#airflow-1106)
- [Airflow 1.10.5](#airflow-1105)
- [Airflow 1.10.4](#airflow-1104)
- [Airflow 1.10.3](#airflow-1103)
- [Airflow 1.10.2](#airflow-1102)
- [Airflow 1.10.1](#airflow-1101)
- [Airflow 1.10](#airflow-110)
- [Airflow 1.9](#airflow-19)
- [Airflow 1.8.1](#airflow-181)
- [Airflow 1.8](#airflow-18)
- [Airflow 1.7.1.2](#airflow-1712)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!--

I'm glad you want to write a new note. Remember that this note is intended for users.
Make sure it contains the following information:

- [ ] Previous behaviors
- [ ] New behaviors
- [ ] If possible, a simple example of how to migrate. This may include a simple code example.
- [ ] If possible, the benefit for the user after migration e.g. "we want to make these changes to unify class names."
- [ ] If possible, the reason for the change, which adds more context to that interested, e.g. reference for Airflow Improvement Proposal.

More tips can be found in the guide:
https://developers.google.com/style/inclusive-documentation

-->

## Airflow 1.10.15

No breaking changes.

## Airflow 1.10.14

### `[scheduler] max_threads` config has been renamed to `[scheduler] parsing_processes`

From Airflow 1.10.14, `max_threads` config under `[scheduler]` section has been renamed to `parsing_processes`.

This is to align the name with the actual code where the Scheduler launches the number of processes defined by
`[scheduler] parsing_processes` to parse the DAG files.

### Airflow CLI changes in line with  2.0

The Airflow CLI has been organized so that related commands are grouped together as subcommands,
which means that if you use these commands in your scripts, you have to make changes to them.

This section describes the changes that have been made, and what you need to do to update your script.

The ability to manipulate users from the command line has been changed. ``airflow create_user``,  ``airflow delete_user``
 and ``airflow list_users`` has been grouped to a single command `airflow users` with optional flags `create`, `list` and `delete`.

The `airflow list_dags` command is now `airflow dags list`, `airflow pause` is `airflow dags pause`, etc.

In Airflow 1.10 and 2.0 there is an `airflow config` command but there is a difference in behavior. In Airflow 1.10,
it prints all config options while in Airflow 2.0, it's a command group. `airflow config` is now `airflow config list`.
You can check other options by running the command `airflow config --help`

Compatibility with the old CLI has been maintained, but they will no longer appear in the help

You can learn about the commands by running ``airflow --help``. For example to get help about the ``celery`` group command,
you have to run the help command: ``airflow celery --help``.

| Old command                   | New command                        |     Group          |
|-------------------------------|------------------------------------|--------------------|
| ``airflow worker``            | ``airflow celery worker``          |    ``celery``      |
| ``airflow flower``            | ``airflow celery flower``          |    ``celery``      |
| ``airflow trigger_dag``       | ``airflow dags trigger``           |    ``dags``        |
| ``airflow delete_dag``        | ``airflow dags delete``            |    ``dags``        |
| ``airflow show_dag``          | ``airflow dags show``              |    ``dags``        |
| ``airflow list_dag``          | ``airflow dags list``              |    ``dags``        |
| ``airflow dag_status``        | ``airflow dags status``            |    ``dags``        |
| ``airflow backfill``          | ``airflow dags backfill``          |    ``dags``        |
| ``airflow list_dag_runs``     | ``airflow dags list-runs``         |    ``dags``        |
| ``airflow pause``             | ``airflow dags pause``             |    ``dags``        |
| ``airflow unpause``           | ``airflow dags unpause``           |    ``dags``        |
| ``airflow next_execution``    | ``airflow dags next-execution``    |    ``dags``        |
| ``airflow test``              | ``airflow tasks test``             |    ``tasks``       |
| ``airflow clear``             | ``airflow tasks clear``            |    ``tasks``       |
| ``airflow list_tasks``        | ``airflow tasks list``             |    ``tasks``       |
| ``airflow task_failed_deps``  | ``airflow tasks failed-deps``      |    ``tasks``       |
| ``airflow task_state``        | ``airflow tasks state``            |    ``tasks``       |
| ``airflow run``               | ``airflow tasks run``              |    ``tasks``       |
| ``airflow render``            | ``airflow tasks render``           |    ``tasks``       |
| ``airflow initdb``            | ``airflow db init``                |     ``db``         |
| ``airflow resetdb``           | ``airflow db reset``               |     ``db``         |
| ``airflow upgradedb``         | ``airflow db upgrade``             |     ``db``         |
| ``airflow checkdb``           | ``airflow db check``               |     ``db``         |
| ``airflow shell``             | ``airflow db shell``               |     ``db``         |
| ``airflow pool``              | ``airflow pools``                  |     ``pools``      |
| ``airflow create_user``       | ``airflow users create``           |     ``users``      |
| ``airflow delete_user``       | ``airflow users delete``           |     ``users``      |
| ``airflow list_users``        | ``airflow users list``             |     ``users``      |
| ``airflow rotate_fernet_key`` | ``airflow rotate-fernet-key``      |                    |
| ``airflow sync_perm``         | ``airflow sync-perm``              |                    |

## Airflow 1.10.13

### TimeSensor is now timezone aware

Previously `TimeSensor` always compared the `target_time` with the current time in UTC.

Now it will compare `target_time` with the current time in the timezone of the DAG,
defaulting to the `default_timezone` in the global config.

### Removed Kerberos support for HDFS hook

The HDFS hook's Kerberos support has been removed due to removed python-krbV dependency from PyPI
and generally lack of support for SSL in Python3 (Snakebite-py3 we use as dependency has no
support for SSL connection to HDFS).

SSL support still works for WebHDFS hook.

### Unify user session lifetime configuration

In previous version of Airflow user session lifetime could be configured by
`session_lifetime_days` and `force_log_out_after` options. In practise only `session_lifetime_days`
had impact on session lifetime, but it was limited to values in day.
We have removed mentioned options and introduced new `session_lifetime_minutes`
option which simplify session lifetime configuration.

Before

 ```ini
[webserver]
force_log_out_after = 0
session_lifetime_days = 30
 ```

After

 ```ini
[webserver]
session_lifetime_minutes = 43200
 ```

### Adding Operators, Hooks and Sensors via Airflow Plugins is deprecated

The ability to import Operators, Hooks and Senors via the plugin mechanism has been deprecated and will raise warnings
in Airflow 1.10.13 and will be removed completely in Airflow 2.0.

Check http://airflow.apache.org/docs/1.10.13/howto/custom-operator.html to see how you can create and import
Custom Hooks, Operators and Sensors.

## Airflow 1.10.12

### Clearing tasks skipped by SkipMixin will skip them

Previously, when tasks skipped by SkipMixin (such as BranchPythonOperator, BaseBranchOperator and ShortCircuitOperator) are cleared, they execute. Since 1.10.12, when such skipped tasks are cleared,
they will be skipped again by the newly introduced NotPreviouslySkippedDep.

### The pod_mutation_hook function will now accept a kubernetes V1Pod object

As of airflow 1.10.12, using the `airflow.contrib.kubernetes.Pod` class in the `pod_mutation_hook` is now deprecated. Instead we recommend that users
treat the `pod` parameter as a `kubernetes.client.models.V1Pod` object. This means that users now have access to the full Kubernetes API
when modifying airflow pods

### pod_template_file option now available in the KubernetesPodOperator

Users can now offer a path to a yaml for the KubernetesPodOperator using the `pod_template_file` parameter.

## Airflow 1.10.11

### Use NULL as default value for dag.description

Now use NULL as default value for dag.description in dag table

### Restrict editing DagRun State in the old UI (Flask-admin based UI)

Before 1.10.11 it was possible to edit DagRun State in the `/admin/dagrun/` page
 to any text.

In Airflow 1.10.11+, the user can only choose the states from the list.

### Experimental API will deny all request by default.

The previous default setting was to allow all API requests without authentication, but this poses security
risks to users who miss this fact. This changes the default for new installs to deny all requests by default.

**Note**: This will not change the behavior for existing installs, please update check your airflow.cfg

If you wish to have the experimental API work, and aware of the risks of enabling this without authentication
(or if you have your own authentication layer in front of Airflow) you can get
the previous behaviour on a new install by setting this in your airflow.cfg:

```
[api]
auth_backend = airflow.api.auth.backend.default
```

### XCom Values can no longer be added or changed from the Webserver

Since XCom values can contain pickled data, we would no longer allow adding or
changing XCom values from the UI.

### Default for `run_as_user` configured has been changed to 50000 from 0

The UID to run the first process of the Worker PODs when using has been changed to `50000`
from the previous default of `0`. The previous default was an empty string but the code used `0` if it was
empty string.

**Before**:

```ini
[kubernetes]
run_as_user =
```

**After**:

```ini
[kubernetes]
run_as_user = 50000
```

This is done to avoid running the container as `root` user.

## Airflow 1.10.10

### Setting Empty string to a Airflow Variable will return an empty string

Previously when you set an Airflow Variable with an empty string (`''`), the value you used to get
back was ``None``. This will now return an empty string (`'''`)

Example:

```python
>> Variable.set('test_key', '')
>> Variable.get('test_key')
```

The above code returned `None` previously, now it will return `''`.

### Make behavior of `none_failed` trigger rule consistent with documentation
The behavior of the `none_failed` trigger rule is documented as "all parents have not failed (`failed` or
    `upstream_failed`) i.e. all parents have succeeded or been skipped." As previously implemented, the actual behavior
    would skip if all parents of a task had also skipped.

### Add new trigger rule `none_failed_or_skipped`
The fix to `none_failed` trigger rule breaks workflows that depend on the previous behavior.
    If you need the old behavior, you should change the tasks with `none_failed` trigger rule to `none_failed_or_skipped`.

### Success Callback will be called when a task in marked as success from UI

When a task is marked as success by a user from Airflow UI - `on_success_callback` will be called

## Airflow 1.10.9

No breaking changes.

## Airflow 1.10.8

### Failure callback will be called when task is marked failed
When task is marked failed by user or task fails due to system failures - on failure call back will be called as part of clean up

See [AIRFLOW-5621](https://jira.apache.org/jira/browse/AIRFLOW-5621) for details

## Airflow 1.10.7

### Changes in experimental API execution_date microseconds replacement

The default behavior was to strip the microseconds (and milliseconds, etc) off of all dag runs triggered by
by the experimental REST API.  The default behavior will change when an explicit execution_date is
passed in the request body.  It will also now be possible to have the execution_date generated, but
keep the microseconds by sending `replace_microseconds=false` in the request body.  The default
behavior can be overridden by sending `replace_microseconds=true` along with an explicit execution_date

### Infinite pool size and pool size query optimisation

Pool size can now be set to -1 to indicate infinite size (it also includes
optimisation of pool query which lead to poor task n^2 performance of task
pool queries in MySQL).

### Viewer won't have edit permissions on DAG view.

### Google Cloud Storage Hook

The `GoogleCloudStorageDownloadOperator` can either write to a supplied `filename` or
return the content of a file via xcom through `store_to_xcom_key` - both options are mutually exclusive.

## Airflow 1.10.6

### BaseOperator::render_template function signature changed

Previous versions of the `BaseOperator::render_template` function required an `attr` argument as the first
positional argument, along with `content` and `context`. This function signature was changed in 1.10.6 and
the `attr` argument is no longer required (or accepted).

In order to use this function in subclasses of the `BaseOperator`, the `attr` argument must be removed:
```python
result = self.render_template('myattr', self.myattr, context)  # Pre-1.10.6 call
...
result = self.render_template(self.myattr, context)  # Post-1.10.6 call
```

### Changes to `aws_default` Connection's default region

The region of Airflow's default connection to AWS (`aws_default`) was previously
set to `us-east-1` during installation.

The region now needs to be set manually, either in the connection screens in
Airflow, via the `~/.aws` config files, or via the `AWS_DEFAULT_REGION` environment
variable.

### Some DAG Processing metrics have been renamed

The following metrics are deprecated and won't be emitted in Airflow 2.0:

- `scheduler.dagbag.errors` and `dagbag_import_errors` -- use `dag_processing.import_errors` instead
- `dag_file_processor_timeouts` -- use `dag_processing.processor_timeouts` instead
- `collect_dags` -- use `dag_processing.total_parse_time` instead
- `dag.loading-duration.<basename>` -- use `dag_processing.last_duration.<basename>` instead
- `dag_processing.last_runtime.<basename>` -- use `dag_processing.last_duration.<basename>` instead

## Airflow 1.10.5

No breaking changes.

## Airflow 1.10.4

### Export MySQL timestamps as UTC

`MySqlToGoogleCloudStorageOperator` now exports TIMESTAMP columns as UTC
by default, rather than using the default timezone of the MySQL server.
This is the correct behavior for use with BigQuery, since BigQuery
assumes that TIMESTAMP columns without time zones are in UTC. To
preserve the previous behavior, set `ensure_utc` to `False.`

### Changes to DatastoreHook

* removed argument `version` from `get_conn` function and added it to the hook's `__init__` function instead and renamed it to `api_version`
* renamed the `partialKeys` argument of function `allocate_ids` to `partial_keys`

### Changes to GoogleCloudStorageHook

* the discovery-based api (`googleapiclient.discovery`) used in `GoogleCloudStorageHook` is now replaced by the recommended client based api (`google-cloud-storage`). To know the difference between both the libraries, read https://cloud.google.com/apis/docs/client-libraries-explained. PR: [#5054](https://github.com/apache/airflow/pull/5054)
* as a part of this replacement, the `multipart` & `num_retries` parameters for `GoogleCloudStorageHook.upload` method have been deprecated.

  The client library uses multipart upload automatically if the object/blob size is more than 8 MB - [source code](https://github.com/googleapis/google-cloud-python/blob/11c543ce7dd1d804688163bc7895cf592feb445f/storage/google/cloud/storage/blob.py#L989-L997). The client also handles retries automatically

* the `generation` parameter is deprecated in `GoogleCloudStorageHook.delete` and `GoogleCloudStorageHook.insert_object_acl`.

Updating to `google-cloud-storage >= 1.16` changes the signature of the upstream `client.get_bucket()` method from `get_bucket(bucket_name: str)` to `get_bucket(bucket_or_name: Union[str, Bucket])`. This method is not directly exposed by the airflow hook, but any code accessing the connection directly (`GoogleCloudStorageHook().get_conn().get_bucket(...)` or similar) will need to be updated.

### Changes in writing Logs to Elasticsearch

The `elasticsearch_` prefix has been removed from all config items under the `[elasticsearch]` section. For example `elasticsearch_host` is now just `host`.

### Removal of `non_pooled_task_slot_count` and `non_pooled_backfill_task_slot_count`

`non_pooled_task_slot_count` and `non_pooled_backfill_task_slot_count`
are removed in favor of a real pool, e.g. `default_pool`.

By default tasks are running in `default_pool`.
`default_pool` is initialized with 128 slots and user can change the
number of slots through UI/CLI. `default_pool` cannot be removed.

### `pool` config option in Celery section to support different Celery pool implementation

The new `pool` config option allows users to choose different pool
implementation. Default value is "prefork", while choices include "prefork" (default),
"eventlet", "gevent" or "solo". This may help users achieve better concurrency performance
in different scenarios.

For more details about Celery pool implementation, please refer to:
- https://docs.celeryproject.org/en/latest/userguide/workers.html#concurrency
- https://docs.celeryproject.org/en/latest/userguide/concurrency/eventlet.html


### Change to method signature in `BaseOperator` and `DAG` classes

The signature of the `get_task_instances` method in the `BaseOperator` and `DAG` classes has changed. The change does not change the behavior of the method in either case.

#### For `BaseOperator`

Old signature:

```python
def get_task_instances(self, session, start_date=None, end_date=None):
```

New signature:

```python
@provide_session
def get_task_instances(self, start_date=None, end_date=None, session=None):
```

#### For `DAG`

Old signature:

```python
def get_task_instances(
    self, session, start_date=None, end_date=None, state=None):
```

New signature:

```python
@provide_session
def get_task_instances(
    self, start_date=None, end_date=None, state=None, session=None):
```

In either case, it is necessary to rewrite calls to the `get_task_instances` method that currently provide the `session` positional argument. New calls to this method look like:

```python
# if you can rely on @provide_session
dag.get_task_instances()
# if you need to provide the session
dag.get_task_instances(session=your_session)
```

## Airflow 1.10.3

### New `dag_discovery_safe_mode` config option

If `dag_discovery_safe_mode` is enabled, only check files for DAGs if
they contain the strings "airflow" and "DAG". For backwards
compatibility, this option is enabled by default.

### RedisPy dependency updated to v3 series
If you are using the Redis Sensor or Hook you may have to update your code. See
[redis-py porting instructions] to check if your code might be affected (MSET,
MSETNX, ZADD, and ZINCRBY all were, but read the full doc).

[redis-py porting instructions]: https://github.com/andymccurdy/redis-py/tree/3.2.0#upgrading-from-redis-py-2x-to-30

### SLUGIFY_USES_TEXT_UNIDECODE or AIRFLOW_GPL_UNIDECODE no longer required

It is no longer required to set one of the environment variables to avoid
a GPL dependency. Airflow will now always use text-unidecode if unidecode
was not installed before.

### new `sync_parallelism` config option in celery section

The new `sync_parallelism` config option will control how many processes CeleryExecutor will use to
fetch celery task state in parallel. Default value is max(1, number of cores - 1)

### Rename of BashTaskRunner to StandardTaskRunner

BashTaskRunner has been renamed to StandardTaskRunner. It is the default task runner
so you might need to update your config.

`task_runner = StandardTaskRunner`

### Modification to config file discovery

If the `AIRFLOW_CONFIG` environment variable was not set and the
`~/airflow/airflow.cfg` file existed, airflow previously used
`~/airflow/airflow.cfg` instead of `$AIRFLOW_HOME/airflow.cfg`. Now airflow
will discover its config file using the `$AIRFLOW_CONFIG` and `$AIRFLOW_HOME`
environment variables rather than checking for the presence of a file.

### Changes in Google Cloud related operators

Most GCP-related operators have now optional `PROJECT_ID` parameter. In case you do not specify it,
the project id configured in
[GCP Connection](https://airflow.apache.org/howto/manage-connections.html#connection-type-gcp) is used.
There will be an `AirflowException` thrown in case `PROJECT_ID` parameter is not specified and the
connection used has no project id defined. This change should be  backwards compatible as earlier version
of the operators had `PROJECT_ID` mandatory.

Operators involved:

  * GCP Compute Operators
    * GceInstanceStartOperator
    * GceInstanceStopOperator
    * GceSetMachineTypeOperator
  * GCP Function Operators
    * GcfFunctionDeployOperator
  * GCP Cloud SQL Operators
    * CloudSqlInstanceCreateOperator
    * CloudSqlInstancePatchOperator
    * CloudSqlInstanceDeleteOperator
    * CloudSqlInstanceDatabaseCreateOperator
    * CloudSqlInstanceDatabasePatchOperator
    * CloudSqlInstanceDatabaseDeleteOperator

Other GCP operators are unaffected.

### Changes in Google Cloud related hooks

The change in GCP operators implies that GCP Hooks for those operators require now keyword parameters rather
than positional ones in all methods where `project_id` is used. The methods throw an explanatory exception
in case they are called using positional parameters.

Hooks involved:

  * GceHook
  * GcfHook
  * CloudSqlHook

Other GCP hooks are unaffected.

### Changed behaviour of using default value when accessing variables
It's now possible to use `None` as a default value with the `default_var` parameter when getting a variable, e.g.

```python
foo = Variable.get("foo", default_var=None)
if foo is None:
    handle_missing_foo()
```

(Note: there is already `Variable.setdefault()` which me be helpful in some cases.)

This changes the behaviour if you previously explicitly provided `None` as a default value. If your code expects a `KeyError` to be thrown, then don't pass the `default_var` argument.

### Removal of `airflow_home` config setting

There were previously two ways of specifying the Airflow "home" directory
(`~/airflow` by default): the `AIRFLOW_HOME` environment variable, and the
`airflow_home` config setting in the `[core]` section.

If they had two different values different parts of the code base would end up
with different values. The config setting has been deprecated, and you should
remove the value from the config file and set `AIRFLOW_HOME` environment
variable if you need to use a non default value for this.

(Since this setting is used to calculate what config file to load, it is not
possible to keep just the config option)

### Change of two methods signatures in `GCPTransferServiceHook`

The signature of the `create_transfer_job` method in `GCPTransferServiceHook`
class has changed. The change does not change the behavior of the method.

Old signature:
```python
def create_transfer_job(self, description, schedule, transfer_spec, project_id=None):
```
New signature:
```python
def create_transfer_job(self, body):
```

It is necessary to rewrite calls to method. The new call looks like this:
```python
body = {
  'status': 'ENABLED',
  'projectId': project_id,
  'description': description,
  'transferSpec': transfer_spec,
  'schedule': schedule,
}
gct_hook.create_transfer_job(body)
```
The change results from the unification of all hooks and adjust to
[the official recommendations](https://lists.apache.org/thread.html/e8534d82be611ae7bcb21ba371546a4278aad117d5e50361fd8f14fe@%3Cdev.airflow.apache.org%3E)
for the Google Cloud.

The signature of `wait_for_transfer_job` method in `GCPTransferServiceHook` has changed.

Old signature:
```python
def wait_for_transfer_job(self, job):
```
New signature:
```python
def wait_for_transfer_job(self, job, expected_statuses=(GcpTransferOperationStatus.SUCCESS, )):
```

The behavior of `wait_for_transfer_job` has changed:

Old behavior:

`wait_for_transfer_job` would wait for the SUCCESS status in specified jobs operations.

New behavior:

You can now specify an array of expected statuses. `wait_for_transfer_job` now waits for any of them.

The default value of `expected_statuses` is SUCCESS so that change is backwards compatible.

### Moved two classes to different modules

The class `GoogleCloudStorageToGoogleCloudStorageTransferOperator` has been moved from
`airflow.contrib.operators.gcs_to_gcs_transfer_operator` to `airflow.contrib.operators.gcp_transfer_operator`

the class `S3ToGoogleCloudStorageTransferOperator` has been moved from
`airflow.contrib.operators.s3_to_gcs_transfer_operator` to `airflow.contrib.operators.gcp_transfer_operator`

The change was made to keep all the operators related to GCS Transfer Services in one file.

The previous imports will continue to work until Airflow 2.0

### Fixed typo in --driver-class-path in SparkSubmitHook

The `driver_classapth` argument  to SparkSubmit Hook and Operator was
generating `--driver-classpath` on the spark command line, but this isn't a
valid option to spark.

The argument has been renamed to `driver_class_path`  and  the option it
generates has been fixed.

## Airflow 1.10.2

### New `dag_processor_manager_log_location` config option

The DAG parsing manager log now by default will be log into a file, where its location is
controlled by the new `dag_processor_manager_log_location` config option in core section.

### DAG level Access Control for new RBAC UI

Extend and enhance new Airflow RBAC UI to support DAG level ACL. Each dag now has two permissions(one for write, one for read) associated('can_dag_edit', 'can_dag_read').
The admin will create new role, associate the dag permission with the target dag and assign that role to users. That user can only access / view the certain dags on the UI
that he has permissions on. If a new role wants to access all the dags, the admin could associate dag permissions on an artificial view(``all_dags``) with that role.

We also provide a new cli command(``sync_perm``) to allow admin to auto sync permissions.

### Modification to `ts_nodash` macro
`ts_nodash` previously contained TimeZone information along with execution date. For Example: `20150101T000000+0000`. This is not user-friendly for file or folder names which was a popular use case for `ts_nodash`. Hence this behavior has been changed and using `ts_nodash` will no longer contain TimeZone information, restoring the pre-1.10 behavior of this macro. And a new macro `ts_nodash_with_tz` has been added which can be used to get a string with execution date and timezone info without dashes.

Examples:
  * `ts_nodash`: `20150101T000000`
  * `ts_nodash_with_tz`: `20150101T000000+0000`

### Semantics of next_ds/prev_ds changed for manually triggered runs

next_ds/prev_ds now map to execution_date instead of the next/previous schedule-aligned execution date for DAGs triggered in the UI.

### User model changes
This patch changes the `User.superuser` field from a hardcoded boolean to a `Boolean()` database column. `User.superuser` will default to `False`, which means that this privilege will have to be granted manually to any users that may require it.

For example, open a Python shell and
```python
from airflow import models, settings

session = settings.Session()
users = session.query(models.User).all()  # [admin, regular_user]

users[1].superuser  # False

admin = users[0]
admin.superuser = True
session.add(admin)
session.commit()
```

### Custom auth backends interface change

We have updated the version of flask-login we depend upon, and as a result any
custom auth backends might need a small change: `is_active`,
`is_authenticated`, and `is_anonymous` should now be properties. What this means is if
previously you had this in your user class

    def is_active(self):
      return self.active

then you need to change it like this

    @property
    def is_active(self):
      return self.active

### Support autodetected schemas to GoogleCloudStorageToBigQueryOperator

GoogleCloudStorageToBigQueryOperator is now support schema auto-detection is available when you load data into BigQuery. Unfortunately, changes can be required.

If BigQuery tables are created outside of airflow and the schema is not defined in the task, multiple options are available:

define a schema_fields:

    gcs_to_bq.GoogleCloudStorageToBigQueryOperator(
      ...
      schema_fields={...})

or define a schema_object:

    gcs_to_bq.GoogleCloudStorageToBigQueryOperator(
      ...
      schema_object='path/to/schema/object)

or enabled autodetect of schema:

    gcs_to_bq.GoogleCloudStorageToBigQueryOperator(
      ...
      autodetect=True)

## Airflow 1.10.1

### min_file_parsing_loop_time config option temporarily disabled

The scheduler.min_file_parsing_loop_time config option has been temporarily removed due to
some bugs.

### StatsD Metrics

The `scheduler_heartbeat` metric has been changed from a gauge to a counter. Each loop of the scheduler will increment the counter by 1. This provides a higher degree of visibility and allows for better integration with Prometheus using the [StatsD Exporter](https://github.com/prometheus/statsd_exporter). The scheduler's activity status can be determined by graphing and alerting using a rate of change of the counter. If the scheduler goes down, the rate will drop to 0.

### EMRHook now passes all of connection's extra to CreateJobFlow API

EMRHook.create_job_flow has been changed to pass all keys to the create_job_flow API, rather than
just specific known keys for greater flexibility.

However prior to this release the "emr_default" sample connection that was created had invalid
configuration, so creating EMR clusters might fail until your connection is updated. (Ec2KeyName,
Ec2SubnetId, TerminationProtection and KeepJobFlowAliveWhenNoSteps were all top-level keys when they
should be inside the "Instances" dict)

### LDAP Auth Backend now requires TLS

Connecting to an LDAP server over plain text is not supported anymore. The
certificate presented by the LDAP server must be signed by a trusted
certificate, or you must provide the `cacert` option under `[ldap]` in the
config file.

If you want to use LDAP auth backend without TLS then you will have to create a
custom-auth backend based on
https://github.com/apache/airflow/blob/1.10.0/airflow/contrib/auth/backends/ldap_auth.py

## Airflow 1.10

Installation and upgrading requires setting `SLUGIFY_USES_TEXT_UNIDECODE=yes` in your environment or
`AIRFLOW_GPL_UNIDECODE=yes`. In case of the latter a GPL runtime dependency will be installed due to a
dependency (python-nvd3 -> python-slugify -> unidecode).

### Replace DataProcHook.await calls to DataProcHook.wait

The method name was changed to be compatible with the Python 3.7 async/await keywords

### Setting UTF-8 as default mime_charset in email utils

### Add a configuration variable(default_dag_run_display_number) to control numbers of dag run for display

Add a configuration variable(default_dag_run_display_number) under webserver section to control the number of dag runs to show in UI.

### Default executor for SubDagOperator is changed to SequentialExecutor

### New Webserver UI with Role-Based Access Control

The current webserver UI uses the Flask-Admin extension. The new webserver UI uses the [Flask-AppBuilder (FAB)](https://github.com/dpgaspar/Flask-AppBuilder) extension. FAB has built-in authentication support and Role-Based Access Control (RBAC), which provides configurable roles and permissions for individual users.

To turn on this feature, in your airflow.cfg file (under [webserver]), set the configuration variable `rbac = True`, and then run `airflow` command, which will generate the `webserver_config.py` file in your $AIRFLOW_HOME.

#### Setting up Authentication

FAB has built-in authentication support for DB, OAuth, OpenID, LDAP, and REMOTE_USER. The default auth type is `AUTH_DB`.

For any other authentication type (OAuth, OpenID, LDAP, REMOTE_USER), see the [Authentication section of FAB docs](http://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-methods) for how to configure variables in webserver_config.py file.

Once you modify your config file, run `airflow db init` to generate new tables for RBAC support (these tables will have the prefix `ab_`).

#### Creating an Admin Account

Once configuration settings have been updated and new tables have been generated, create an admin account with `airflow create_user` command.

#### Using your new UI

Run `airflow webserver` to start the new UI. This will bring up a log in page, enter the recently created admin username and password.

There are five roles created for Airflow by default: Admin, User, Op, Viewer, and Public. To configure roles/permissions, go to the `Security` tab and click `List Roles` in the new UI.

#### Breaking changes

- AWS Batch Operator renamed property queue to job_queue to prevent conflict with the internal queue from CeleryExecutor - AIRFLOW-2542
- Users created and stored in the old users table will not be migrated automatically. FAB's built-in authentication support must be reconfigured.
- Airflow dag home page is now `/home` (instead of `/admin`).
- All ModelViews in Flask-AppBuilder follow a different pattern from Flask-Admin. The `/admin` part of the URL path will no longer exist. For example: `/admin/connection` becomes `/connection/list`, `/admin/connection/new` becomes `/connection/add`, `/admin/connection/edit` becomes `/connection/edit`, etc.
- Due to security concerns, the new webserver will no longer support the features in the `Data Profiling` menu of old UI, including `Ad Hoc Query`, `Charts`, and `Known Events`.
- HiveServer2Hook.get_results() always returns a list of tuples, even when a single column is queried, as per Python API 2.
- **UTC is now the default timezone**: Either reconfigure your workflows scheduling in UTC or set `default_timezone` as explained in https://airflow.apache.org/timezone.html#default-time-zone

### airflow.contrib.sensors.hdfs_sensors renamed to airflow.contrib.sensors.hdfs_sensor

We now rename airflow.contrib.sensors.hdfs_sensors to airflow.contrib.sensors.hdfs_sensor for consistency purpose.

### MySQL setting required

We now rely on more strict ANSI SQL settings for MySQL in order to have sane defaults. Make sure
to have specified `explicit_defaults_for_timestamp=1` in your my.cnf under `[mysqld]`

### Celery config

To make the config of Airflow compatible with Celery, some properties have been renamed:

```
celeryd_concurrency -> worker_concurrency
celery_result_backend -> result_backend
celery_ssl_active -> ssl_active
celery_ssl_cert -> ssl_cert
celery_ssl_key -> ssl_key
```

Resulting in the same config parameters as Celery 4, with more transparency.

### GCP Dataflow Operators

Dataflow job labeling is now supported in Dataflow{Java,Python}Operator with a default
"airflow-version" label, please upgrade your google-cloud-dataflow or apache-beam version
to 2.2.0 or greater.

### BigQuery Hooks and Operator

The `bql` parameter passed to `BigQueryOperator` and `BigQueryBaseCursor.run_query` has been deprecated and renamed to `sql` for consistency purposes. Using `bql` will still work (and raise a `DeprecationWarning`), but is no longer
supported and will be removed entirely in Airflow 2.0

### Redshift to S3 Operator

With Airflow 1.9 or lower, Unload operation always included header row. In order to include header row,
we need to turn off parallel unload. It is preferred to perform unload operation using all nodes so that it is
faster for larger tables. So, parameter called `include_header` is added and default is set to False.
Header row will be added only if this parameter is set True and also in that case parallel will be automatically turned off (`PARALLEL OFF`)

### Google cloud connection string

With Airflow 1.9 or lower, there were two connection strings for the Google Cloud operators, both `google_cloud_storage_default` and `google_cloud_default`. This can be confusing and therefore the `google_cloud_storage_default` connection id has been replaced with `google_cloud_default` to make the connection id consistent across Airflow.

### Logging Configuration

With Airflow 1.9 or lower, `FILENAME_TEMPLATE`, `PROCESSOR_FILENAME_TEMPLATE`, `LOG_ID_TEMPLATE`, `END_OF_LOG_MARK` were configured in `airflow_local_settings.py`. These have been moved into the configuration file, and hence if you were using a custom configuration file the following defaults need to be added.

```
[core]
fab_logging_level = WARN
log_filename_template = {{{{ ti.dag_id }}}}/{{{{ ti.task_id }}}}/{{{{ ts }}}}/{{{{ try_number }}}}.log
log_processor_filename_template = {{{{ filename }}}}.log

[elasticsearch]
elasticsearch_log_id_template = {{dag_id}}-{{task_id}}-{{execution_date}}-{{try_number}}
elasticsearch_end_of_log_mark = end_of_log
```

The previous setting of `log_task_reader` is not needed in many cases now when using the default logging config with remote storages. (Previously it needed to be set to `s3.task` or similar. This is not needed with the default config anymore)

#### Change of per-task log path

With the change to Airflow core to be timezone aware the default log path for task instances will now include timezone information. This will by default mean all previous task logs won't be found. You can get the old behaviour back by setting the following config options:

```
[core]
log_filename_template = {{ ti.dag_id }}/{{ ti.task_id }}/{{ execution_date.strftime("%%Y-%%m-%%dT%%H:%%M:%%S") }}/{{ try_number }}.log
```

## Airflow 1.9

### SSH Hook updates, along with new SSH Operator & SFTP Operator

SSH Hook now uses the Paramiko library to create an ssh client connection, instead of the sub-process based ssh command execution previously (<1.9.0), so this is backward incompatible.

- update SSHHook constructor
- use SSHOperator class in place of SSHExecuteOperator which is removed now. Refer to test_ssh_operator.py for usage info.
- SFTPOperator is added to perform secure file transfer from serverA to serverB. Refer to test_sftp_operator.py for usage info.
- No updates are required if you are using ftpHook, it will continue to work as is.

### S3Hook switched to use Boto3

The airflow.hooks.S3_hook.S3Hook has been switched to use boto3 instead of the older boto (a.k.a. boto2). This results in a few backwards incompatible changes to the following classes: S3Hook:

- the constructors no longer accepts `s3_conn_id`. It is now called `aws_conn_id`.
- the default connection is now "aws_default" instead of "s3_default"
- the return type of objects returned by `get_bucket` is now boto3.s3.Bucket
- the return type of `get_key`, and `get_wildcard_key` is now an boto3.S3.Object.

If you are using any of these in your DAGs and specify a connection ID you will need to update the parameter name for the connection to "aws_conn_id": S3ToHiveTransfer, S3PrefixSensor, S3KeySensor, RedshiftToS3Transfer.

### Logging update

The logging structure of Airflow has been rewritten to make configuration easier and the logging system more transparent.

#### A quick recap about logging

A logger is the entry point into the logging system. Each logger is a named bucket to which messages can be written for processing. A logger is configured to have a log level. This log level describes the severity of the messages that the logger will handle. Python defines the following log levels: DEBUG, INFO, WARNING, ERROR or CRITICAL.

Each message that is written to the logger is a Log Record. Each log record contains a log level indicating the severity of that specific message. A log record can also contain useful metadata that describes the event that is being logged. This can include details such as a stack trace or an error code.

When a message is given to the logger, the log level of the message is compared to the log level of the logger. If the log level of the message meets or exceeds the log level of the logger itself, the message will undergo further processing. If it doesn’t, the message will be ignored.

Once a logger has determined that a message needs to be processed, it is passed to a Handler. This configuration is now more flexible and can be easily be maintained in a single file.

#### Changes in Airflow Logging

Airflow's logging mechanism has been refactored to use Python’s built-in `logging` module to perform logging of the application. By extending classes with the existing `LoggingMixin`, all the logging will go through a central logger. Also the `BaseHook` and `BaseOperator` already extend this class, so it is easily available to do logging.

The main benefit is easier configuration of the logging by setting a single centralized python file. Disclaimer; there is still some inline configuration, but this will be removed eventually. The new logging class is defined by setting the dotted classpath in your `~/airflow/airflow.cfg` file:

```
# Logging class
# Specify the class that will specify the logging configuration
# This class has to be on the python classpath
logging_config_class = my.path.default_local_settings.LOGGING_CONFIG
```

The logging configuration file needs to be on the `PYTHONPATH`, for example `$AIRFLOW_HOME/config`. This directory is loaded by default. Any directory may be added to the `PYTHONPATH`, this might be handy when the config is in another directory or a volume is mounted in case of Docker.

The config can be taken from `airflow/config_templates/airflow_local_settings.py` as a starting point. Copy the contents to `${AIRFLOW_HOME}/config/airflow_local_settings.py`,  and alter the config as is preferred.

```
# -*- coding: utf-8 -*-
#
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

import os

from airflow import configuration as conf

# TODO: Logging format and level should be configured
# in this file instead of from airflow.cfg. Currently
# there are other log format and level configurations in
# settings.py and cli.py. Please see AIRFLOW-1455.

LOG_LEVEL = conf.get('core', 'LOGGING_LEVEL').upper()
LOG_FORMAT = conf.get('core', 'log_format')

BASE_LOG_FOLDER = conf.get('core', 'BASE_LOG_FOLDER')
PROCESSOR_LOG_FOLDER = conf.get('scheduler', 'child_process_log_directory')

FILENAME_TEMPLATE = '{{ ti.dag_id }}/{{ ti.task_id }}/{{ ts }}/{{ try_number }}.log'
PROCESSOR_FILENAME_TEMPLATE = '{{ filename }}.log'

DEFAULT_LOGGING_CONFIG = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'airflow.task': {
            'format': LOG_FORMAT,
        },
        'airflow.processor': {
            'format': LOG_FORMAT,
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'airflow.task',
            'stream': 'ext://sys.stdout'
        },
        'file.task': {
            'class': 'airflow.utils.log.file_task_handler.FileTaskHandler',
            'formatter': 'airflow.task',
            'base_log_folder': os.path.expanduser(BASE_LOG_FOLDER),
            'filename_template': FILENAME_TEMPLATE,
        },
        'file.processor': {
            'class': 'airflow.utils.log.file_processor_handler.FileProcessorHandler',
            'formatter': 'airflow.processor',
            'base_log_folder': os.path.expanduser(PROCESSOR_LOG_FOLDER),
            'filename_template': PROCESSOR_FILENAME_TEMPLATE,
        }
        # When using s3 or gcs, provide a customized LOGGING_CONFIG
        # in airflow_local_settings within your PYTHONPATH, see UPDATING.md
        # for details
        # 's3.task': {
        #     'class': 'airflow.utils.log.s3_task_handler.S3TaskHandler',
        #     'formatter': 'airflow.task',
        #     'base_log_folder': os.path.expanduser(BASE_LOG_FOLDER),
        #     's3_log_folder': S3_LOG_FOLDER,
        #     'filename_template': FILENAME_TEMPLATE,
        # },
        # 'gcs.task': {
        #     'class': 'airflow.utils.log.gcs_task_handler.GCSTaskHandler',
        #     'formatter': 'airflow.task',
        #     'base_log_folder': os.path.expanduser(BASE_LOG_FOLDER),
        #     'gcs_log_folder': GCS_LOG_FOLDER,
        #     'filename_template': FILENAME_TEMPLATE,
        # },
    },
    'loggers': {
        '': {
            'handlers': ['console'],
            'level': LOG_LEVEL
        },
        'airflow': {
            'handlers': ['console'],
            'level': LOG_LEVEL,
            'propagate': False,
        },
        'airflow.processor': {
            'handlers': ['file.processor'],
            'level': LOG_LEVEL,
            'propagate': True,
        },
        'airflow.task': {
            'handlers': ['file.task'],
            'level': LOG_LEVEL,
            'propagate': False,
        },
        'airflow.task_runner': {
            'handlers': ['file.task'],
            'level': LOG_LEVEL,
            'propagate': True,
        },
    }
}
```

To customize the logging (for example, use logging rotate), define one or more of the logging handles that [Python has to offer](https://docs.python.org/3/library/logging.handlers.html). For more details about the Python logging, please refer to the [official logging documentation](https://docs.python.org/3/library/logging.html).

Furthermore, this change also simplifies logging within the DAG itself:

```
root@ae1bc863e815:/airflow# python
Python 3.6.2 (default, Sep 13 2017, 14:26:54)
[GCC 4.9.2] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from airflow.settings import *
>>>
>>> from datetime import datetime
>>> from airflow import DAG
>>> from airflow.operators.dummy_operator import DummyOperator
>>>
>>> dag = DAG('simple_dag', start_date=datetime(2017, 9, 1))
>>>
>>> task = DummyOperator(task_id='task_1', dag=dag)
>>>
>>> task.log.error('I want to say something..')
[2017-09-25 20:17:04,927] {<stdin>:1} ERROR - I want to say something..
```

#### Template path of the file_task_handler

The `file_task_handler` logger has been made more flexible. The default format can be changed, `{dag_id}/{task_id}/{execution_date}/{try_number}.log` by supplying Jinja templating in the `FILENAME_TEMPLATE` configuration variable. See the `file_task_handler` for more information.

#### I'm using S3Log or GCSLogs, what do I do!?

If you are logging to Google cloud storage, please see the [Google cloud platform documentation](https://airflow.apache.org/integration.html#gcp-google-cloud-platform) for logging instructions.

If you are using S3, the instructions should be largely the same as the Google cloud platform instructions above. You will need a custom logging config. The `REMOTE_BASE_LOG_FOLDER` configuration key in your airflow config has been removed, therefore you will need to take the following steps:

- Copy the logging configuration from [`airflow/config_templates/airflow_logging_settings.py`](https://github.com/apache/airflow/blob/master/airflow/config_templates/airflow_local_settings.py).
- Place it in a directory inside the Python import path `PYTHONPATH`. If you are using Python 2.7, ensuring that any `__init__.py` files exist so that it is importable.
- Update the config by setting the path of `REMOTE_BASE_LOG_FOLDER` explicitly in the config. The `REMOTE_BASE_LOG_FOLDER` key is not used anymore.
- Set the `logging_config_class` to the filename and dict. For example, if you place `custom_logging_config.py` on the base of your `PYTHONPATH`, you will need to set `logging_config_class = custom_logging_config.LOGGING_CONFIG` in your config as Airflow 1.8.

### New Features

#### Dask Executor

A new DaskExecutor allows Airflow tasks to be run in Dask Distributed clusters.

### Deprecated Features

These features are marked for deprecation. They may still work (and raise a `DeprecationWarning`), but are no longer
supported and will be removed entirely in Airflow 2.0

- If you're using the `google_cloud_conn_id` or `dataproc_cluster` argument names explicitly in `contrib.operators.Dataproc{*}Operator`(s), be sure to rename them to `gcp_conn_id` or `cluster_name`, respectively. We've renamed these arguments for consistency. (AIRFLOW-1323)

- `post_execute()` hooks now take two arguments, `context` and `result`
  (AIRFLOW-886)

  Previously, post_execute() only took one argument, `context`.

- `contrib.hooks.gcp_dataflow_hook.DataFlowHook` starts to use `--runner=DataflowRunner` instead of `DataflowPipelineRunner`, which is removed from the package `google-cloud-dataflow-0.6.0`.

- The pickle type for XCom messages has been replaced by json to prevent RCE attacks.
  Note that JSON serialization is stricter than pickling, so if you want to e.g. pass
  raw bytes through XCom you must encode them using an encoding like base64.
  By default pickling is still enabled until Airflow 2.0. To disable it
  set enable_xcom_pickling = False in your Airflow config.

## Airflow 1.8.1

The Airflow package name was changed from `airflow` to `apache-airflow` during this release. You must uninstall
a previously installed version of Airflow before installing 1.8.1.

## Airflow 1.8

### Database

The database schema needs to be upgraded. Make sure to shutdown Airflow and make a backup of your database. To
upgrade the schema issue `airflow upgradedb`.

### Upgrade systemd unit files

Systemd unit files have been updated. If you use systemd please make sure to update these.

> Please note that the webserver does not detach properly, this will be fixed in a future version.

### Tasks not starting although dependencies are met due to stricter pool checking

Airflow 1.7.1 has issues with being able to over subscribe to a pool, ie. more slots could be used than were
available. This is fixed in Airflow 1.8.0, but due to past issue jobs may fail to start although their
dependencies are met after an upgrade. To workaround either temporarily increase the amount of slots above
the amount of queued tasks or use a new pool.

### Less forgiving scheduler on dynamic start_date

Using a dynamic start_date (e.g. `start_date = datetime.now()`) is not considered a best practice. The 1.8.0 scheduler
is less forgiving in this area. If you encounter DAGs not being scheduled you can try using a fixed start_date and
renaming your DAG. The last step is required to make sure you start with a clean slate, otherwise the old schedule can
interfere.

### New and updated scheduler options

Please read through the new scheduler options, defaults have changed since 1.7.1.

#### child_process_log_directory

In order to increase the robustness of the scheduler, DAGS are now processed in their own process. Therefore each
DAG has its own log file for the scheduler. These log files are placed in `child_process_log_directory` which defaults to
`<AIRFLOW_HOME>/scheduler/latest`. You will need to make sure these log files are removed.

> DAG logs or processor logs ignore and command line settings for log file locations.

#### run_duration

Previously the command line option `num_runs` was used to let the scheduler terminate after a certain amount of
loops. This is now time bound and defaults to `-1`, which means run continuously. See also num_runs.

#### num_runs

Previously `num_runs` was used to let the scheduler terminate after a certain amount of loops. Now num_runs specifies
the number of times to try to schedule each DAG file within `run_duration` time. Defaults to `-1`, which means try
indefinitely. This is only available on the command line.

#### min_file_process_interval

After how much time should an updated DAG be picked up from the filesystem.

#### min_file_parsing_loop_time
CURRENTLY DISABLED DUE TO A BUG
How many seconds to wait between file-parsing loops to prevent the logs from being spammed.

#### dag_dir_list_interval

The frequency with which the scheduler should relist the contents of the DAG directory. If while developing +dags, they are not being picked up, have a look at this number and decrease it when necessary.

#### catchup_by_default

By default the scheduler will fill any missing interval DAG Runs between the last execution date and the current date.
This setting changes that behavior to only execute the latest interval. This can also be specified per DAG as
`catchup = False / True`. Command line backfills will still work.

### Faulty DAGs do not show an error in the Web UI

Due to changes in the way Airflow processes DAGs the Web UI does not show an error when processing a faulty DAG. To
find processing errors go the `child_process_log_directory` which defaults to `<AIRFLOW_HOME>/scheduler/latest`.

### New DAGs are paused by default

Previously, new DAGs would be scheduled immediately. To retain the old behavior, add this to airflow.cfg:

```
[core]
dags_are_paused_at_creation = False
```

### Airflow Context variable are passed to Hive config if conf is specified

If you specify a hive conf to the run_cli command of the HiveHook, Airflow add some
convenience variables to the config. In case you run a secure Hadoop setup it might be
required to allow these variables by adjusting you hive configuration to add `airflow\.ctx\..*` to the regex
of user-editable configuration properties. See
[the Hive docs on Configuration Properties][hive.security.authorization.sqlstd] for more info.

[hive.security.authorization.sqlstd]: https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=82903061#ConfigurationProperties-SQLStandardBasedAuthorization.1

### Google Cloud Operator and Hook alignment

All Google Cloud Operators and Hooks are aligned and use the same client library. Now you have a single connection
type for all kinds of Google Cloud Operators.

If you experience problems connecting with your operator make sure you set the connection type "Google Cloud Platform".

Also the old P12 key file type is not supported anymore and only the new JSON key files are supported as a service
account.

### Deprecated Features

These features are marked for deprecation. They may still work (and raise a `DeprecationWarning`), but are no longer
supported and will be removed entirely in Airflow 2.0

- Hooks and operators must be imported from their respective submodules

  `airflow.operators.PigOperator` is no longer supported; `from airflow.operators.pig_operator import PigOperator` is.
  (AIRFLOW-31, AIRFLOW-200)

- Operators no longer accept arbitrary arguments

  Previously, `Operator.__init__()` accepted any arguments (either positional `*args` or keyword `**kwargs`) without
  complaint. Now, invalid arguments will be rejected. (https://github.com/apache/airflow/pull/1285)

- The config value secure_mode will default to True which will disable some insecure endpoints/features

### Known Issues

There is a report that the default of "-1" for num_runs creates an issue where errors are reported while parsing tasks.
It was not confirmed, but a workaround was found by changing the default back to `None`.

To do this edit `cli.py`, find the following:

```
        'num_runs': Arg(
            ("-n", "--num_runs"),
            default=-1, type=int,
            help="Set the number of runs to execute before exiting"),
```

and change `default=-1` to `default=None`. If you have this issue please report it on the mailing list.

## Airflow 1.7.1.2

### Changes to Configuration

#### Email configuration change

To continue using the default smtp email backend, change the email_backend line in your config file from:

```
[email]
email_backend = airflow.utils.send_email_smtp
```

to:

```
[email]
email_backend = airflow.utils.email.send_email_smtp
```

#### S3 configuration change

To continue using S3 logging, update your config file so:

```
s3_log_folder = s3://my-airflow-log-bucket/logs
```

becomes:

```
remote_base_log_folder = s3://my-airflow-log-bucket/logs
remote_log_conn_id = <your desired s3 connection>
```
