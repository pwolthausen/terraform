

module "departments" {
  for_each = var.departments

  source                             = "../modules/department_fldr"
  department                         = each.key
  parent                             = local.parent
  org_id                             = var.org_id
  billing_account                    = var.billing_account
  terraform_service_account          = var.terraform_service_account
  folder_prefix                      = var.folder_prefix
  department_fldr_iam_bindings       = each.value.dept_fldr_iam_bindings
  department_prod_fldr_iam_bindings  = each.value.prod_fldr_iam_bindings
  department_dev_fldr_iam_bindings   = each.value.dev_fldr_iam_bindings
  department_test_fldr_iam_bindings  = each.value.test_fldr_iam_bindingss
  department_stage_fldr_iam_bindings = each.value.stage_fldr_iam_bindings
}
