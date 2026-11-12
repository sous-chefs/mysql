# mysql_client_config

Preserves the client-options resource introduced in the existing migration PR. Actions: `:create` (default), `:delete`.

`config_name` defaults to the resource name. Required sensitive `options` is a hash of option groups and values, for example `'client' => { 'user' => 'application', 'socket' => '/run/mysql-application/mysqld.sock' }`. Values use MySQL options-file escaping, including quotes, backslashes and newlines. Invalid group or option names are rejected before writing.

`owner` and `group` default to `root`; `mode` now defaults to private `0600`. `include_dir` defaults to the selected instance's configuration include directory; `instance` defaults to `default`. Existing directory ownership is preserved to avoid conflicting with `mysql_service`. `version`, `major_version`, `run_user` and `run_group` remain shared compatibility properties.

Select the resulting `config_name.cnf` using the client's `--defaults-file` option. Root-owned private options files at the default include path work for root clients; MySQL 8.4 server restarts are tested with that default file present. Only client groups belong in such a file: the server cannot read root-private mysqld settings. For separate credential storage, set `include_dir '/root/mysql-clients'`. Set an explicit mode/group only when you intend to share access. Template diffs and the options property are sensitive.
