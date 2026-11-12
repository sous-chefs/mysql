# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'
require_relative '../libraries/sql_client'

describe 'MySQL resources against an isolated real server', :real_mysql do
  before do
    skip 'Set MYSQL_REAL_TEST_CLI to an isolated test client' unless ENV['MYSQL_REAL_TEST_CLI']
    @database = "chef_database_#{SecureRandom.hex(4)}`quote"
    @username = "chef_user_#{SecureRandom.hex(4)}"
    allow(MysqlCookbook::SqlClient).to receive(:new).and_wrap_original do |original, connection, **_options|
      original.call(connection, binary: ENV.fetch('MYSQL_REAL_TEST_CLI'), options_dir: '/private/tmp/mysql-754-options')
    end
  end

  def converge_sql(recipe = 'test::sql')
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: [:mysql_database, :mysql_user]) do |node|
      node.default['mysql_test']['database'] = @database
      node.default['mysql_test']['username'] = @username
    end.converge(recipe)
  end

  it 'creates a database and current-auth account with scoped grants, then converges without updates' do
    first = converge_sql
    expect(first.find_resource(:mysql_database, @database)).to be_updated_by_last_action
    second = converge_sql
    expect(second.resource_collection.select(&:updated_by_last_action?)).to be_empty
    client = MysqlCookbook::SqlClient.new({ user: 'root', socket: '/var/run/mysqld/mysqld.sock' })
    expect(client.query("SELECT plugin FROM mysql.user WHERE User=#{MysqlCookbook::SqlClient.quote(@username)}").first['plugin']).to eq('caching_sha2_password')
    grantee = MysqlCookbook::SqlClient.quote("'#{@username}'@'localhost'")
    expect(client.query("SELECT PRIVILEGE_TYPE FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE=#{grantee} ORDER BY PRIVILEGE_TYPE").map { |row| row['PRIVILEGE_TYPE'] }).to eq(%w(INSERT SELECT))
    client.query("GRANT DELETE ON #{MysqlCookbook::SqlClient.identifier(@database)}.* TO #{MysqlCookbook::SqlClient.quote(@username)}@'localhost'")
    expect(converge_sql.resource_collection.select(&:updated_by_last_action?).map(&:name)).to include("#{@username} revoke unused privilege")
    client.query("ALTER USER #{MysqlCookbook::SqlClient.quote(@username)}@'localhost' IDENTIFIED BY 'fixture-rotated-externally'")
    expect(converge_sql.resource_collection.select(&:updated_by_last_action?).map(&:name)).to include(@username)
    expect(converge_sql.resource_collection.select(&:updated_by_last_action?)).to be_empty
    converge_sql('test::sql_delete')
    expect(converge_sql('test::sql_delete').resource_collection.select(&:updated_by_last_action?)).to be_empty
  ensure
    if @database
      client ||= MysqlCookbook::SqlClient.new({ user: 'root', socket: '/var/run/mysqld/mysqld.sock' })
      client.query("DROP DATABASE IF EXISTS #{MysqlCookbook::SqlClient.identifier(@database)}")
      client.query("DROP USER IF EXISTS #{MysqlCookbook::SqlClient.quote(@username)}@'localhost'")
    end
  end

  it 'grants both static and registered dynamic global privileges idempotently' do
    converge_sql('test::sql_global')
    expect(converge_sql('test::sql_global').resource_collection.select(&:updated_by_last_action?)).to be_empty
    client = MysqlCookbook::SqlClient.new({ user: 'root', socket: '/var/run/mysqld/mysqld.sock' })
    dynamic = client.query("SELECT PRIV FROM mysql.global_grants WHERE User=#{MysqlCookbook::SqlClient.quote(@username)}")
    expect(dynamic.map { |row| row['PRIV'] }).to include('BACKUP_ADMIN')
  ensure
    client&.query("DROP USER IF EXISTS #{MysqlCookbook::SqlClient.quote(@username)}@'localhost'") if @username
  end
end
