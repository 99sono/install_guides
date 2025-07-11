# Issue 14871: Plugin Warning After Docker Data Folder Relocation

**GitHub Issue:** https://github.com/docker/for-win/issues/14871

## Summary

After moving Docker Desktop's data folder from the C: drive to the D: drive using the official Docker Desktop UI, a persistent warning appears when running `docker info` inside WSL2 Ubuntu:

```
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-dev" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-dev: no such file or directory
```

- The referenced plugin does not exist and was never manually installed.
- Docker otherwise works as expected.
- The warning started only after the data folder migration.

This issue tracks the investigation and any developments or fixes related to this warning after Docker Desktop data folder relocation.
