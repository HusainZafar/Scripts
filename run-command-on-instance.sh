#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <instance-id> <script-file> <region>"
    exit 1
fi

INSTANCE_ID=$1
SCRIPT_FILE=$2
REGION=$3

# Check if the script file exists
if [ ! -f "$SCRIPT_FILE" ]; then
    echo "Error: Script file '$SCRIPT_FILE' not found."
    exit 1
fi

# Read the script content
SCRIPT_CONTENT=$(cat "$SCRIPT_FILE")

# Run the script on the instance using SSM
aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=[\"$SCRIPT_CONTENT\"]" \
    --region $REGION \
    --output json

# Get the command ID from the output
COMMAND_ID=$(aws ssm list-commands --instance-id "$INSTANCE_ID" --region $REGION --query 'Commands[0].CommandId' --output text)

# Wait for the command to complete
aws ssm wait command-executed --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID" --region $REGION

# Get the command output
aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --region $REGION \
    --query "StandardOutputContent" \
    --output text

echo "Script execution completed."
