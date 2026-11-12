# frozen_string_literal: true

require 'rspec'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'

describe 'MySQL test failure diagnostics' do
  it 'reports structured failures without emitting bootstrap SQL or password material' do
    Dir.mktmpdir('mysql-diagnostics') do |directory|
      log_dir = File.join(directory, 'mysql-primary')
      FileUtils.mkdir_p(log_dir)
      secret = "fixture-do-not-emit-'quoted-password"
      File.write(File.join(log_dir, 'error.log'), "[ERROR] [MY-010187] SQL ALTER USER IDENTIFIED BY '#{secret}'; Errcode: 13 Permission denied\n")
      script = File.expand_path('../test/cookbooks/test/files/default/mysql_diagnostics.rb', __dir__)
      stdout, stderr, status = Open3.capture3({ 'MYSQL_DIAGNOSTIC_LOG_DIR' => directory }, RbConfig.ruby, script)
      expect(status).to be_success
      expect(stdout).to include('[MY-010187]', 'errno=13', 'Permission denied')
      expect(stdout).not_to include(secret, 'ALTER USER', 'IDENTIFIED BY')
      expect(stderr).to be_empty
    end
  end
end
