#!/bin/bash
set -e

if [[ $# -gt 0 ]]; then
    username=$1
    shift
else
    echo -n 'Username: '
    read username
fi

keycount=$(aws --profile bastion-super-user iam list-access-keys --user-name $username |jq -r '.AccessKeyMetadata|length')
if [[ $keycount -gt 0 ]]; then
    echo "User already has access keys, wut?"
    exit 1;
fi

output=$(aws --output json --profile bastion-super-user iam create-access-key --user-name $username)
akid=$(echo "$output" | jq -r .AccessKey.AccessKeyId)
secret=$(echo "$output" | jq -r .AccessKey.SecretAccessKey)
sed "s;{{USERNAME}};$username; ; s;{{AKID}};$akid; ; s;{{SECRET}};$secret;" bootstrap-user.template.sh > $username-bootstrap.sh
chmod +x $username-bootstrap.sh

echo Send $username-bootstrap.sh to $username so they can finalize their user creation in AWS
