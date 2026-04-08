moved {
  from = module.ebs_csi_controller_role.aws_iam_role.this[0]
  to   = module.ebs_csi_controller_role[0].aws_iam_role.this[0]
}

moved {
  from = module.ebs_csi_controller_role.aws_iam_role_policy_attachment.custom[0]
  to   = module.ebs_csi_controller_role[0].aws_iam_role_policy_attachment.custom[0]
}
