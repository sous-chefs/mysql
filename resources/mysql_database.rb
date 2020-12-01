#
# Cookbook:: mysql
# Resource:: database
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
provides :mysql_database

include MysqlCookbook::HelpersBase
include MysqlCookbook

property :database_name, String,         name_property: true
property :host,          [String, nil],  default: 'localhost', desired_state: false
property :port,          [Integer, nil], default: 3306, desired_state: false
property :user,          [String, nil],  default: 'root', desired_state: false
property :socket,        [String, nil],  desired_state: false
property :password,      [String, nil],  sensitive: true, desired_state: false
property :encoding,      String,         default: 'utf8'
property :collation,     String,         default: 'utf8_general_ci'
property :sql,           String
property :instance,      String, default: 'default'

action :create do
  if current_resource.nil?
    converge_by "Creating database '#{new_resource.database_name}'" do
      create_sql = "CREATE DATABASE IF NOT EXISTS \\`#{new_resource.database_name}\\`"
      create_sql << " CHARACTER SET = #{new_resource.encoding}" if new_resource.encoding
      create_sql << " COLLATE = #{new_resource.collation}" if new_resource.collation
      run_query(create_sql, nil)
    end
  else
    converge_if_changed :encoding do
      run_query("ALTER SCHEMA \\`#{new_resource.database_name}\\` CHARACTER SET #{new_resource.encoding}", nil)
    end
    converge_if_changed :collation do
      run_query("ALTER SCHEMA \\`#{new_resource.database_name}\\` COLLATE #{new_resource.collation}", nil)
    end
  end
end

action :drop do
  return if current_resource.nil?
  converge_by "Dropping database '#{new_resource.database_name}'" do
    run_query("DROP DATABASE IF EXISTS \\`#{new_resource.database_name}\\`", nil)
  end
end

action :query do
  run_query(new_resource.sql, nil)
end

load_current_value do
  lsocket = (socket && host == 'localhost') ? socket : nil
  ctrl = { user: user, password: password
                   }.merge!(lsocket.nil? ? { host: host, port: port } : { socket: lsocket })
  query = "SHOW DATABASES LIKE '#{database_name}'"
  results = execute_sql(query, nil, ctrl).split("\n")
  current_value_does_not_exist! if results.count == 0

  results = execute_sql("SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '#{database_name}'", nil, ctrl)
  results.split("\n").each do |row|
    columns = row.split("\t")
    if columns[0] != 'DEFAULT_CHARACTER_SET_NAME'
      encoding  columns[0]
      collation columns[1]
    end
  end
end

action_class do
  include MysqlCookbook::HelpersBase

  def run_query(query, database)
    socket = (new_resource.socket && new_resource.host == 'localhost') ? new_resource.socket : nil
    ctrl_hash = { host: new_resource.host, port: new_resource.port, user: new_resource.user, password: new_resource.password, socket: socket }
    Chef::Log.debug("#{@new_resource}: Performing query [#{query}]")
    execute_sql(query, database, ctrl_hash)
  end
end
