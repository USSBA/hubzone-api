#!/bin/bash

WORKSPACE=`terraform workspace show`
SERVICE='hubzone-api'

SGID=`aws ec2 describe-security-groups --query "SecurityGroups[?contains(GroupName, '${WORKSPACE}-${SERVICE}-fg-svc-sg') && starts_with(GroupName, '${WORKSPACE}')].GroupId" --output text`
terraform import \
  "module.api.aws_security_group_rule.fargate_egress" \
  "${SGID}_egress_all_0_0_0.0.0.0/0"

SGID=`aws ec2 describe-security-groups --query "SecurityGroups[?contains(GroupName, '${WORKSPACE}-${SERVICE}-fg-alb') && starts_with(GroupName, '${WORKSPACE}')].GroupId" --output text`
terraform import \
  "module.api.aws_security_group_rule.alb_egress" \
  "${SGID}_egress_all_0_0_0.0.0.0/0"

terraform import \
  "module.api.aws_security_group_rule.alb_egress_ipv6[0]" \
  "${SGID}_egress_all_0_0_::/0"
