#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <region-name> <cluster-name>"
    exit 1
fi

AWS_REGION=$1
CLUSTER_NAME=$2

# Get cluster information
CLUSTER_ENDPOINT=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --region $AWS_REGION \
    --output text \
    --query 'cluster.endpoint')

CLUSTER_CA=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --region $AWS_REGION \
    --output text \
    --query 'cluster.certificateAuthority.data')

CLUSTER_CIDR=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --region $AWS_REGION \
    --output text \
    --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr')

# Generate the NodeConfig
cat << EOF > userdata-$CLUSTER_NAME.yaml
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${CLUSTER_NAME}
    apiServerEndpoint: ${CLUSTER_ENDPOINT}
    certificateAuthority: ${CLUSTER_CA}
    cidr: ${CLUSTER_CIDR}

--BOUNDARY--
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
echo "Hello World" > /tmp/greetings.txt

--BOUNDARY--
