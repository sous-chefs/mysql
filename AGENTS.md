# MySQL cookbook migration

## Confirmed scope

* Owner confirmed Full Migration for release PR #754 on 2026-11-12. Replace the Chef resource
  class hierarchy with flat custom resources, preserve documented resource names and useful
  properties, and deliver a breaking feature against main before Release Please generates
  the next major release. Do not merge the existing 11.2.0 release as the breaking migration.
* MySQL 8.4 is the new default. Require an explicit sensitive root bootstrap password.
  Use current server authentication by default; native authentication and HashedPassword
  compatibility must be explicit. Do not enable a legacy authentication plugin silently.
* Preserve data and shared accounts/packages when deleting an instance. SQL database/user drop
  actions remain explicit destructive operations. No automatic database-engine upgrade is part
  of this cookbook migration.
* Reuse existing user-authored migration PR #739 instead of creating a duplicate. Preserve its
  three commits using a normal merge, retain its mysql_client_config API, and reconcile its old
  implementation to the tested migration and current main. Keep #721 unchanged. Original #739
  integration jobs failed in March 2026; the stale LIMITATIONS vendor matrix is not authoritative.
  Client options now default to private mode 0600 and escape values rather than exposing secrets.

## Existing behaviour and defects

* Root recipes and attributes are already absent. The migration concerns resource classes in
  libraries and their shared helpers, not removing working public recipes.
* README advertises 8.0/8.4, but helpers still default to 5.6/5.7 or nil on current platforms.
  CI and Kitchen also drift and retain obsolete server/OS versions.
* The old SQL helper exposes credentials in process arguments/debug logs and interpolates SQL
  into shell commands. Replace that transport; do not preserve its unsafe logging or quoting.
* The old systemd manager has no delete action and ignores configured service users/groups.
  Keep multi-instance paths, socket/port separation and custom package/config inputs.

## Package and platform constraints

* Repository configuration remains caller-owned, as documented by the existing cookbook.
  Oracle MySQL packages are required; do not silently substitute MariaDB or Percona servers.
* Preserve declared platform families and Ubuntu 20.04 ESM where feasible. Retire obsolete test
  versions rather than deleting their supported newer families.
* Oracle's platform matrix includes both x86_64 and arm64 on supported RHEL-family releases.
  Debian/Ubuntu Oracle APT packages have narrower architecture support; record actual test
  coverage rather than claiming all package combinations work.
* MySQL 8.0 entered Oracle Sustaining Support in April 2026. Keep explicit 8.0 compatibility
  where practical, but target 8.4 for the new default and primary integration evidence.
* MySQL 8.4 disables mysql_native_password by default. Explicit legacy credentials require an
  explicitly enabled server plugin; the cookbook must not weaken server authentication.

## Implementation and verification notes

* Flat unified resources retain client/config/service/database/user names and installation aliases.
  SQL uses vendor-client argument arrays, private temporary options files and XML metadata rows.
  Binary authentication hashes are selected as HEX to avoid invalid XML control characters.
* Independent review found and corrected stale PID recovery, symlinked data containment on delete,
  package-array input mismatch and bootstrap-marker symlink trust. Recovery state now lives under
  root-owned mode-0700 `/var/lib/chef/mysql-bootstrap`, records the canonical data directory and
  server series, and rejects unexpected links, ownership, modes or mismatched state. Bootstrap
  daemon processes run as the configured service user; no PID-based killing is used.
* Preserve every metadata platform family. Kitchen/CI defaults exercise all retained newer Linux
  versions with checksum-pinned Oracle binaries; separate package suites exercise Oracle repositories
  on Ubuntu 24.04 and AlmaLinux 9. Ubuntu 20.04 ESM remains in the matrix. RHEL remains declared;
  its compatible AlmaLinux/Oracle Linux families are exercised without claiming a licensed RHEL run.
* Initial local evidence: Cookstyle and Markdown clean; actual MySQL 8.4.13 SQL tests cover special
  credentials, quoting, create/grant/revoke/drop, current authentication, password repair and second
  converge idempotency, including dynamic global privileges and grant options. Ubuntu 24.04 generic
  binary and AlmaLinux 9 Oracle RPM suites each completed two converges with no changes on the second.
  Expanded custom-user/multi-instance bootstrap also passed on both, with zero changes on the second
  converge (Ubuntu 0/58; AlmaLinux 0/59 after retaining client configuration). The explicit secondary
  root password includes a newline. Both complete fixtures passed 29 InSpec assertions each, including
  an actual vendor-client login through the retained private mysql_client_config output.
* Local x86 containers cannot execute on this Docker configuration (`exec format error`). Native
  arm64 binaries/packages provide local lifecycle evidence; hosted x86 matrix results remain distinct.

## Primary references

* [Oracle supported platforms](https://www.mysql.com/support/supportedplatforms/database.html)
* [MySQL lifecycle notices](https://www.mysql.com/support/eol-notice.html)
* [MySQL 8.4 native authentication](https://dev.mysql.com/doc/refman/8.4/en/native-pluggable-authentication.html)
