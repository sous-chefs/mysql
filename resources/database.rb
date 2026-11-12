# frozen_string_literal: true

provides :mysql_database
unified_mode true

property :database_name, String, name_property: true
property :host, [String, nil], default: 'localhost', desired_state: false
property :port, [Integer, nil], default: 3306, desired_state: false
property :user, [String, nil], default: 'root', desired_state: false
property :socket, [String, nil], desired_state: false
property :password, [String, nil], sensitive: true, desired_state: false
property :encoding, String, default: 'utf8'
property :collation, String, default: 'utf8_general_ci'
property :sql, String, sensitive: true
property :instance, String, default: 'default'
property :ssl_mode, String, desired_state: false
property :ssl_ca, String, desired_state: false
property :ssl_cert, String, desired_state: false
property :ssl_key, String, sensitive: true, desired_state: false

action :create do
  charset = new_resource.encoding == 'utf8' ? 'utf8mb3' : new_resource.encoding
  collation = new_resource.collation.sub(/^utf8_/, 'utf8mb3_')
  current = client.query("SELECT DEFAULT_CHARACTER_SET_NAME AS encoding, DEFAULT_COLLATION_NAME AS collation FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=#{quote(new_resource.database_name)}").first
  unless current && current['encoding'] == charset && current['collation'] == collation
    converge_by "Configure database #{new_resource.database_name}" do
      statement = current ? 'ALTER DATABASE' : 'CREATE DATABASE'
      client.query("#{statement} #{identifier(new_resource.database_name)} CHARACTER SET #{identifier(charset)} COLLATE #{identifier(collation)}")
    end
  end
end

action :drop do
  unless client.query("SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=#{quote(new_resource.database_name)}").empty?
    converge_by "Drop database #{new_resource.database_name}" do
      client.query("DROP DATABASE #{identifier(new_resource.database_name)}")
    end
  end
end

action :query do
  raise ArgumentError, 'sql is required for action :query' unless new_resource.sql
  converge_by "Execute SQL in database #{new_resource.database_name}" do
    client.execute(new_resource.sql, database: new_resource.database_name)
  end
end

action_class do
  def client
    @client ||= MysqlCookbook::SqlClient.new({ host: new_resource.host, port: new_resource.port, user: new_resource.user, password: new_resource.password, socket: new_resource.socket, ssl_mode: new_resource.ssl_mode, ssl_ca: new_resource.ssl_ca, ssl_cert: new_resource.ssl_cert, ssl_key: new_resource.ssl_key })
  end

  def quote(value)
    MysqlCookbook::SqlClient.quote(value)
  end

  def identifier(value)
    MysqlCookbook::SqlClient.identifier(value)
  end
end
