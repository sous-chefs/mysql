---
description: Run all kitchen suites and fix failures iteratively
auto_execution_mode: 3
---

# Kitchen Test and Fix Workflow

This workflow runs all Test Kitchen suites, aggregates failures, and iteratively fixes common issues.

## Steps

### 1. Get Your Bearings

Run `kitchen list` to see all available test suites and their current state.

```bash
chef exec kitchen list
```

Review the output to understand:

- Which suites exist (installer-mysql, installer-postgresql, standalone-mysql, standalone-postgresql)
- Which platforms are configured
- Current state of any existing instances

### 2. Run Kitchen Tests

Run all kitchen tests in parallel with destroy on completion:

```bash
# Run a single suite first to validate
chef exec kitchen test installer-mysql-ubuntu-2404 --destroy=always

# Or run all tests (this takes a long time)
chef exec kitchen test --concurrency=4 --destroy=always
```

For faster iteration, test one platform per suite first:

```bash
chef exec kitchen test installer-mysql-ubuntu-2404 --destroy=always
chef exec kitchen test installer-postgresql-ubuntu-2404 --destroy=always
chef exec kitchen test standalone-mysql-ubuntu-2404 --destroy=always
chef exec kitchen test standalone-postgresql-ubuntu-2404 --destroy=always
```

### 3. Aggregate Failures

When tests fail, collect and categorize the errors:

1. **Converge failures** - Recipe compilation or resource execution errors
2. **Verify failures** - InSpec/Serverspec test failures
3. **Platform-specific failures** - Issues only on certain OS families

For each failure, note:

- Suite name
- Platform
- Error message
- Stack trace location

### 4. Apply Common Fixes

Address failures by category:

#### Converge Failures

- Check recipe syntax and resource availability
- Verify cookbook dependencies in `metadata.rb` and `Berksfile`
- Review attribute precedence issues
- Check for deprecated Chef APIs

#### Verify Failures

- Review test expectations in `test/integration/*/serverspec/`
- Ensure services are running and ports are listening
- Check file permissions and ownership

#### Platform-Specific Failures

- Add platform conditionals where needed
- Check package names differ between distros
- Verify service names (systemd vs init)

### 5. Iterate

After applying fixes:

// turbo
1. Re-run the failing tests:

```bash
chef exec kitchen test <suite-platform> --destroy=always
```

2. If new failures appear, return to step 3
3. Continue until all tests pass

### 6. Verify All Suites Pass

Once individual fixes are applied, run the full test matrix:

```bash
chef exec kitchen test --concurrency=4 --destroy=always
```

### 7. Cleanup

Destroy any remaining kitchen instances:

// turbo
```bash
chef exec kitchen destroy
```

## Common Issues Reference

| Error                 | Cause                           | Fix                             |
|-----------------------|---------------------------------|---------------------------------|
| `undefined method`    | Missing cookbook dependency     | Add to `metadata.rb` depends    |
| `package not found`   | Wrong package name for platform | Use platform conditionals       |
| `service not running` | Service failed to start         | Check logs, add retries         |
| `port not listening`  | App not configured correctly    | Review configuration templates  |
| `Chef::Platform.set`  | Deprecated API in dependency    | Update cookbook version or stub |
