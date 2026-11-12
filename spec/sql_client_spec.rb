# frozen_string_literal: true

require 'rspec'
require 'securerandom'
require_relative '../libraries/sql_client'

describe MysqlCookbook::SqlClient do
  it 'keeps credentials out of arguments and removes the private file after success' do
    password = "sample-#{SecureRandom.hex(8)}\"\\\n"
    option_path = nil
    allow(Mixlib::ShellOut).to receive(:new) do |*arguments, **options|
      option_path = arguments.find { |argument| argument.start_with?('--defaults-file=') }.split('=', 2).last
      expect(::File.stat(option_path).mode & 0o777).to eq(0o600)
      expect(arguments.join(' ')).not_to include(password)
      expect(options.fetch(:input)).to start_with("SET SESSION sql_mode='NO_BACKSLASH_ESCAPES';")
      expect(options.fetch(:environment)).to include('MYSQL_PWD' => nil)
      double(run_command: nil, exitstatus: 0, stdout: '', stderr: '')
    end
    described_class.new({ user: 'root', password: password }).query('SELECT 1')
    expect(::File).not_to exist(option_path)
  end

  it 'redacts query errors and removes the private file after failure' do
    option_path = nil
    allow(Mixlib::ShellOut).to receive(:new) do |*arguments, **_options|
      option_path = arguments.find { |argument| argument.start_with?('--defaults-file=') }.split('=', 2).last
      double(run_command: nil, exitstatus: 1, stdout: '', stderr: 'ERROR 1045 sensitive query text')
    end
    request = -> { described_class.new({ user: 'root' }).query('sensitive query text') }
    expect(&request).to raise_error(MysqlCookbook::QueryError) do |error|
      expect(error.error_code).to eq(1045)
      expect(error.message).not_to include('sensitive query text')
      expect(error.cause).to be_nil
    end
    expect(::File).not_to exist(option_path)
  end

  it 'does not change SQL mode for an explicit raw query action' do
    allow(Mixlib::ShellOut).to receive(:new) do |*_arguments, **options|
      expect(options.fetch(:input)).to eq('SELECT 1')
      double(run_command: nil, exitstatus: 0, stdout: '', stderr: '')
    end
    described_class.new({ user: 'root' }).execute('SELECT 1')
  end
end

describe 'MySQL 8.4 SQL transport', :real_mysql do
  before do
    skip 'Set MYSQL_REAL_TEST_CLI to an isolated test client' unless ENV['MYSQL_REAL_TEST_CLI']
    @client = MysqlCookbook::SqlClient.new(
      { user: 'root', socket: '/var/run/mysqld/mysqld.sock' },
      binary: ENV.fetch('MYSQL_REAL_TEST_CLI'), options_dir: '/private/tmp/mysql-754-options'
    )
  end

  it 'round trips quotes, backslashes, newlines and NULL without shell interpretation' do
    value = "quote' slash\\ newline\n tab\t $(not-a-shell-command)"
    result = @client.query("SELECT #{MysqlCookbook::SqlClient.quote(value)} AS value, NULL AS missing")
    expect(result).to eq([{ 'value' => value, 'missing' => nil }])
  end

  it 'quotes unusual database identifiers and uses structured metadata rows' do
    name = "chef_test_#{SecureRandom.hex(4)}`quoted"
    @client.query("CREATE DATABASE #{MysqlCookbook::SqlClient.identifier(name)}")
    rows = @client.query("SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=#{MysqlCookbook::SqlClient.quote(name)}")
    expect(rows).to eq([{ 'SCHEMA_NAME' => name }])
  ensure
    @client&.query("DROP DATABASE IF EXISTS #{MysqlCookbook::SqlClient.identifier(name)}") if name
  end

  it 'authenticates a password with quotes, backslashes, newlines and tabs through the private options file' do
    username = "chef_transport_#{SecureRandom.hex(4)}"
    password = "quote' double\" slash\\ newline\n tab\t!"
    @client.query("CREATE USER #{MysqlCookbook::SqlClient.quote(username)}@'localhost' IDENTIFIED BY #{MysqlCookbook::SqlClient.quote(password)}")
    login = MysqlCookbook::SqlClient.new({ user: username, password: password, socket: '/var/run/mysqld/mysqld.sock' }, binary: ENV.fetch('MYSQL_REAL_TEST_CLI'), options_dir: '/private/tmp/mysql-754-options')
    expect(login.query('SELECT CURRENT_USER() AS account')).to eq([{ 'account' => "#{username}@localhost" }])
  ensure
    @client&.query("DROP USER IF EXISTS #{MysqlCookbook::SqlClient.quote(username)}@'localhost'") if username
  end
end
