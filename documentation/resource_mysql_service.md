# mysql_service

Manage an independent systemd MySQL instance. Actions: `:create` (default), `:start`, `:stop`, `:restart`, `:delete`. `mysql_service_manager` and `mysql_service_manager_systemd` remain aliases.

| Property | Default | Purpose |
| --- | --- | --- |
| `instance` | resource name | Instance identifier; `default` uses the traditional mysql paths |
| `version` | `8.4` | Expected server series; never implicitly upgrades an existing server |
| `initial_root_password` | none | Required, non-empty sensitive secret for fresh bootstrap only |
| `install_method` | `auto` | `auto`, `package` or `none` for caller-installed binaries |
| `service_manager` | `auto` | `auto` or `systemd` |
| `apparmor_mode` | `enforce` | Load installed vendor policy; explicit `validate` only parses policy without loading it |
| `run_user`, `run_group` | `mysql` | System account and group |
| `package_name` | `mysql-community-server` | Caller-configured Oracle package repository |
| `package_version`, `package_options` | none | Exact package version and provider options |
| `bind_address` | none | Server bind address |
| `charset` | `utf8` | Server/client character set |
| `port` | `3306` | Server port |
| `data_dir` | `/var/lib/mysql-INSTANCE` | Persistent database files |
| `include_dir` | `/etc/mysql-INSTANCE/conf.d` | Additional configuration |
| `socket` | `/run/mysql-INSTANCE/mysqld.sock` | Unix socket; `socket_file` remains an alias |
| `pid_file` | `/run/mysql-INSTANCE/mysqld.pid` | PID file |
| `error_log` | `/var/log/mysql-INSTANCE/error.log` | Error log |
| `tmp_dir` | none | Optional server temporary directory |
| `mysqld_options` | `{}` | Additional mysqld settings |
| `mysqld_binary`, `mysql_binary`, `mysqladmin_binary` | `/usr/sbin/mysqld`, `/usr/bin/mysql`, `/usr/bin/mysqladmin` | Preinstalled vendor executables |

For instance `default`, configuration, data and logs use `mysql` instead of `mysql-INSTANCE`; Debian-family sockets use `/run/mysqld`. `major_version` remains a derived compatibility property.

Create writes configuration and enables the unit; start is explicit. Notify `:restart` when changing additional configuration. Existing data keeps its root credentials. Interrupted fresh bootstrap retains a private recovery marker and retries only that bootstrap; it never resets arbitrary existing databases. The unit refuses automatic data upgrades with `--upgrade=NONE`.

For multiple instances, configure distinct classic ports, sockets and X Protocol ports, or explicitly disable X Protocol with `mysqld_options('mysqlx' => 0)`. The server's normal network defaults otherwise apply.

Delete preserves data, logs, system accounts and packages. It refuses to remove configuration containing the configured data directory. Stop an existing vendor default instance before adopting its paths, and manage its credentials explicitly. See the README for AppArmor and SELinux requirements.

The default AppArmor mode loads the installed vendor profile and fails real policy-load errors. `validate` is an explicit option for image builds or containers without a kernel policy interface; it writes and parses policy but provides no evidence of kernel confinement. Integration package fixtures use that mode and a fixture-local copy of the installed package binary so runner-global profiles do not apply to the nested test instance. Production binary/profile defaults remain unchanged.
