# mysql_user

Manage an account and additive grants. Actions: `:create` (default), `:drop`, `:grant`, `:revoke`.

`username` defaults to the resource name; `host` defaults to `localhost` and identifies the account, not the control connection. Sensitive `password` can be a String, an explicit `MysqlCookbook::HashedPassword`, or unset to preserve an existing password. `use_native_auth` defaults to `false`, using the server's current authentication. Enable the legacy server plugin before explicitly selecting native authentication or a native password hash; MySQL 8.4 otherwise rejects it. No plugin is enabled silently.

`require_ssl` and `require_x509` default to false; X509 takes precedence. Existing TLS requirements are reconciled by `:create`. Password verification logs into the same server endpoint as the managed user, checks `CURRENT_USER()` and never logs credentials. Supply a connection endpoint and client TLS credentials that can authenticate that account; remote-only accounts or X509 accounts require matching connection settings.

Control properties are `ctrl_user` (`root`), sensitive `ctrl_password`, `ctrl_host` (`localhost`), `ctrl_port` (`3306`) and optional `ctrl_socket`. Optional TLS properties are `ssl_mode`, `ssl_ca`, `ssl_cert` and sensitive `ssl_key`. Set an explicit socket for named instances.

`database_name` and optional `table` select the grant scope; absent database means global scope. `privileges` defaults to `[:all]`. Static aliases such as `:create_tmp_table`, `:show_db`, `:repl_client` remain accepted; the server validates other static and dynamic privilege names. `grant_option` defaults to false and adds grant authority when true. Grants preserve unrelated privileges. Revoke removes only requested privileges currently present at that exact scope. Create the account before granting; grant does not create accounts or rotate passwords. Drop and revoke are idempotent when the account or grants are absent.
