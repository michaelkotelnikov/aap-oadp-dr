# AAP OADP DR

This repository demonstrates a backup and restore flow for Ansible Automation Platform (AAP) between two OpenShift clusters by using OpenShift Application Data Protection (OADP).

Inspired by - https://github.com/IdanHenik/RH-Disaster-Recovery-Workshop

## Setting up S3 with Minio

On your primary cluster -

1. Create a namespace for Minio

```
$ oc new-project oadp-minio
```

2. Apply all Minio resources to the namespace

```
$ oc apply -k minio
```

3. Create a route to enable external access to the Minio instance

```
$ oc create route edge --service=minio
```

4. Save the Minio route for later usage -

```
$ oc get route
```

## Setting up OADP

On both clusters -

1. Install the OADP operator for the Operator Hub.

2. Apply the cloud credentials that connect OADP to Minio by running the next command -

```
$ oc apply -f oadp-manifests/cloud-credentials.yaml
```

3. Create a DataProtectionApplication resource to configure the Velero instance. **Make sure to modify the S3 endpoint with the Minio route you created in the previous stage** -

```
$ oc apply -f oadp-manifests/dataprotectionapplication.yaml
```

4. Create a VolumeSnapshotLocation resource. **Make sure to modify the S3 endpoint with the Minio route you created in the previous stage** -

```
$ oc apply -f oadp-manifests/volumesnapshotlocation.yaml
```

## Configuring AAP

On both clusters -

1. Install the AAP operator from Operator Hub in the aap namespace.

2. Allow the AAP database to run as a specific UID by attaching the anyuid SCC to the default service account in the namespace -

```
$ oc adm policy add-scc-to-user anyuid -z default -n aap
```

3. Install the AutomationController CR.

## Backup

On primary cluster -

1. Log into the AAP instance and make some changes. Create inventories, credentials, etc.

2. Create a backup by applying the backup CR -

```
$ oc apply -f oadp-manifests/backup-pvc.yaml
```

3. Validate that the backup is successful by verifying the output of the next commands -

```
$ oc get backup -n openshift-adp -o yaml
```

## Restore

On secondary site -

1. Create a CronJob resource that periodically runs a flow that restores and configures AAP from the backup created in the primary site -

```
$ oc apply -f oadp-manifests/cronjob.yaml -n openshift-adp
```

2. Validate that the job is completes successfuly and AAP is available with the relevant restored data.

```
$ oc get job -n openshift-adp -o yaml
```