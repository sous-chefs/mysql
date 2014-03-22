# from inspecting platform package managers
|-----------------+------------------------+------------------+------------|
| distro          | package name           | software version | repository |
|-----------------+------------------------+------------------+------------|
| centos-5.x      | mysql-server           |           5.0.95 | base       |
|-----------------+------------------------+------------------+------------|
| centos-5.x      | mysql51-mysql-server   |           5.1.70 | base       |
|-----------------+------------------------+------------------+------------|
| centos-5.x      | mysql55-mysql-server   |           5.5.36 | base       |
|-----------------+------------------------+------------------+------------|
| centos-6.x      | mysql-server           |           5.1.73 | base
|-----------------+------------------------+------------------+------------|
| amazon-2013.09  | mysql-server           |           5.1.73 | base       |
|-----------------+------------------------+------------------+------------|
| fedora-19       | community-mysql-server |           5.5.35 | base       |
|-----------------+------------------------+------------------+------------|
| debian-7.x      | mysql-server-5.5       |           5.5.33 | main       |
|-----------------+------------------------+------------------+------------|
| ubuntu-10.04    | mysql-server-5.1       |           5.1.41 | main       |
|-----------------+------------------------+------------------+------------|
| ubuntu-12.04    | mysql-server-5.5       |           5.5.22 | main       |
|-----------------+------------------------+------------------+------------|
| ubuntu-13.10    | mysql-server-5.5       |           5.5.32 | main       |
|-----------------+------------------------+------------------+------------|
| smartos-1303    | mysql-server-5.5       |           5.5.33 | 2013Q3     |
|-----------------+------------------------+------------------+------------|
| smartos-1303    | mysql-server-5.6       |           5.6.13 | 2013Q3     |
|-----------------+------------------------+------------------+------------|
| omnios-151006   | mysql-55               |           5.5.31 | omniti-ms  |
|-----------------+------------------------+------------------+------------|
| omnios-151006   | mysql-65               |           5.6.13 | omniti-ms  |
|-----------------+------------------------+------------------+------------|

# ohai 6.20.0 output
|---------+---------+---------|
| centos  | rhel    |     5.8 |
|---------+---------+---------|
| centos  | rhel    |     6.4 |
|---------+---------+---------|
| amazon  | rhel    | 2013.09 |
|---------+---------+---------|
| fedora  | fedora  |      19 |
|---------+---------+---------|
| debian  | debian  |     7.2 |
|---------+---------+---------|
| ubuntu  | debian  |   10.04 |
|---------+---------+---------|
| smartos | smartos |    5.11 |
|---------+---------+---------|
| omnios  | omnios  |  151006 |
|---------+---------+---------|


@version = default_version_for_(platform_family,platform_version)
@package_name = package_name_for(platform_family,platform_version,@version)
@data_dir = default_data_dir(platform_family)

an_boolean = validate_version(platform_family,platform_version,desired_version)

# 
wat(platform_family, key_for(platform_family,platform_version), mysql_version)

# do **NOT** access node['mysql']['version'] from the resource_mysql_service!

# version function ref
5.0 = version('rhel','5.x','5.0')
5.1 = version('rhel','5.x','5.1')
5.5 = version('rhel','5.x','5.5')
nil = version('rhel','5.x','5.6')
nil = version('rhel','6.x','5.0')
5.1 = version('rhel','6.x','5.1')
nil = version('rhel','6.x','5.5')
nil = version('rhel','6.x','5.6')
nil = version('fedora','19','5.0')
nil = version('fedora','19','5.1')
5.5 = version('fedora','19','5.5')
nil = version('fedora','19','5.6')
nil = version('debian','7.x','5.0')
nil = version('debian','7.x','5.1')
5.5 = version('debian','7.x','5.5')
nil = version('debian','7.x','5.6')
nil = version('ubuntu','10.04','5.0')
nil = version('ubuntu','12.04','5.1')
5.5 = version('ubuntu','13.10','5.5')
nil = version('ubuntu','13.10','5.6')
nil = version('smartos','5.11','5.0')
nil = version('smartos','5.11','5.1')
5.5 = version('smartos','5.11','5.5')
nil = version('smartos','5.11','5.6')
nil = version('omnios','151006','5.0')
nil = version('omnios','151006','5.1')
5.5 = version('omnios','151006','5.5')
5.6 = version('omnios','151006','5.6')

