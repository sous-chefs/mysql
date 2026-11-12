# mysql_database

Create or alter a schema's character set and collation, drop it, or run explicit SQL. Actions: `:create` (default), `:drop`, `:query`.

`database_name` defaults to the resource name. `encoding` defaults to `utf8`, and `collation` to `utf8_general_ci`; MySQL's `utf8mb3` aliases are normalised for idempotency. Prefer explicitly selecting `utf8mb4` for new applications. Existing contents are not converted by changing the schema defaults.

Connection properties are `host` (`localhost`), `port` (`3306`), `user` (`root`), sensitive `password`, and optional `socket`. Without a socket, the vendor client's normal host/socket selection applies. Set `socket` explicitly for named instances. Optional TLS properties are `ssl_mode`, `ssl_ca`, `ssl_cert`, sensitive `ssl_key`. `instance` remains a compatibility property; it does not replace an explicit connection endpoint.

Create/drop compare structured server metadata. Identifiers and SQL literals are quoted independently. `sql` is sensitive and required for `:query`; it executes unchanged on every converge. Add an application-specific guard when appropriate. SQL errors report an error number without exposing the query or credentials.
