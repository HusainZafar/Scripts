#!/bin/bash

# ./delete_all_clusters.sh -h
# Usage: ./delete_all_clusters.sh -r REGION [-e ENDPOINT]

while getopts "r:e:h" opt; do
    case $opt in
        r) AWS_REGION="$OPTARG";;
        e) ENDPOINT="$OPTARG";;
        h) echo "Usage: $0 -r REGION [-e ENDPOINT]"; exit 1;;
        ?) echo "Usage: $0 -r REGION [-e ENDPOINT]"; exit 1;;
    esac
done

if [ -z "$AWS_REGION" ]; then
    echo "Error: Region is required"
    exit 1
fi

# Build base AWS command parts
AWS_CMD_BASE="aws eks"
if [ ! -z "$ENDPOINT" ]; then
    AWS_CMD_BASE="$AWS_CMD_BASE --endpoint-url $ENDPOINT"
fi

while true; do
    CLUSTERS=$(${AWS_CMD_BASE} list-clusters --region "$AWS_REGION" --query 'clusters[]' --output text)

    if [ -z "$CLUSTERS" ]; then
        echo "No clusters found"
        break
    fi

    for cluster in $CLUSTERS; do
        echo "Processing cluster: $cluster"

        # Delete one Fargate profile at a time
        fps=$(${AWS_CMD_BASE} list-fargate-profiles --cluster-name "$cluster" --region "$AWS_REGION" --query 'fargateProfileNames[]' --output text 2>/dev/null)
        if [ ! -z "$fps" ]; then
            fp=$(echo $fps | awk '{print $1}')
            echo "Deleting Fargate profile: $fp"
            ${AWS_CMD_BASE} delete-fargate-profile --cluster-name "$cluster" --fargate-profile-name "$fp" --region "$AWS_REGION"
            sleep 60
            echo "Sleeping for fp deletion"
            continue
        fi

        # Delete node groups in parallel
        ngs=$(${AWS_CMD_BASE} list-nodegroups --cluster-name "$cluster" --region "$AWS_REGION" --query 'nodegroups[]' --output text 2>/dev/null)
        if [ ! -z "$ngs" ]; then
            for ng in $ngs; do
                ${AWS_CMD_BASE} delete-nodegroup --cluster-name "$cluster" --nodegroup-name "$ng" --region "$AWS_REGION" &
            done
            echo "Sleeping for ng deletion"
            sleep 60
            continue
        fi

        # Delete cluster
        ${AWS_CMD_BASE} delete-cluster --name "$cluster" --region "$AWS_REGION" &
    done

    timeout 300 bash -c "wait" || echo "5-minute timeout reached"
    sleep 30
done

echo "All deletion commands completed"
