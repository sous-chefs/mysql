# mysql_client

Install a vendor client and development headers from repositories configured by the caller. Actions: `:create` (default), `:delete`.

`mysql_client_installation` and `mysql_client_installation_package` are aliases. `version` defaults to `8.4`; `major_version` remains derived. `package_name` defaults to `mysql-community-client` plus `libmysqlclient-dev` on Debian-family systems or `mysql-community-devel` elsewhere. Override package names where your repository differs. `package_version` and `package_options` pass through to the package provider.

`mysql_server_installation` and `mysql_server_installation_package` expose the same package properties for the server, with actions `:install` (default) and `:delete`. Their default package is `mysql-community-server`. Explicit package deletion affects every instance using that shared installation.
