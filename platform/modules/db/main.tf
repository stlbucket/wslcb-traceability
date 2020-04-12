# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


locals {
}

resource "google_sql_database_instance" "postgres" {
  name             = "lcb-postgres-db"
  database_version = "POSTGRES_11"

  settings {
    tier = "db-custom-1-4096"
  }
}




# https://github.com/hashicorp/terraform/issues/12617#issuecomment-298617855