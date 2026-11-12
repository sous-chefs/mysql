# frozen_string_literal: true

require 'rspec'
require 'tmpdir'
require_relative '../libraries/lifecycle'

describe MysqlCookbook::Lifecycle do
  it 'rejects a bootstrap marker symlink without truncating its target' do
    Dir.mktmpdir('chef-mysql-marker') do |directory|
      target = File.join(directory, 'protected')
      marker = File.join(directory, 'marker')
      File.write(target, 'preserve these bytes')
      File.symlink(target, marker)
      expect { described_class.ensure_bootstrap_marker(marker, data_dir: directory, series: '8.4') }.to raise_error(/Untrusted MySQL bootstrap marker/)
      expect(File.read(target)).to eq('preserve these bytes')
    end
  end

  it 'resolves a data symlink into configuration before deciding whether deletion is safe' do
    Dir.mktmpdir('chef-mysql-paths') do |directory|
      config = File.join(directory, 'config')
      FileUtils.mkdir_p(File.join(config, 'data'))
      data = File.join(directory, 'data-link')
      File.symlink(File.join(config, 'data'), data)
      expect(described_class.canonical_path(data)).to start_with(described_class.canonical_path(config) + '/')
      expect(described_class.canonical_path(File.join(data, 'not-created-yet'))).to start_with(described_class.canonical_path(config) + '/')
    end
  end

  it 'treats a stale positive PID as recoverable without signalling a process' do
    Dir.mktmpdir('chef-mysql-pid') do |directory|
      path = File.join(directory, 'mysqld.pid')
      File.write(path, "123456789\n")
      expect(Process).to receive(:kill).with(0, 123456789).and_raise(Errno::ESRCH)
      expect(described_class.process_alive_from_pid?(path)).to be(false)
    end
  end

  it 'refuses process-group IDs in a PID file' do
    Dir.mktmpdir('chef-mysql-pid') do |directory|
      path = File.join(directory, 'mysqld.pid')
      File.write(path, '-1')
      expect(Process).not_to receive(:kill)
      expect { described_class.process_alive_from_pid?(path) }.to raise_error(/Invalid bootstrap PID/)
    end
  end
end
