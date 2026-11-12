# frozen_string_literal: true

# Emit only profile identity, structured MySQL codes and fixed OS error labels.
# Never print SQL text or authentication details from a bootstrap error log.
puts File.read('/proc/self/attr/current').strip if File.exist?('/proc/self/attr/current')
Dir.glob(File.join(ENV.fetch('MYSQL_DIAGNOSTIC_LOG_DIR', '/var/log'), 'mysql-*', 'error.log')).sort.each do |path|
  File.readlines(path).last(60).each do |line|
    next unless line.include?('[ERROR]')

    codes = line.scan(/\[MY-\d+\]/)
    codes += line.scan(/(?:errno|Errcode)[:= ]+(\d+)/i).flatten.map { |number| "errno=#{number}" }
    codes += ['Permission denied', 'Operation not permitted', 'No such file or directory'].select { |label| line.include?(label) }
    puts "#{path}: #{codes.join(' ')}"
  end
end
