# Troubleshooting Logs
***
## MongoDB SELinux Troubleshooting: FTDC Mount Point Alerts
Issue
Date: January 13, 2026

Environment: Fedora 43 / MongoDB Symptom: SELinux Alert Browser reports that the process ftdc was denied search access to the directory /var/lib/nfs.

Root Cause
MongoDB includes a feature called Full-Time Diagnostic Data Capture (FTDC). This background thread (ftdc) periodically scans all system mount points—including those for Network File Systems (NFS)—to collect hardware and disk performance metrics.

On Fedora, the default SELinux security policy for MongoDB is restrictive and prevents the database process from "peeking" into system directories like /var/lib/nfs, triggering the security alert.

Solution: Disable FTDC Diagnostic Collection
Since these diagnostic files are primarily used by MongoDB Inc. support engineers for deep-dive debugging and aren't required for standard database operations, the simplest fix is to disable the collection.

1. Edit the configuration file:
```bash
sudo nano /etc/mongod.conf
```
2. Add/Modify the `setParameter` section:
```YAML
setParameter:
  diagnosticDataCollectionEnabled: false
```
3. Restart the service:
```bash
sudo systemctl restart mongod
```
Impact & Trade-offs
Pros: Instantly stops the SELinux alerts; saves a negligible amount of CPU and disk I/O used by the diagnostic thread.

Cons: If you ever encounter a high-level performance bug and need to contact MongoDB support, you won't have the compressed diagnostic.data files they usually request for analysis.
***
