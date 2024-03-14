#! /bin/bash

kubectl delete automationcontroller aap -n aap
kubectl delete pvc --all -n aap

RESTORE_NAME="aap-restore"
kubectl delete restore $RESTORE_NAME

sleep 40

NEWEST_BACKUP_NAME=$(kubectl get backups -n openshift-adp --sort-by=.metadata.creationTimestamp -o json | jq -r '.items[-1].metadata.name')

cat <<EOF | kubectl apply -f -
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: $RESTORE_NAME
  namespace: openshift-adp
spec:
  backupName: $NEWEST_BACKUP_NAME
  excludedResources:
  - operatorgroups.operators.coreos.com
  - subscriptions.operators.coreos.com
  - deployments
  - statefulsets
  - replicasets
  - automationcontrollerbackups.automationcontroller.ansible.com
  - automationcontrollerrestores.automationcontroller.ansible.com
  existingResourcePolicy: update
  includedNamespaces:
    - aap
  itemOperationTimeout: 1h0m0s
  restorePVs: true
EOF

# Needs to be reconfigured and defined according to proper time to complete
sleep 120

kubectl patch statefulset aap-postgres-13 --type='json' -p='[{"op": "add", "path": "/spec/template/spec/securityContext/runAsUser", "value": 1000710000}]' -n aap

sleep 5

oc delete pods --all -n aap