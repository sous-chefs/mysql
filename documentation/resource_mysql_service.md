# mysql\_service

The `mysql_service` resource manages the basic plumbing needed to get a MySQL server instance running with minimal configuration.

The `:create` action handles package installation, support directories, socket files, and other operating system level concerns. The internal configuration file contains just enough to get the service up and running, then loads extra configuration from a conf.d directory. Further configurations are managed with the `mysql_config` resource.

- If the `data_dir` is empty, a database will be initialized, and a
- root user will be set up with `initial_root_password`. If this
- directory already contains database files, no action will be taken.

The `:start` action starts the service on the machine using the appropriate provider for the platform. The `:start` action should be omitted when used in recipes designed to build containers.

## Example

```ruby
mysql_service 'default' do
  version '8.4'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password 'Ch4ng3me'
  action [:create, :start]
end
```

Please note that when using `notifies` or `subscribes`, the resource to reference is `mysql_service[name]`, not `service[mysql]`.

## Properties

- `bind_address` - determines the listen IP address for the mysqld service. When omitted, it will be determined by MySQL. If the address is "regular" IPv4/IPv6 address (e.g 127.0.0.1 or ::1), the server accepts TCP/IP connections only for that particular address. If the address is "0.0.0.0" (IPv4) or "::" (IPv6), the server accepts TCP/IP connections on all IPv4 or IPv6 interfaces.
- `charset` - specifies the default character set. Defaults to `utf8`.
- `data_dir` - determines where the actual data files are kept on the machine. This is useful when mounting external storage. When omitted, it will default to the platform's native location.
- `error_log` - Tunable location of the error\_log.
- `include_dir` - The directory for additional configuration files. Defaults to a calculated value based on platform.
- `initial_root_password` - allows the user to specify the initial root password for mysql when initializing new databases. This can be set explicitly in a recipe, driven from a node attribute, or from data\_bags. When omitted, it defaults to `ilikerandompasswords`. Please be sure to change it.
- `instance` - A string to identify the MySQL service. By convention, to allow for multiple instances of the `mysql_service`, directories and files on disk are named `mysql-<instance_name>`. Defaults to the resource name.
- `major_version` - The major version of MySQL (e.g., `8.0`). Derived from `version` property.
- `mysqld_options` - A key value hash of options to be rendered into the main my.cnf. WARNING - It is highly recommended that you use the `mysql_config` resource instead of sending extra config into a `mysql_service` resource. This will allow you to set up notifications and subscriptions between the service and its configuration. That being said, this can be useful for adding extra options needed for database initialization at first run.
- `package_name` - Defaults to a value looked up in an internal map.
- `package_options` - Additional options to pass to the package manager. Defaults to `nil`.
- `package_version` - Specific version of the package to install, passed onto the underlying package manager. Defaults to `nil`.
- `pid_file` - Tunable location of the pid file.
- `port` - determines the listen port for the mysqld service. When omitted, it will default to '3306'.
- `run_group` - The name of the system group the `mysql_service` should run as. Defaults to 'mysql'.
- `run_user` - The name of the system user the `mysql_service` should run as. Defaults to 'mysql'.
- `socket` - determines where to write the socket file for the `mysql_service` instance. Useful when configuring clients on the same machine to talk over socket and skip the networking stack. Defaults to a calculated value based on platform and instance name.
- `tmp_dir` - Tunable location of the tmp\_dir.
- `version` - allows the user to select from the versions available for the platform, where applicable. When omitted, it will install the default MySQL version for the target platform. Available version numbers are `8.0` and `8.4`, depending on platform. See [LIMITATIONS.md](../LIMITATIONS.md) for the full support matrix.

## Actions

- `:create` - Configures everything but the underlying operating system service.
- `:delete` - Removes everything but the package and data\_dir.
- `:start` - Starts the underlying operating system service.
- `:stop`- Stops the underlying operating system service.
- `:restart` - Restarts the underlying operating system service.
- `:reload` - Reloads the underlying operating system service.

## Service Management

This resource uses **systemd** exclusively for service management. Legacy init systems (SysVinit, Upstart) are no longer supported. The resource manages a systemd unit file at `/etc/systemd/system/mysql.service` (or `mysql-<instance>.service` for named instances).
