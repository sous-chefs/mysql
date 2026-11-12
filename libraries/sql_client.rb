# frozen_string_literal: true

require 'mixlib/shellout'
require 'rexml/document'
require 'tempfile'

module MysqlCookbook
  class QueryError < StandardError
    attr_reader :error_code

    def initialize(message, error_code = nil)
      @error_code = error_code
      super(message)
    end
  end

  # Use the vendor client without a shell, password arguments or persistent credential files.
  class SqlClient
    OPTIONS = %i(user password host port socket ssl_mode ssl_ca ssl_cert ssl_key).freeze

    def initialize(connection, binary: '/usr/bin/mysql', options_dir: nil)
      @connection = connection
      @binary = binary
      @options_dir = options_dir
    end

    def self.quote(value)
      "'#{value.to_s.gsub("'", "''")}'"
    end

    def self.identifier(value)
      raise ArgumentError, 'SQL identifiers cannot contain NUL' if value.to_s.include?("\0")

      "`#{value.to_s.gsub('`', '``')}`"
    end

    def query(sql, database: nil)
      parse(run(sql, database: database, managed: true))
    end

    def execute(sql, database: nil)
      run(sql, database: database, managed: false)
      nil
    end

    def self.option_value(value)
      escapes = { '\\' => '\\\\', '"' => '\\"', "\n" => '\\n', "\r" => '\\r', "\t" => '\\t' }
      '"' + value.to_s.gsub(/[\\"\n\r\t]/) { |character| escapes.fetch(character) } + '"'
    end

    private

    def run(sql, database:, managed:)
      Tempfile.create(['chef-mysql-', '.cnf'], @options_dir) do |file|
        file.chmod(0o600)
        file.write("[client]\n")
        OPTIONS.each do |key|
          next if @connection[key].nil?

          file.write("#{key.to_s.tr('_', '-')}=#{self.class.option_value(@connection[key])}\n")
        end
        file.flush
        arguments = [@binary, "--defaults-file=#{file.path}", '--no-login-paths', '--batch', '--xml', '--binary-mode', '--skip-reconnect']
        arguments << "--database=#{database}" if database
        input = managed ? "SET SESSION sql_mode='NO_BACKSLASH_ESCAPES';\n#{sql}" : sql
        command = Mixlib::ShellOut.new(*arguments, input: input, timeout: 60, environment: { 'MYSQL_PWD' => nil })
        command.run_command
        unless command.exitstatus.zero?
          code = command.stderr[/\bERROR (\d+)/, 1]&.to_i
          raise QueryError.new("MySQL request failed#{code ? " with error #{code}" : ''}", code), cause: nil
        end
        command.stdout
      end
    rescue Mixlib::ShellOut::CommandTimeout
      raise QueryError, 'MySQL request timed out', cause: nil
    rescue Errno::ENOENT
      raise QueryError, 'MySQL client is unavailable; install mysql_client first', cause: nil
    end

    def parse(xml)
      return [] if xml.strip.empty?

      body = xml.gsub(/<\?xml[^?]*\?>/, '')
      document = REXML::Document.new("<results>#{body}</results>")
      REXML::XPath.match(document, '/results/resultset/row').map do |row|
        row.elements.to_a('field').to_h do |field|
          [field.attributes['name'], field.attributes['xsi:nil'] == 'true' ? nil : field.text.to_s]
        end
      end
    rescue REXML::ParseException
      raise QueryError, 'Unable to parse MySQL response', cause: nil
    end
  end
end
