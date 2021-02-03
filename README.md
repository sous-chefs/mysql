
# MySQL Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/mysql.svg)](https://supermarket.chef.io/cookbooks/mysql)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/mysql/master.svg)](https://circleci.com/gh/sous-chefs/mysql)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

The MySQL Cookbook is a library cookbook that provides resource primitives (LWRPs) for use in recipes. It is designed to be a reference example for creating highly reusable cross-platform cookbooks.

## Scope

This cookbook is concerned with the "MySQL Community Server", particularly those shipped with F/OSS Unix and Linux distributions. It does not address forks or value-added repackaged MySQL distributions like MariaDB or Percona.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

- Chef 12.7 or higher
- Network accessible package repositories
- 'recipe[selinux::disabled]' on RHEL platforms

## Platform Support

The following platforms have been tested with Test Kitchen:

|  OS            | 5.6 | 5.7 | 8.0 |
|----------------|-----|-----|-----|
| centos-7       |  X  |  X  |  X  |
| centos-8       |     |  X  |  X  |
| debian-9       |     |  X  |     |
| debian-10      |     |     |  X  |
| fedora         |  X  |  X  |  X  |
| openSUSE Leap  |  X  |     |     |
| ubuntu-18.04   |     |  X  |     |
| ubuntu-20.04   |     |     |  X  |

## Cookbook Dependencies

There are no hard coupled dependencies. However, there is a loose dependency on `yum-mysql-community` for RHEL/CentOS platforms. As of the 8.0 version of this cookbook, configuration of the package repos is now the responsibility of the user.

## Usage

Place a dependency on the mysql cookbook in your cookbook's metadata.rb

```ruby
depends 'mysql'
```

Then, in a recipe:

```ruby
mysql_service 'foo' do
  port '3306'
  version '8.0'
  initial_root_password 'change me'
  action [:create, :start]
end
```

The service name on the OS is `mysql-foo`. You can manually start and stop it with `service mysql-foo start` and `service mysql-foo stop`.

If you use `default` as the name the service name will be `mysql` instead of `mysql-default`.

The configuration file is at `/etc/mysql-foo/my.cnf`. It contains the minimum options to get the service running. It looks like this.

```cnf
# Chef generated my.cnf for instance mysql-foo

[client]
default-character-set          = utf8
port                           = 3306
socket                         = /var/run/mysql-foo/mysqld.sock

[mysql]
default-character-set          = utf8

[mysqld]
user                           = mysql
pid-file                       = /var/run/mysql-foo/mysqld.pid
socket                         = /var/run/mysql-foo/mysqld.sock
port                           = 3306
datadir                        = /var/lib/mysql-foo
tmpdir                         = /tmp
log-error                      = /var/log/mysql-foo/error.log
!includedir /etc/mysql-foo/conf.d

[mysqld_safe]
socket                         = /var/run/mysql-foo/mysqld.sock
```

You can put extra configuration into the conf.d directory by using the `mysql_config` resource, like this:

```ruby
mysql_service 'foo' do
  port '3306'
  version '8.0'
  initial_root_password 'change me'
  action [:create, :start]
end

mysql_config 'foo' do
  source 'my_extra_settings.erb'
  instance 'foo'
  notifies :restart, 'mysql_service[foo]'
  action :create
end
```

You are responsible for providing `my_extra_settings.erb` in your own cookbook's templates folder. The name of the mysql service instance must be provided in mysql config as this defaults to 'default'.

## Connecting with the mysql CLI command

Logging into the machine and typing `mysql` with no extra arguments will fail. You need to explicitly connect over the socket with `mysql -S /var/run/mysql-foo/mysqld.sock`, or over the network with `mysql -h 127.0.0.1`

## Upgrading from older version of the mysql cookbook

- It is strongly recommended that you rebuild the machine from scratch. This is easy if you have your `data_dir` on a dedicated mount point. If you _must_ upgrade in-place, follow the instructions below.
- The 6.x series supports multiple service instances on a single machine. It dynamically names the support directories and service names. `/etc/mysql becomes /etc/mysql-instance_name`. Other support directories in `/var` `/run` etc work the same way. Make sure to specify the `data_dir` property on the `mysql_service` resource to point to the old `/var/lib/mysql` directory.

## Resources

- [`mysql_service`](https://github.com/sous-chefs/mysql/blob/master/documentation/resource_mysql_service.md)
- [`mysql_config`](https://github.com/sous-chefs/mysql/blob/master/documentation/resource_mysql_config.md)
- [`mysql_client`](https://github.com/sous-chefs/mysql/blob/master/documentation/resource_mysql_client.md)
- [`mysql_user`](https://github.com/sous-chefs/mysql/blob/master/documentation/resource_mysql_user.md)
- [`mysql_database`](https://github.com/sous-chefs/mysql/blob/master/documentation/resource_mysql_database.md)

## Advanced Usage Examples

There are a number of configuration scenarios supported by the use of resource primitives in recipes. For example, you might want to run multiple MySQL services, as different users, and mount block devices that contain pre-existing databases.

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
  action [:create, :start]
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
  action [:create, :start]
end

mysql_config 'site config for instance-2' do
  instance 'instance-2'
  source 'instance-2.cnf.erb'
  notifies :restart, 'mysql_service[instance-2]'
end
```

### Replication Testing

Use multiple `mysql_service` instances to test a replication setup. This particular example serves as a smoke test in Test Kitchen because it exercises different resources and requires service restarts.

<https://github.com/chef-cookbooks/mysql/blob/master/test/fixtures/cookbooks/mysql_replication_test/recipes/default.rb>

## Frequently Asked Questions

### How do I run this behind my firewall

On Linux, the `mysql_service` resource uses the platform's underlying package manager to install software. For this to work behind firewalls, you'll need to either:

- Configure the system yum/apt utilities to use a proxy server that
- can reach the Internet
- Host a package repository on a network that the machine can talk to

On the RHEL platform_family, applying the `yum::default` recipe will allow you to drive the `yum_globalconfig` resource with attributes to change the global yum proxy settings.

If hosting repository mirrors, applying one of the following recipes and adjust the settings with node attributes.

- `recipe[yum-centos::default]` from the Supermarket

  <https://supermarket.chef.io/cookbooks/yum-centos>

  <https://github.com/chef-cookbooks/yum-centos>

- `recipe[yum-mysql-community::default]` from the Supermarket

  <https://supermarket.chef.io/cookbooks/yum-mysql-community>

  <https://github.com/chef-cookbooks/yum-mysql-community>

### The mysql command line doesn't work

If you log into the machine and type `mysql`, you may see an error like this one:

`Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'`

This is because MySQL is hardcoded to read the defined default my.cnf file, typically at /etc/my.cnf, and this LWRP deletes it to prevent overlap among multiple MySQL configurations.

To connect to the socket from the command line, check the socket in the relevant my.cnf file and use something like this:

`mysql -S /var/run/mysql-foo/mysqld.sock -Pwhatever`

Or to connect over the network, use something like this: connect over the network..

`mysql -h 127.0.0.1 -Pwhatever`

These network or socket ssettings can also be put in you $HOME/.my.cnf, if preferred.

### What about MariaDB, Percona, etc

MySQL forks are purposefully out of scope for this cookbook. This is mostly to reduce the testing matrix to a manageable size. Cookbooks for these technologies can easily be created by copying and adapting this cookbook. However, there will be differences.

Package repository locations, package version names, software major version numbers, supported platform matrices, and the availability of software such as XtraDB and Galera are the main reasons that creating multiple cookbooks to make sense.

There are existing cookbooks to carter for these forks, check them out on the supermarket

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
