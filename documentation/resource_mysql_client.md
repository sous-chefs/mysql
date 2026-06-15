# mysql\_client

The `mysql_client` resource manages the MySQL client binaries and development libraries.

## Example

```ruby
mysql_client 'default' do
  version '8.4'
  action :create
end
```

## Properties

- `package_name` - An array of packages to be installed. Defaults to a platform-specific value (e.g. `mysql-community-client` on RHEL, `mysql-client-8.0` on Ubuntu).
- `package_options` - Additional options to pass to the package manager. Defaults to `nil`.
- `package_version` - Specific version of the package to install, passed onto the underlying package manager. Defaults to `nil`.
- `version` - MySQL version string (e.g. `8.0`, `8.4`). Used to determine the default package names. Defaults to the platform default.
- `major_version` - Derived from `version`. Used internally for package name resolution.
- `run_user` - System user. Defaults to `mysql`.
- `run_group` - System group. Defaults to `mysql`.
- `include_dir` - The conf.d directory path. Defaults to a calculated value.

## Actions

- `:create` - Installs the client software (default)
- `:delete` - Removes the client software
