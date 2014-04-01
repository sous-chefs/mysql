# Set the mysql_service name from a node attribtue so resources can
# have different names in ChefSpec.

mysql_service node['mysql']['service_name']
