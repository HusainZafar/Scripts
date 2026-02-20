# There is a limit of 1000 instance profiles per AWS account

aws iam list-instance-profiles --output json | \
  jq -r '.InstanceProfiles[].InstanceProfileName' | \
  grep -E 'regex-goes-here' | \
  while read profile; do
    echo "Processing: $profile"

    # Remove any attached roles first
    roles=$(aws iam get-instance-profile \
      --instance-profile-name "$profile" \
      --query 'InstanceProfile.Roles[*].RoleName' \
      --output text)

    for role in $roles; do
      echo "  Removing role $role from $profile"
      aws iam remove-role-from-instance-profile \
        --instance-profile-name "$profile" \
        --role-name "$role"
    done

    # Delete the profile
    aws iam delete-instance-profile --instance-profile-name "$profile"
    echo "  Deleted: $profile"
  done
