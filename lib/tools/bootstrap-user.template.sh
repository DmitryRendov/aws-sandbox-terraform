#!/bin/bash
set -e

username={{USERNAME}}
akid={{AKID}}
secret={{SECRET}}

required_commands="aws jq python3 aws-login.sh"

for required_command in $required_commands; do
    command -v "$required_command" > /dev/null || { >&2 echo "$required_command is not installed, please follow our docs in the Teams group"; exit 1; }
done

aws --profile bastion configure set aws_access_key_id $akid
aws --profile bastion configure set aws_secret_access_key $secret

keycount=$(aws --profile bastion --output json iam list-access-keys |jq -r '.AccessKeyMetadata|length')
if [[ $keycount -gt 1 ]]; then
    otherkey=$(aws --profile bastion --output json iam list-access-keys |jq -r '.AccessKeyMetadata[]| select(.AccessKeyId != "'${akid}'")|.AccessKeyId')
    echo "Please have a kind super-user delete this bogus key: $otherkey"
    exit 1;
fi

echo Enter a NEW password so you can log into the AWS console,
echo Requires at least one upper and lower letter, one number,
echo one non-alphanumeric character, and is at least 14 characters long.
while :; do
  echo
  echo -n 'Console password: '
  read -s consolepw
  echo
  pwlen=${#consolepw}
  if [[ $pwlen -ge 14 ]]; then
    if [[ $consolepw == *[[:lower:]]* && $consolepw == *[[:upper:]]* && \
          $consolepw == *[0-9]* && ! $consolepw == *[[:space:]]* ]] ; then
      if [[ $consolepw == *[\!@\#\$%^\&*\(\)_\+\-\=\[\]{}\|]* ]] ; then
        echo
        echo -n 'Repeat password, please: '
        read -s consolepw2verify
        echo
        [ "$consolepw" = "$consolepw2verify" ] && break || echo "Passwords don't match. Please try again..."
        else
          echo "Weak password, must include one non-alphanumeric character like !@#$%^&*()_+-=[]{}|"
      fi
    else
      echo "Weak password, please include at least one number, one lowercase and one uppercase character"
    fi
  else
    echo "Weak password, must be at least 14 characters long"
  fi
done

TMPFILE="$(mktemp -d)/mfabarcode.png"

echo Enabling Two-factor authentication. Amazon requires that you verify 2 consecutive tokens.
serialnumber=$(aws --profile bastion --output text iam create-virtual-mfa-device --virtual-mfa-device-name $username --outfile $TMPFILE --bootstrap-method QRCodePNG | awk '{print $2}')
aws --profile bastion configure set mfa_serial $serialnumber

echo Opening the file containing the barcode to scan into your Google Authenticator or Authy app to host the MFA device
sleep 2
open $TMPFILE || true

echo -n Enter the first token:
read token1
echo -n Wait for a new token to show and enter it:
read token2

rm -f $TMPFILE

aws --profile bastion iam enable-mfa-device --user-name $username --serial-number $serialnumber --authentication-code1 $token1 --authentication-code2 $token2

echo Now that we are actually logging you in to your account with 2FA, you will be prompted to enter a token once more.
sleep 5
echo You can use whatever token your 2FA app shows, no need to wait for a new token like we did before.
sleep 5

aws-bastion.sh login

aws --profile sts iam create-login-profile --user-name $username --password "$consolepw" --no-password-reset-required || echo "Console password setting failed, probably didn't meet minimum standards. You can try again later using the CLI http://docs.aws.amazon.com/cli/latest/reference/iam/create-login-profile.html"

echo "You're good to go now."
echo You can sign into the AWS Console with the following link https://501055688096.signin.aws.amazon.com/console
