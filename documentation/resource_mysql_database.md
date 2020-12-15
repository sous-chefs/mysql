# mysql\_database

Manage MySQL databases and execute SQL queries on them. It works by establishing a control connection to the MySQL server using the MySQL client (be sure it is installed before using this resource).

## Actions

- create - (default) to create a named database
- drop - to drop a named database
- query - to execute a SQL query

## Properties

Name              | Types             | Description                                                  | Default                                   | Required?
----------------- | ----------------- | ------------------------------------------------------------ | ----------------------------------------- | ---------
`user`            | String            | the username of the control connection                       | `root`                                    | no
`password`        | String            | password of the user used to connect to                      |                                           | no
`host`            | String            | host to connect to                                           | `localhost`                               | no
`port`            | String            | port of the host to connect to                               | `3306`                                    | no
`database_name`   | String            | the name of the database to manage                           | `name` if not specified                   | no
`encoding`        | String            |                                                              | `utf8`                                    | no
`collation`       | String            |                                                              | `utf8_general_ci`                         | no
`sql`             | String            | the SQL query to execute                                     |                                           | no

When `host` has the value `localhost`, it will try to connect using a Unix socket, or TCP/IP if no socket is defined.

### Examples

```ruby
# Create a database
mysql_database 'wordpress-cust01' do
  host '127.0.0.1'
  user 'root'
  password node['wordpress-cust01']['mysql']['initial_root_password']
  action :create
end

# Drop a database
mysql_database 'baz' do
  action :drop
end

# Query a database
mysql_database 'flush the privileges' do
  sql 'flush privileges'
  action :query
end
```

**The `query` action will NOT select a database before running the query, nor return the actual results from the SQL query.**
