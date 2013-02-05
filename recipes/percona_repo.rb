#
# Cookbook Name:: mysql
# Recipe:: percona_repo
#
# Copyright 2008-2009, Opscode, Inc.
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


case node['platform']
  when "ubuntu", "debian"
    include_recipe "apt"
    execute "add percona key to gpg" do
      command "gpg --keyserver keys.gnupg.net --homedir /root " +
	"--recv-keys #{node['mysql']['percona']['key_id']}"
      not_if "gpg --list-keys #{node['mysql']['percona']['key_id']}"
    end

    execute "add percona key to apt" do
      command "gpg --homedir /root --armor " +
	"--export #{node['mysql']['percona']['key_id']} | apt-key add -"
      not_if "apt-get key list #{node['mysql']['percona']['key_id']}"
    end

    apt_repository "percona" do
      uri "http://repo.percona.com/apt"
      distribution node['lsb']['codename']
      components [ "main" ]
      key node['mysql']['percona']['key_id']
      action :add
    end
end
