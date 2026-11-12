# frozen_string_literal: true

require 'json'

module MysqlCookbook
  module Lifecycle
    def self.paths_overlap?(left, right)
      left = canonical_path(left)
      right = canonical_path(right)
      left == right || left == '/' || right == '/' || left.start_with?(right + '/') || right.start_with?(left + '/')
    end

    def self.ensure_bootstrap_marker(path, data_dir:, series:)
      state = { 'data_dir' => canonical_path(data_dir), 'series' => series }
      begin
        ::File.open(path, ::File::WRONLY | ::File::CREAT | ::File::EXCL, 0600) { |file| file.write(JSON.generate(state)) }
      rescue Errno::EEXIST
        stat = ::File.lstat(path)
        raise 'Untrusted MySQL bootstrap marker; inspect recovery state' unless stat.file? && !stat.symlink? && stat.uid.zero? && stat.nlink == 1 && (stat.mode & 0777) == 0600
        raise 'Bootstrap recovery state does not match this data directory and server series' unless JSON.parse(::File.read(path)) == state
      end
    end

    def self.canonical_path(path)
      expanded = ::File.expand_path(path)
      return ::File.realpath(expanded) if ::File.exist?(expanded) || ::File.symlink?(expanded)

      ::File.join(canonical_path(::File.dirname(expanded)), ::File.basename(expanded))
    end

    def self.process_alive_from_pid?(path)
      return false unless ::File.exist?(path)

      pid = Integer(::File.read(path).strip, 10)
      raise 'Invalid bootstrap PID file; inspect the instance before retrying' unless pid.positive?

      Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    rescue Errno::EPERM
      true
    end
  end
end
