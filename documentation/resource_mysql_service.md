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
  version '5.7'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password 'Ch4ng3me'
  action [:create, :start]
end
```

Please note that when using `notifies` or `subscribes`, the resource to reference is `mysql_service[name]`, not `service[mysql]`.

## Parameters

- `charset` - specifies the default character set. Defaults to `utf8`.
- `data_dir` - determines where the actual data files are kept on the machine. This is useful when mounting external storage. When omitted, it will default to the platform's native location.
- `error_log` - Tunable location of the error\_log
- `initial_root_password` - allows the user to specify the initial root password for mysql when initializing new databases. This can be set explicitly in a recipe, driven from a node attribute, or from data\_bags. When omitted, it defaults to `ilikerandompasswords`. Please be sure to change it.
- `instance` - A string to identify the MySQL service. By convention, to allow for multiple instances of the `mysql_service`, directories and files on disk are named `mysql-<instance_name>`. Defaults to the resource name.
- `package_name` - Defaults to a value looked up in an internal map.
- `package_version` - Specific version of the package to install,passed onto the underlying package manager. Defaults to `nil`.
- `bind_address` - determines the listen IP address for the mysqld service. When omitted, it will be determined by MySQL. If the address is "regular" IPv4/IPv6address (e.g 127.0.0.1 or ::1), the server accepts TCP/IP connections only for that particular address. If the address is "0.0.0.0" (IPv4) or "::" (IPv6), the server accepts TCP/IP connections on all IPv4 or IPv6 interfaces.
- `mysqld_options` - A key value hash of options to be rendered into the main my.cnf. WARNING - It is highly recommended that you use the `mysql_config` resource instead of sending extra config into a `mysql_service` resource. This will allow you to set up notifications and subscriptions between the service and its configuration. That being said, this can be useful for adding extra options needed for database initialization at first run.
- `port` - determines the listen port for the mysqld service. When omitted, it will default to '3306'.
- `run_group` - The name of the system group the `mysql_service` should run as. Defaults to 'mysql'.
- `run_user` - The name of the system user the `mysql_service` should run as. Defaults to 'mysql'.
- `pid_file` - Tunable location of the pid file.
- `socket` - determines where to write the socket file for the `mysql_service` instance. Useful when configuring clients on the same machine to talk over socket and skip the networking stack. Defaults to a calculated value based on platform and instance name.
- `tmp_dir` - Tunable location of the tmp\_dir.
- `version` - allows the user to select from the versions available for the platform, where applicable. When omitted, it will install the default MySQL version for the target platform. Available version numbers are `5.6`, `5.7`, and `8.0`, depending on platform.

## Actions

- `:create` - Configures everything but the underlying operating system service.
- `:delete` - Removes everything but the package and data\_dir.
- `:start` - Starts the underlying operating system service.
- `:stop`- Stops the underlying operating system service.
- `:restart` - Restarts the underlying operating system service.
- `:reload` - Reloads the underlying operating system service.

## Providers

Chef selects the appropriate provider based on platform and version, but you can specify one if your platform support it.

```ruby
mysql_service[instance-1] do
  port '1234'
  data_dir '/mnt/lottadisk'
  provider Chef::Provider::MysqlServiceSysvinit
  action [:create, :start]
end
```

- `Chef::Provider::MysqlServiceBase` - Configures everything needed to run a MySQL service except the platform service facility. This provider should never be used directly. The `:start`, `:stop`, `:restart`, and `:reload` actions are stubs meant to be overridden by the providers below.
- `Chef::Provider::MysqlServiceSmf` - Starts a `mysql_service` using the Service Management Facility, used by Solaris and Illumos. Manages the FMRI and method script.
- `Chef::Provider::MysqlServiceSystemd` - Starts a `mysql_service` using SystemD. Manages the unit file and activation state
- `Chef::Provider::MysqlServiceSysvinit` - Starts a `mysql_service` using SysVinit. Manages the init script and status.
- `Chef::Provider::MysqlServiceUpstart` - Starts a `mysql_service` using Upstart. Manages job definitions and status.
