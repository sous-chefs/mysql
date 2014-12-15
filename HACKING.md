ChefDK
------
This cookbook was created with the ChefDK, available here:
https://downloads.chef.io/chef-dk/

Adding platform support
-----------------------------
- Add the platform `platforms` section in .kitchen.yml or .kitchen.cloud.yml
- Add the platform to the `includes` attributes in the `suites`
  section of .kitchen.yml or .kitchen.cloud.yml  
- Make sure the platform shows up when doing `kitchen list`
- Run a `kitchen converge <platform_name>` and watch it fail
- Edit cookbook until it passes ServerSpec
- Add ChefSpec coverage in spec/

TODO
----
Refactor the gigantic Monster Mash in helpers.rb into something more
sensible. Perhaps use value_for_platform.
