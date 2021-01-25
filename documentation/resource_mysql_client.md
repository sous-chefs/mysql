# mysql\_client

The `mysql_client` resource manages the MySQL client binaries and development libraries.

It is an example of a "singleton" resource. Declaring two `mysql_client` resources on a machine usually won't yield two separate copies of the client binaries, except for platforms that support multiple versions (RHEL SCL, OmniOS).

## Example

```ruby
mysql_client 'default' do
  action :create
end
```

## Properties

- `package_name` - An array of packages to be installed. Defaults to a value looked up in an internal map.
- `package_version` - Specific versions of the package to install, passed onto the underlying package manager. Defaults to `nil`.
- `version` - Major MySQL version number of client packages. Only valid on for platforms that support multiple versions, such as RHEL via Software Collections and OmniOS.

## Actions

- `:create` - Installs the client software
- `:delete` - Removes the client software
