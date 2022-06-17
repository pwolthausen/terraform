/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "app_projects" {
  source   = "../../modules/app_projects"
  for_each = local.applications

  org_id          = var.org_id
  billing_account = var.billing_account
  parent_id       = local.parent_id

  department       = var.department
  application_name = each.key
  primary_contact  = each.value.primary_contact

  environments  = length(each.value.environments) < 1 ? ["prod", "dev", "stage"] : each.value.environments
  prj_prod_iam  = each.value.prj_prod_iam
  prj_stage_iam = each.value.prj_stage_iam
  prj_test_iam  = each.value.prj_test_iam
  prj_dev_iam   = each.value.prj_dev_iam
  prj_qa_iam    = each.value.prj_qa_iam
}
