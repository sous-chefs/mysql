# Integration fixtures

`default` provisions a real MySQL 8.4 instance, current-auth account, database, scoped privileges and configuration. `binary` installs checksum-pinned Oracle binaries for broad platform lifecycle coverage. `repository` selects Oracle packages for the package suite. Credentials are public test fixtures, stored in private files for verifier connections; do not reuse them.

`sql` supports optional real-server ChefSpec checks. It manages only the random names supplied by the isolated test runner. Never target a production server.
