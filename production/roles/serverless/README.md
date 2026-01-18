## Purpose
<!-- What is this role for? -->

This role is responsible for deploying and managing serverless applications in the production environment using AWS Lambda and API Gateway.
It ensures that serverless functions are properly configured, monitored, and scaled to meet the demands of production workloads.

Currently this role is destroyed and not in use.

## Workspaces
<!-- Which workspaces does this role use? -->

## Information
<!-- Any additional info for future developers to know for this role -->

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::562495469185:role/dmitry_rendov \
  --role-session-name production \
  --profile sts
```

then save the output credentials to `~/.aws/credentials` under `[production]` profile.

## Secrets
<!-- What secrets are used in this role? How/where are they generated? How do you rotate them?-->

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
