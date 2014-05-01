mysql Cookbook
==============

Installs and configures MySQL client or server.

Requirements
------------
Chef 0.11.0+.

Platform
--------
- Debian, Ubuntu
- CentOS, Red Hat

Tested on:

- Ubuntu 12.04
- CentOS 6.4

See TESTING.md for information about running tests in Opscode's Test Kitchen.


Cookbooks
---------
Requires Opscode's openssl cookbook for secure password generation. See _Attributes_ and _Usage_ for more information.

The RubyGem installation in the `rackspace_mysql::ruby` recipe requires a C compiler and Ruby development headers to be installed in order to build the mysql gem.


Resources and Providers
-----------------------
The LWRP that used to ship as part of this cookbook has been refactored into the
[database](http://community.opscode.com/cookbooks/database) cookbook. Please see the README for details on updated usage.


Attributes
----------
See the `attributes/server.rb` or `attributes/client.rb` for default values. Several attributes have values that vary based on the node's platform and version.
See attributes/server_[OS].rb for OS specific variations.


The following common variables are used for the server install:

| Variable | Node Path | Use |
| -------- | --------- | --- |
| Data Directory | ['rackspace_mysql']['data_dir'] | Sets the data directory path for MySQL |
| Package List | ['rackspace_mysql']['server']['packages'] | List of packages to install to provide the server |
| Run Directory | ['rackspace_mysql']['server']['directories']['run_dir'] | Run directory Path |
| Log Directory |['rackspace_mysql']['server']['directories']['log_dir']  | Log Directory Path |
| Extra Configuration Directory | ['rackspace_mysql']['server']['directories']['confd_dir'] | Directory containing additional configuration files |
| MySQLAdmin Path | ['rackspace_mysql']['server']['mysqladmin_bin'] | Path to the mysqladmin binary |
| MySQL binary path | ['rackspace_mysql']['server']['mysql_bin']    | Path to the mysql binary |

The options for my.cnf are to numerous to list here, however, a standard hash format is used.
For the my.cnf template this cookbook uses a config hash methodology per [rackspace-cookbooks/contributing](https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md).
The config has is broken up into blocks for each section of the my.cnf config to allow easy adding of extra options by calling recipes.
The general layout is `node['rackspace_mysql']['config'][block][option] = ConfigInnerHash`
Where:
* option is the option name, i.e. 'port'
* block corresponds to the my.cnf block the option goes in, i.e. 'mysqld'
* The inner hash is the standard inner hash format as documented in rackspace-cookbooks/contributing with the following deviations:
   * key: 'bool_flag': Sets that this option is a flag in the config, and the key should be added without a value.
* The ['includes'] section is an exception as in controls the !includes block at the bottom of the file, see my.cnf.erb.

Be warned that the use of - and _ is inconsistent across names!
This is upstream inconsistency coming through, see the comments in the attributes and template files for documentation links.

Many standard options are explicitly added to my.cnf for grouping and commenting.
However, any options added to the hash which are not known to the cookbook will automatically be added to the end of the config block.
It is not necessary to edit this cookbook to add options.
See my.cnf.erb for the options currently explicitly added to the template.

By default, a MySQL installation has an anonymous user, allowing anyone to log into MySQL without having to have a user account created for them.  This is intended only for testing, and to make the installation go a bit smoother.  You should remove them before moving into a production environment.

* `node['rackspace_mysql']['remove_anonymous_users']` - Remove anonymous users

Normally, root should only be allowed to connect from 'localhost'.  This ensures that someone cannot guess at the root password from the network.

* `node['rackspace_mysql']['allow_remote_root']` - If true Sets root access from '%'. If false deletes any non-localhost root users.

By default, MySQL comes with a database named 'test' that anyone can access.  This is also intended only for testing, and should be removed before moving into a production environment. This will also drop any user privileges to the test database and any DB named test_% .

* `node['rackspace_mysql']['remove_test_database']` - Delete the test database and access to it.

The following attributes are randomly generated passwords handled in the `rackspace_mysql::server` recipe, using the OpenSSL cookbook's `secure_password` helper method. These are set using the `set_unless` node attribute method, which allows them to be easily overridden e.g.
in a role.

* `node['rackspace_mysql']['server_root_password']` - Set the server's root
  password
* `node['rackspace_mysql']['server_repl_password']` - Set the replication user
  'repl' password
* `node['rackspace_mysql']['server_debian_password']` - Set the debian-sys-maint
  user password

You can drop off a /root/.my.cnf file containing a [mysql] and [client] config containing user and password fields. The attributes to do so are:

* `node['rackspace_mysql']['install_root_my_cnf']` - Create the /root/.my.cnf file. Defaults to false.
* `node['rackspace_mysql']['config']['user_mycnf']['user']` - Sets the user for the /root/.my.cnf file.
* `node['rackspace_mysql']['config']['user_mycnf']['pass']` - Sets the password for the /root/.my.cnf file.
* `node['rackspace_mysql']['templates']['user_mycnf']` - Sets the cookbook that the template is pulled from. Defaults to rackspace_mysql.

Usage
-----
On client nodes, use the client (or default) recipe:

```javascript
{ "run_list": ["recipe[rackspace_mysql::client]"] }
```

This will install the MySQL client libraries and development headers on the system.

On nodes which may use the `database` cookbook's mysql resources, also use the ruby recipe. This installs the mysql RubyGem in the Ruby environment Chef is using via `chef_gem`.

```javascript
{ "run_list": ["recipe[rackspace_mysql::client]", "recipe[rackspace_mysql::ruby]"] }
```

If you need to install the mysql Ruby library as a package for your system, override the client packages attribute in your node or role. For example, on an Ubuntu system:

```javascript
{
  "rackspace_mysql": {
    "client": {
      "packages": ["mysql-client", "libmysqlclient-dev","ruby-mysql"]
    }
  }
}
```

This creates a resource object for the package and does the installation before other recipes are parsed. You'll need to have the C compiler and such (ie, build-essential on Ubuntu) before running the recipes, but we already do that when installing Chef :-).

On server nodes, use the server recipe:

```javascript
{ "run_list": ["recipe[rackspace_mysql::server]"] }
```

On Debian and Ubuntu, this will preseed the mysql-server package with the randomly generated root password in the recipe file. On other platforms, it simply installs the required packages. It will also create an SQL file, `/etc/mysql/grants.sql`, that will be used to set up grants for the root, repl and debian-sys-maint users.

The recipe will perform a `node.save` unless it is run under `chef-solo` after the password attributes are used to ensure that in the event of a failed run, the saved attributes would be used.

The client recipe is already included by server and 'default' recipes.

For more information on the compile vs execution phase of a Chef run:

- http://wiki.opscode.com/display/chef/Anatomy+of+a+Chef+Run


Chef Solo Note
--------------
These node attributes are stored on the Chef server when using `chef-client`. Because `chef-solo` does not connect to a server or save the node object at all, to have the same passwords persist across `chef-solo` runs, you must specify them in the `json_attribs` file used. For example from a Vagrantfile:

```javascript
config.vm.provision :chef_solo do |chef|
    chef.json = {
      :rackspace_mysql => {
        :server_debian_password => 'TestDebianPassword',
        :server_root_password => 'TestRootPassword',
        :server_repl_password => 'TestReplicationPassword',
      }
    }

    chef.run_list = [
                     "recipe[rackspace_mysql::server]",
                     "recipe[rackspace_mysql::client]",
                    ]
  end
```


License & Authors
-----------------
- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: AJ Christensen (<aj@opscode.com>)
- Author:: Seth Chisamore (<schisamo@opscode.com>)
- Author:: Brian Bianco (<brian.bianco@gmail.com>)
- Author:: Jesse Howarth (<him@jessehowarth.com>)
- Author:: Andrew Crump (<andrew@kotirisoftware.com>)
- Author:: Christoph Hartmann (<chris@lollyrock.com>)
- Author:: Sean OMeara (<someara@opscode.com>)
- Author:: Matthew Thode (<matt.thode@rackspace.com>)
- Author:: Tom Noonan II (<thomas.noonan@rackspace.com>)

```text
Copyright:: 2009-2013 Opscode, Inc
Copyright:: 2014 Rackspace, US Inc.

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
