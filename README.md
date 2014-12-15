MySQL Cookbook
=====================

The Mysql Cookbook is a library cookbook that provides resource primitives
(LWRPs) for use in recipes. It is designed to be reference example for
creating highly reusable cross-platform cookbooks.

Scope
-----
This cookbook is concerned with the "MySQL Community Server",
particularly those shipped with F/OSS Unix and Linux distributions. It
does not address forks and value-added repackaged MySQL distributions
like Drizzle, MariaDB, or Percona.

Requirements
------------
- Chef 11 or higher
- Ruby 1.9 or higher (preferably from the Chef full-stack installer)
- Network accessible package repositories

Platform Support
----------------
The following platforms have been tested with Test Kitchen:

```
|---------------+-----+-----+-----+-----+-----|
|               | 5.0 | 5.1 | 5.5 | 5.6 | 5.7 |
|---------------+-----+-----+-----+-----+-----|
| debian-7      |     |     | X   |     |     |
|---------------+-----+-----+-----+-----+-----|
| ubuntu-10.04  |     | X   |     |     |     |
|---------------+-----+-----+-----+-----+-----|
| ubuntu-12.04  |     |     | X   |     |     |
|---------------+-----+-----+-----+-----+-----|
| ubuntu-14.04  |     |     | X   | X   |     |
|---------------+-----+-----+-----+-----+-----|
| centos-5      |   X | X   | X   | X   | X   |
|---------------+-----+-----+-----+-----+-----|
| centos-6      |     | X   | X   | X   | X   |
|---------------+-----+-----+-----+-----+-----|
| centos-7      |     |     | X   | X   | X   |
|---------------+-----+-----+-----+-----+-----|
| amazon        |     |     | X   | X   | X   |
|---------------+-----+-----+-----+-----+-----|
| fedora-20     |     |     | X   | X   | X   |
|---------------+-----+-----+-----+-----+-----|
| suse-11.3     |     |     | X   |     |     |
|---------------+-----+-----+-----+-----+-----|
| omnios-151006 |     |     | X   | X   |     |
|---------------+-----+-----+-----+-----+-----|
| suse-14.3.0   |     |     | X   | X   |     |
|---------------+-----+-----+-----+-----+-----|
```

Cookbook Dependencies
------------
- yum-mysql-community
- smf

Usage
-----
Place a dependency on the mysql cookbook in your cookbook's  metadata.rb
```ruby
depends 'mysql', '~> 6.0'
```

Then, in a recipe:

```ruby
mysql_service 'default' do
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  action [:create, :start]
end

mysql_config 'default' do
  source 'mysite.cnf.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end
```

Resources Overview
------------------
### mysql_service

The `mysql_service` resource manages the basic plumbing needed to get a
MySQL server instance running with minimal configuration.

The `:create` action handles package installation, support
directories, socket files, and other operating system level concerns.
The internal configuration file contains just enough to get the
service up and running, then loads extra configuration from a conf.d
directory. which should be managed by a `mysql_config` resource.

- If the `data_dir`, is empty, a database will be initialized, and a
root user will be set up with `initial_root_password`. If the
directory already contains database files, no action will be taken.

The `:start` action starts the service on the machine, using the
appropriate provider for the platform. The `:create` action should be
omitted when used in recipes designed to build containers.

#### Example
```ruby
mysql_service 'default' do
  version '5.7'
  port '3306'
  data_dir '/data'
  initial_root_password 'Ch4ng3me'
  action [:create, :start]
end
```

Please note that when using `notifies` or `subscribes`, the resource
to reference is `mysql_service[name]`, not `service[mysql]`.

#### Parameters

- `charset` - specifies the default character set. Defaults to `utf8`.

- `data_dir` -determines where the actual data files are kept
on the machine. This is useful when mounting external storage. When
omitted, it will default to the platform's native location.

- `initial_root_password` - allows the user to specify the initial
  root password for the mysql database initializing new databases.
  This can be set explicitly in a recipe, driven from a node
  attribute, or from data_bags. When omitted, it defaults to
  `ilikerandompasswords`. Please be sure to change it.

- `instance` - A string to identify the MySQL service. By convention,
  to allow for multiple instances of the `mysql_service`, directories
  and files on disk are named "mysql-<instance>". Defaults to the
  resource name.

