# mysql\_config

The `mysql_config` resource is a wrapper around the core Chef `template` resource. Instead of a `path` parameter, it uses the `instance` parameter to calculate the path on the filesystem where file is rendered.

## Example

```ruby
mysql_config[default] do
  source 'site.cnf.erb'
  action :create
end
```

## Parameters

- `config_name` - The base name of the configuration file to be rendered into the conf.d directory on disk. Defaults to the resource name.
- `cookbook` - The name of the cookbook to look for the template source. Defaults to nil
- `group` - System group for file ownership. Defaults to 'mysql'.
- `instance` - Name of the `mysql_service` instance the config is meant for. Defaults to 'default'.
- `owner` - System user for file ownership. Defaults to 'mysql'.
- `source` - Template in cookbook to be rendered.
- `variables` - Variables to be passed to the underlying `template` resource.
- `version` - Version of the `mysql_service` instance the config is meant for. Used to calculate path. Only necessary when using packages with unique configuration paths, such as RHEL Software Collections or OmniOS. Defaults to 'nil'

## Actions

- `:create` - Renders the template to disk at a path calculated using the instance parameter.
- `:delete` - Deletes the file from the conf.d directory calculated using the instance parameter.

## More Examples

```ruby
mysql_service 'instance-1' do
  action [:create, :start]
end

mysql_service 'instance-2' do
  action [:create, :start]
end

mysql_config 'logging' do
  instance 'instance-1'
  source 'logging.cnf.erb'
  action :create
  notifies :restart, 'mysql_service[instance-1]'
end

mysql_config 'security settings for instance-2' do
  config_name 'security'
  instance 'instance-2'
  source 'security_stuff.cnf.erb'
  variables(:foo => 'bar')
  action :create
  notifies :restart, 'mysql_service[instance-2]'
end
```
