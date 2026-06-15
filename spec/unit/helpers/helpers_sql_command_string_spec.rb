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
    # Stub default_socket_file used when host is localhost
    allow(helper).to receive(:default_socket_file).and_return('/var/run/mysqld/mysqld.sock')
  end

  describe '#sql_command_string' do
    context 'with a simple password' do
      it 'builds a valid command' do
        ctrl = { user: 'root', password: 'simple', host: '127.0.0.1', port: 3306 }
        cmd = helper.sql_command_string('SELECT 1', nil, ctrl)
        expect(cmd).to include('-psimple')
        expect(cmd).to include('-B -e')
      end
    end

    context 'with special characters in password' do
      let(:password) { 'MyPa$$word\Has_"Special\'Chars%!' }
      let(:ctrl) { { user: 'root', password: password, host: '127.0.0.1', port: 3306 } }

      it 'shell-escapes the password so the command is valid' do
        cmd = helper.sql_command_string('SHOW DATABASES', nil, ctrl)
        # The password portion must survive a shell round-trip.
        # Shellwords.split should be able to parse the full command without error.
        expect { Shellwords.split(cmd) }.not_to raise_error
      end

      it 'preserves the password value through shell escaping' do
        cmd = helper.sql_command_string('SHOW DATABASES', nil, ctrl)
        # Extract the -p argument from the parsed tokens
        tokens = Shellwords.split(cmd)
        password_token = tokens.find { |t| t.start_with?('-p') }
        expect(password_token).not_to be_nil
        extracted = password_token.sub(/\A-p/, '')
        expect(extracted).to eq(password)
      end
    end

    context 'with nil password' do
      it 'omits the -p flag' do
        ctrl = { user: 'root', password: nil, host: '127.0.0.1', port: 3306 }
        cmd = helper.sql_command_string('SELECT 1', nil, ctrl)
        expect(cmd).not_to include('-p')
      end
    end

    context 'with no password key' do
      it 'omits the -p flag' do
        ctrl = { user: 'root', host: '127.0.0.1', port: 3306 }
        cmd = helper.sql_command_string('SELECT 1', nil, ctrl)
        expect(cmd).not_to include('-p')
      end
    end
  end
end