- `package_action` - Defaults to `:install`.

- `package_name` - Defaults to a value looked up in an internal map.

- `package_version` - Specific version of the package to install,
  passed onto the underlying package manager. Defaults to `nil`.

- `port` - determines the listen port for the mysqld service. When
  omitted, it will default to '3306'.

- `run_group` - The name of the system group the `mysql_service`
  should run as. Defaults to 'mysql'.

- `run_user` - The name of the system user the `mysql_service` should
  run as. Defaults to 'mysql'.

- `version` - allows the user to select from the versions available
  for the platform, where applicable. When omitted, it will install
  the default MySQL version for the target platform. Available version
  numbers are `5.0`, `5.1`, `5.5`, `5.6`, and `5.7`, depending on platform.

#### Actions

- `:create` - Configures everything but the underlying operating system service.
- `:delete` - Removes everything but the package and data_dir.
- `:start` - Starts the underlying operating system service
- `:stop`-  Stops the underlying operating system service
- `:restart` - Restarts the underlying operating system service
- `:reload` - Reloads the underlying operating system service

#### Providers
Chef selects the appropriate provider based on platform and version,
but you can specify one if your platform support it.

```ruby
mysql_service[instance-1] do
  port '1234'
  data_dir '/mnt/lottadisk'
  provider Chef::Provider::MysqlService::Sysvinit
  action [:create, :start]
end
```

- `Chef::Provider::MysqlService` - Configures everything needed t run
a MySQL service except the platform service facility. This provider
should never be used directly. The `:start`, `:stop`, `:restart`, and
`:reload` actions are stubs meant to be overridden by the providers
below.

- `Chef::Provider::MysqlService::Smf` - Starts a `mysql_service` using
the Service Management Facility, used by Solaris and IllumOS. Manages
the FMRI and method script.

- `Chef::Provider::MysqlService::Systemd` - Starts a `mysql_service`
using SystemD. Manages the unit file and activation state

- `Chef::Provider::MysqlService::Sysvinit` - Starts a `mysql_service`
using SysVinit. Manages the init script and status.

- `Chef::Provider::MysqlService::Upstart` - Starts a `mysql_service`
using Upstart. Manages job definitions and status.

### mysql_config

The `mysql_config` resource is a wrapper around the core Chef
`template` resource. Instead of a `path` parameter, it uses the
`instance` parameter to calculate the path on the filesystem where
file is rendered.

#### Example

```ruby
mysql_config[default] do
  source 'site.cnf.erb'
  action :create
end
```

#### Parameters

- `config_name` - The base name of the configuration file to be
  rendered into the conf.d directory on disk. Defaults to the resource
  name.

- `cookbook` - The name of the cookbook to look for the template
  source. Defaults to nil

- `group` - System group for file ownership. Defaults to 'mysql'.

- `instance` - Name of the `mysql_service` instance the config is
  meant for. Defaults to 'default'.

- `owner` - System user for file ownership. Defaults to 'mysql'.

- `source` - Template in cookbook to be rendered.

- `variables` - Variables to be passed to the underlying `template`
  resource.

- `version` - Version of the `mysql_service` instance the config is
  meant for. Used to calculate path. Only necessary when using
  packages with unique configuration paths, such as RHEL Software
  Collections, or OmniOS. Defaults to 'nil'

#### Actions
- `:create` - Renders the template do disk at a path calculated using
  the instance parameter.
  
- `:delete` - Deletes the file from the conf.d directory calculates
  using the instance parameter.

#### More Examples
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

### mysql_client
The `mysql_client` resource manages the MySQL client binaries and
development libraries. 

It is an example of a "singleton" resource. Declaring two
`mysql_client` resources on a machine usually won't yield two separate
copies of the client binaries, except for platforms that support
multiple versions (RHEL SCL, Omnios).

#### Example
```ruby
mysql_client 'default' do
  action :create
end
```

#### Parameters
- `package_name` - An array of packages to be installed. Defaults to a
  value looked up in an internal map.  

- `package_version` - Specific versions of the package to install,
  passed onto the underlying package manager. Defaults to `nil`.

