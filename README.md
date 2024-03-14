# AAP OADP DR

This repository demonstrates a backup and restore flow for Ansible Automation Platform (AAP) between two OpenShift clusters by using OpenShift Application Data Protection (OADP).

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

On primary cluster -

1. Install the AAP operator from Operator Hub.

2. 