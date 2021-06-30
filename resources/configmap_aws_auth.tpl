- ${iam_entity}arn: ${arn}
  username: ${k8s_user}
  groups:
  %{ for k8s_group in k8s_groups ~}
  - ${k8s_group}
  %{ endfor ~}