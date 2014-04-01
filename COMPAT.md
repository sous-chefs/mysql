Backwards Compatibility
=======================

The Past
--------
In previous versions of this cookbook, the main my.cnf.erb template
was driven by values in the node['mysql']['tunable'] attribute space.
These attributes were mainly responsible for configuring values found
in the "Server System Variables" section of the MySQL reference
manual, found here:

    https://dev.mysql.com/doc/refman/5.1/en/server-system-variables.html
    https://dev.mysql.com/doc/refman/5.5/en/server-system-variables.html
    https://dev.mysql.com/doc/refman/5.6/en/server-system-variables.html
    
Of the close to 600 variables available, only around 150 were present
in the template. These seemed to be chosen rather arbitrarily, and
were the source of most of the tickets found in the issue tracker.
Worse, they simply did not work for most people running this cookbook.

The Present
-----------
Rather than try and encompass every configuration option available,
this cookbook focuses supplying cross platform service primitives, and
lets the user supply the configuration. 

Limited backwards compatibility has been added to aide the transition.
The old template is available at
`templates/default/deprecated/my.cnf.erb`, and a recipe has been
supplied that consumes it. Please use `mysql::server_deprecated` for
the old behavior.

The `mysql::ruby` recipe has been moved into its own cookbook. Please
use `mysql-chef_gem`.

The Future
----------
In future versions of this cookbook, a deprecation warning will be
printed via a log resource. In versions after that, the old style
template and recipe will be removed.
