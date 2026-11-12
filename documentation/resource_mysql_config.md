# mysql_config

Render an additional instance configuration template. Actions: `:create` (default), `:delete`.

`config_name` defaults to the resource name; the target is `include_dir/config_name.cnf`. `instance` defaults to `default`. `include_dir` defaults to `/etc/mysql/conf.d` for the default instance or `/etc/mysql-INSTANCE/conf.d` otherwise. `owner` and `group` default to `mysql`; both are honoured when creating the account and directory. `source`, `cookbook` and `variables` pass through to the template resource. Default variables are `{}`. `run_user`, `run_group`, `version` and `major_version` remain compatibility properties inherited from the shared base partial.

Notify the matching `mysql_service` to restart when your configuration requires it. Delete removes only the named configuration file.
