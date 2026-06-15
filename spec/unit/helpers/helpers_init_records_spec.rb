# frozen_string_literal: true

require 'spec_helper'
require 'shellwords'
require 'json'
require_relative '../../../libraries/helpers'

RSpec.describe MysqlCookbook::HelpersBase do
  let(:helper) do
    Object.new.extend(described_class)
  end

  before do
    allow(helper).to receive(:mysql_name).and_return('mysql')
    allow(helper).to receive(:mysqld_bin).and_return('/usr/sbin/mysqld')
    allow(helper).to receive(:etc_dir).and_return('/etc/mysql')
    allow(helper).to receive(:run_user).and_return('mysql')
    allow(helper).to receive(:pid_file).and_return('/var/run/mysql/mysqld.pid')
    allow(helper).to receive(:default_socket_file).and_return('/var/run/mysql/mysqld.sock')
    allow(helper).to receive(:error_log).and_return('/var/log/mysql/error.log')
  end

  describe '#init_records_script' do
    it 'uses --initialize (secure mode, not --initialize-insecure)' do
      script = helper.init_records_script
      expect(script).to include('--initialize')
      expect(script).not_to include('--initialize-insecure')
    end

    it 'captures the temporary password from the error log' do
      script = helper.init_records_script
      expect(script).to include('temporary password')
      expect(script).to include('/var/log/mysql/error.log')
    end

    it 'does not use --init-file' do
      script = helper.init_records_script
      expect(script).not_to include('--init-file')
    end

    it 'writes a temp option file with the captured password' do
      script = helper.init_records_script
      expect(script).to include('[client]')
      expect(script).to include('password=')
      expect(script).to include('--defaults-extra-file=')
    end

    it 'uses --connect-expired-password to change the temp password' do
      script = helper.init_records_script
      expect(script).to include('--connect-expired-password')
      expect(script).to include('ALTER USER')
    end

    it 'writes the permanent password to etc_dir/.root_password' do
      script = helper.init_records_script
      expect(script).to include('/etc/mysql/.root_password')
      expect(script).to include('chmod 600')
    end

    it 'cleans up temp files but preserves the password file' do
      script = helper.init_records_script
      expect(script).to include('rm -rf /tmp/mysql')
      expect(script).not_to include('rm /etc/mysql/.root_password')
    end

    it 'kills mysqld and waits for shutdown' do
      script = helper.init_records_script
      expect(script).to include('kill $(cat /var/run/mysql/mysqld.pid)')
      expect(script).to include('while [ -f /var/run/mysql/mysqld.pid ]')
    end

    it 'generates a valid bash script with set -e' do
      script = helper.init_records_script
      expect(script.lines.first.strip).to eq('set -e')
    end

    it 'orders steps correctly: initialize → capture → start → change password → save → kill' do
      script = helper.init_records_script
      init_pos = script.index('--initialize')
      grep_pos = script.index('temporary password')
      start_pos = script.index("mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql &\n")
      alter_pos = script.index('ALTER USER')
      save_pos = script.index('.root_password')
      kill_pos = script.index('kill $(cat')

      expect(init_pos).to be < grep_pos
      expect(grep_pos).to be < start_pos
      expect(start_pos).to be < alter_pos
      expect(alter_pos).to be < save_pos
      expect(save_pos).to be < kill_pos
    end
  end
end
