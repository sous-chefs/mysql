# Limitations

## Supported MySQL Versions

| Version | Track      | Status                       |
|---------|------------|------------------------------|
| 8.0     | LTS        | Maintenance (EOL April 2026) |
| 8.4     | LTS        | Current default              |
| 9.x     | Innovation | Rolling release              |

This cookbook targets MySQL Community Server packages from Oracle's official repositories.

## Package Availability

### APT (Debian/Ubuntu)

Packages provided via the [MySQL APT Repository](https://dev.mysql.com/downloads/repo/apt/) (`mysql-apt-config` deb).

| Distribution         | MySQL 8.0 | MySQL 8.4 | Architectures |
|----------------------|-----------|-----------|---------------|
| Ubuntu 20.04 (Focal) | Yes       | Yes       | amd64, arm64  |
| Ubuntu 22.04 (Jammy) | Yes       | Yes       | amd64, arm64  |
| Ubuntu 24.04 (Noble) | Yes       | Yes       | amd64, arm64  |
| Debian 12 (Bookworm) | Yes       | Yes       | amd64, arm64  |
| Debian 13 (Trixie)   | Yes       | Yes       | amd64, arm64  |

**Note:** Debian 12+ ships MariaDB as the default `mysql-client` / `mysql-server` packages.
Installing MySQL Community Server requires the MySQL APT repository or explicit
`mysql-community-server` packages.

### DNF/YUM (RHEL family)

Packages provided via the [MySQL Yum Repository](https://dev.mysql.com/downloads/repo/yum/) (`mysql84-community-release` RPM).

Platform codes: `el8`, `el9`, `el10`, `fc41`, `fc42`.

| Distribution      | MySQL 8.0 | MySQL 8.4 | Architectures   |
|-------------------|-----------|-----------|-----------------|
| AlmaLinux 8       | Yes       | Yes       | x86_64, aarch64 |
| AlmaLinux 9       | Yes       | Yes       | x86_64, aarch64 |
| AlmaLinux 10      | Yes       | Yes       | x86_64, aarch64 |
| Rocky Linux 8     | Yes       | Yes       | x86_64, aarch64 |
| Rocky Linux 9     | Yes       | Yes       | x86_64, aarch64 |
| Rocky Linux 10    | Yes       | Yes       | x86_64, aarch64 |
| Oracle Linux 8    | Yes       | Yes       | x86_64, aarch64 |
| Oracle Linux 9    | Yes       | Yes       | x86_64, aarch64 |
| CentOS Stream 9   | Yes       | Yes       | x86_64, aarch64 |
| CentOS Stream 10  | Yes       | Yes       | x86_64, aarch64 |
| RHEL 8            | Yes       | Yes       | x86_64, aarch64 |
| RHEL 9            | Yes       | Yes       | x86_64, aarch64 |
| Fedora (current)  | Yes       | Yes       | x86_64, aarch64 |
| Amazon Linux 2023 | Yes       | Yes       | x86_64, aarch64 |

**Note:** EL7 is no longer supported by this cookbook. MySQL 8.4 requires EL8+.

### Zypper (SUSE)

Packages provided via the [MySQL SUSE Repository](https://dev.mysql.com/downloads/repo/suse/) (`mysql84-community-release` RPM).

| Distribution     | MySQL 8.0 | MySQL 8.4 | Architectures |
|------------------|-----------|-----------|---------------|
| openSUSE Leap 15 | Yes       | Yes       | x86_64        |
| SLES 15          | Yes       | Yes       | x86_64        |

**Note:** aarch64 packages are not available for SUSE platforms.

## Architecture Limitations

- **x86_64 / amd64**: Available on all supported platforms
- **aarch64 / arm64**: Available on all APT and YUM platforms; **not available** on SUSE

## Service Management

This cookbook uses **systemd only**. All supported platforms use systemd as their init system.
SysVinit and Upstart are not supported.

## metadata.rb Cross-Reference

All platforms declared in `metadata.rb` are supported by Oracle's official MySQL repositories:

| metadata.rb `supports` | Vendor Support            | Notes                   |
|------------------------|---------------------------|-------------------------|
| `almalinux >= 8.0`     | Yes (el8, el9, el10)      |                         |
| `amazon >= 2023.0`     | Yes (el9-compatible)      |                         |
| `centos_stream >= 9.0` | Yes (el9, el10)           |                         |
| `debian >= 12.0`       | Yes (bookworm, trixie)    | Requires MySQL APT repo |
| `fedora`               | Yes (current releases)    |                         |
| `opensuseleap >= 15.0` | Yes (sl15)                | x86_64 only             |
| `oracle >= 8.0`        | Yes (el8, el9)            |                         |
| `redhat >= 8.0`        | Yes (el8, el9)            |                         |
| `rocky >= 8.0`         | Yes (el8, el9, el10)      |                         |
| `ubuntu >= 20.04`      | Yes (focal, jammy, noble) |                         |

## Definition of Done

A change to this cookbook is considered complete when **all** of the following pass:

1. **ChefSpec** — `chef exec rspec spec/` passes with 0 failures
2. **Cookstyle** — `chef exec cookstyle` reports 0 offenses
3. **Kitchen Test** — `kitchen test` completes successfully on **every** suite defined in `kitchen.yml`:
   - `default-almalinux-8`
   - `default-almalinux-9`
   - `default-almalinux-10`
   - `default-amazonlinux-2023`
   - `default-centos-stream-9`
   - `default-centos-stream-10`
   - `default-debian-12`
   - `default-debian-13`
   - `default-ubuntu-2204`
   - `default-ubuntu-2404`

All suites must converge and pass their InSpec verification controls.

## Known Issues

- Debian 12+ defaults to MariaDB; the `default-mysql-client` package installs MariaDB client
  libraries, which are compatible with MySQL server but may not support all MySQL-specific features
- MySQL 8.0 is in maintenance mode and will reach EOL in April 2026; new deployments should use 8.4
- The `mysql_native_password` authentication plugin is deprecated in MySQL 8.4; `caching_sha2_password`
  is the default
