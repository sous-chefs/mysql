# MySQL cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/mysql.svg)](https://supermarket.chef.io/cookbooks/mysql)

Manage Oracle MySQL instances, configuration, clients, databases and accounts with unified custom resources. Requires Chef Infra 17 or later and systemd. MySQL 8.4 LTS is the default. Repository configuration remains the caller's responsibility; this cookbook does not substitute MariaDB or Percona.

```ruby
mysql_service 'application' do
  version '8.4'
  initial_root_password secret_store.fetch('mysql-root-password')
  bind_address '127.0.0.1'
  action [:create, :start]
end

mysql_database 'application' do
  socket '/run/mysql-application/mysqld.sock'
  password secret_store.fetch('mysql-root-password')
  encoding 'utf8mb4'
  collation 'utf8mb4_0900_ai_ci'
end
```

Use your existing secret store; `secret_store` above represents your own integration. Password properties are sensitive. SQL runs through the vendor client with a temporary private options file, without shell interpolation or password arguments. Errors report the MySQL error number without query text or credentials.

## Resources

- [mysql_service](documentation/resource_mysql_service.md)
- [mysql_client](documentation/resource_mysql_client.md)
- [mysql_client_config](documentation/resource_mysql_client_config.md)
- [mysql_config](documentation/resource_mysql_config.md)
- [mysql_database](documentation/resource_mysql_database.md)
- [mysql_user](documentation/resource_mysql_user.md)

The installation aliases `mysql_client_installation`, `mysql_client_installation_package`, `mysql_server_installation` and `mysql_server_installation_package` remain available. Server installation supports `:install` and `:delete`; client installation supports `:create` and `:delete`.

## Platforms

Retains AlmaLinux, Amazon Linux, CentOS Stream, Debian, Fedora, openSUSE Leap, Oracle Linux, RHEL, Rocky Linux and Ubuntu support. See metadata for minimum versions. Operators must provide compatible Oracle MySQL packages or use `install_method 'none'` with a preinstalled server. Oracle's package availability varies by distribution and architecture.

On hosts with a vendor AppArmor profile, the service adds instance-specific access rules and reloads that profile. It preserves existing policy and does not disable confinement. Configure SELinux policy for custom instance paths in your wrapper cookbook; the cookbook does not disable SELinux.

The explicit `apparmor_mode 'validate'` option parses policy without loading it for image/container builds. Production defaults remain `enforce`; failed live loads still fail convergence. Docker tests use offline policy validation and isolated copies of package executables to avoid runner-global profiles. They verify package/bootstrap behaviour, not live host kernel confinement.

## Migration to version 12

This is a full migration from library resource inheritance to flat custom resources. Resource names, instance paths, SQL actions and installation aliases remain. There are no root recipes or node attribute defaults.

- The default server series is 8.4. Set `version` explicitly for an existing 8.0 installation. This does not authorise an engine or data upgrade: the service refuses an installed-series mismatch and starts with `--upgrade=NONE`. Plan and perform upgrades separately using Oracle's procedure.
- New databases require an explicit, non-empty `initial_root_password`. The property is sensitive. Existing databases retain their credentials; this property is not a password rotation mechanism.
- Current server authentication replaces implicit `mysql_native_password`. Set `use_native_auth true` or explicitly pass `MysqlCookbook::HashedPassword` only when you deliberately enable legacy authentication on the server. MySQL 8.4 disables that plugin by default.
- Systemd replaces SysV, Upstart and Solaris service managers. These obsolete managers are not available on the retained supported platforms.
- `mysql_service :delete` stops and removes its unit and configuration. It preserves the data directory, logs, shared packages and system account. Remove data or uninstall shared packages explicitly if required.
- Configuration uses an explicit defaults file. The cookbook no longer deletes global vendor configuration, stops unrelated vendor instances or modifies global SQL mode. Vendor package post-install scripts may create a default instance; operators own that instance separately.
- Explicit SQL `:query` actions always execute and report an update. Use Chef guards for application-specific idempotency.

## Testing

Run `chef install`, `chef exec cookstyle`, `chef exec rspec` and `KITCHEN_LOCAL_YAML=kitchen.dokken.yml kitchen test`. Kitchen performs two converges and verifies a real server, scoped grants, current authentication and private files. The default suite uses checksum-pinned Oracle binaries to exercise all retained Linux families independently of repository availability; package suites exercise Oracle repositories on Ubuntu and AlmaLinux. Optional real SQL specs require an isolated test client configured through `MYSQL_REAL_TEST_CLI`; never point these tests at a production server.

## Licence

Apache-2.0. Maintained by [Sous Chefs](https://sous-chefs.org/).
