# mysql\_user

Manage MySQL users and grant them privileges on database objects.

## Actions

- create - (default) to create a user
- drop - to drop a user
- grant - to grant privileges to a user
- revoke - to revoke privileges from a user

## Properties

Name              | Types                  | Description                                                  | Default                                   | Required?
----------------- | ---------------------- | ------------------------------------------------------------ | ----------------------------------------- | ---------
`ctrl_user`       | String                 | the username of the control connection                       | `root`                                    | no
`ctrl_password`   | String                 | password of the user used to connect to                      |                                           | no
`ctrl_host`       | String                 | host to connect to                                           | `localhost`                               | no
`ctrl_port`       | String                 | port of the host to connect to                               | `3306`                                    | no
`username`        | String                 | The database user to be managed                              | `name` if not defined                     | no
`host`            | String                 | The host from which the user is allowed to connect           | `localhost`                               | no
`password`        | String, HashedPassword | password the user will be asked for to connect               |                                           | yes
`privileges`      | Array                  |                                                              | `[:all]`                                  | no
`database_name`   | String                 |                                                              |                                           | no
`table`           | String                 |                                                              |                                           | no
`grant_option`    | true/false             |                                                              | `false`                                   | no
`require_ssl`     | true/false             |                                                              | `false`                                   | no
`require_x509`    | true/false             |                                                              | `false`                                   | no
`use_native_auth` | true/false             | if using MySQL >8, use `mysql_native_password` for auth      | `true`                                    | no

### `use_native_auth`

This property should be set to `false` if the user is local (host of `localhost`) to provide better security. The property still works for remote users but does not provide any idempotency guarantees. `use_native_auth` has no effect for percona <8.

## Examples

```ruby
# Create an user but grant no privileges
mysql_user 'disenfranchised' do
  password 'super_secret'
  action :create
end

# Create an user using a hashed password string instead of plain text one
mysql_user 'disenfranchised' do
  password hashed_password('md5eacdbf8d9847a76978bd515fae200a2a')
  action :create
end

# Drop a user
mysql_user 'foo_user' do
  action :drop
end

# Grant SELECT, UPDATE, and INSERT privileges to all tables in foo db from all hosts
mysql_user 'foo_user' do
  password 'super_secret'
  database_name 'foo'
  host '%'
  privileges [:select,:update,:insert]
  action :grant
end
```
