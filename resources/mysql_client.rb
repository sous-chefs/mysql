# frozen_string_literal: true

#
# Cookbook:: mysql
# Resource:: mysql_client
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
provides :mysql_client
unified_mode true

use '_partial/_base'

include MysqlCookbook::HelpersBase

property :package_name, [String, Array], default: lazy { default_client_package_name }, desired_state: false
property :package_options, [String, nil], desired_state: false
property :package_version, [String, nil], desired_state: false

action :create do
  package new_resource.package_name do
    version new_resource.package_version if new_resource.package_version
    options new_resource.package_options if new_resource.package_options
    action :install
  end
end

action :delete do
  package new_resource.package_name do
    action :remove
  end
end