- `version` - Major MySQL version number of client packages. Only
  valid on for platforms that support multiple versions, such as RHEL
  via Software Collections and Ominos.
  
#### Actions
- `:create` - Installs the client software
- `:delete` - Removes the client software

Advanced Usage Examples
-----------------------
There are a large number of configuration scenarios supported by the
use of resource primitives in recipes. For example, you might want to
run multiple instances of MySQL server, as different system users,
and mount block devices that contain pre-existing database.

### Multiple Instances as Different Users

```ruby
# instance-1
user 'alice' do
  action :create
end

directory '/mnt/data/mysql/instance-1' do
  owner 'alice'
  action :create
end

mount '/mnt/data/mysql/instance-1' do
  device '/dev/sdb1'
  fstype 'ext4'
  action [:mount, :enable]
end

mysql_service 'instance-1' do
  port '3307'
  run_user 'alice'
  data_dir '/mnt/data/mysql/instance-1'
  action [:create,:start]
end

mysql_config 'site config for instance-1' do
  instance 'instance-1'
  source 'instance-1.cnf.erb'
  notifies :restart, 'mysql_service[instance-1]'
end

# instance-2
user 'bob' do
  action :create
end

directory '/mnt/data/mysql/instance-2' do
  owner 'bob'
  action :create
end

mount '/mnt/data/mysql/instance-2' do
  device '/dev/sdc1'
  fstype 'ext3'
  action [:mount, :enable]
end

mysql_service 'instance-2' do
  port '3308'
  run_user 'bob'
  data_dir '/mnt/data/mysql/instance-2'
  action [:create,:start]
end

mysql_config 'site config for instance-2' do
  instance 'instance-2'
  source 'instance-2.cnf.erb'
  notifies :restart, 'mysql_service[instance-2]'
end
```

### Replication Testing
Use multiple `mysql_service` instances to test a replication setup.
This particular example services as a smoke test in Test Kitchen,
because it exercises different resources and requires service restarts.

https://github.com/someara/mysql/blob/9a588e25166ca411d6ba1777b1435ea6cd115913/test/fixtures/cookbooks/mysql_replication_test/recipes/default.rb

Frequently Asked Questions
--------------------------

### How do I run this behind my firewall?

On Linux, the `mysql_service` resource uses the platform's underlying
package manager to install software. For this to work behind
firewalls, you'll need to either.

- Configure the system yum/apt utilities to use a proxy server that
  can reach the Internet.
- Host a package repository locally that the machine can talk to.

On the RHEL platform_family, applying the 'yum::default' recipe will
allow you to drive the `yum_globalconfig` to change global proxy
settings.

If hosting individual repository mirrors, applying one of the
following recipes and adjusting the settings with node attributes is
recommended.

- 'recipe[yum-centos::default]' from the Supermarket
  https://supermarket.chef.io/cookbooks/yum-centos
  https://github.com/opscode-cookbooks/yum-centos
  
- 'recipe[yum-mysql-community::default]' from the Supermarket
  https://supermarket.chef.io/cookbooks/yum-mysql-community
  https://github.com/opscode-cookbooks/yum-mysql-community
  
### What about MariaDB, Percona, Drizzle, WebScaleSQL, etc.

MySQL forks are purposefully out of scope for this cookbook. This is
mostly to reduce the size of the testing matrix to something manageable.
Cookbooks for those technologies can easily be created by copying and
adapting this cookbook, but there will be differences.

Package repository locations, package version names, software major
version numbers, supported platform matrix, and the availability of
extra software such as XtraDB and Galera are the main factors that
would cause separate cookbooks to make sense.

Hacking / Testing / TODO
-------------------------
Please refer to the HACKING.md

License & Authors
-----------------
- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: AJ Christensen (<aj@opscode.com>)
- Author:: Seth Chisamore (<schisamo@opscode.com>)
- Author:: Brian Bianco (<brian.bianco@gmail.com>)
- Author:: Jesse Howarth (<him@jessehowarth.com>)
- Author:: Andrew Crump (<andrew@kotirisoftware.com>)
- Author:: Christoph Hartmann (<chris@lollyrock.com>)
- Author:: Sean OMeara (<sean@chef.io>)

```text
Copyright:: 2009-2014 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
