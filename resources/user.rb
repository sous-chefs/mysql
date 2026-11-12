# frozen_string_literal: true

provides :mysql_user
unified_mode true

property :username, String, name_property: true
property :password, [String, MysqlCookbook::HashedPassword, nil], sensitive: true
property :host, String, default: 'localhost', desired_state: false
property :database_name, String
property :table, String
property :privileges, Array, default: [:all]
property :grant_option, [true, false], default: false
property :require_ssl, [true, false], default: false
property :require_x509, [true, false], default: false
property :use_native_auth, [true, false], default: false
property :ctrl_user, [String, nil], default: 'root', desired_state: false
property :ctrl_password, [String, nil], sensitive: true, desired_state: false
property :ctrl_host, [String, nil], default: 'localhost', desired_state: false
property :ctrl_port, [Integer, nil], default: 3306, desired_state: false
property :ctrl_socket, String, desired_state: false
property :ssl_mode, String, desired_state: false
property :ssl_ca, String, desired_state: false
property :ssl_cert, String, desired_state: false
property :ssl_key, String, sensitive: true, desired_state: false

action :create do
  current = account
  if current.nil?
    converge_by "Create MySQL account #{new_resource.username}@#{new_resource.host}" do
      client.query("CREATE USER #{account_name}#{authentication}#{tls_requirement}")
    end
  else
    if new_resource.password && !password_current?(current)
      converge_by "Update MySQL account authentication #{new_resource.username}@#{new_resource.host}" do
        client.query("ALTER USER #{account_name}#{authentication}")
      end
    end
    desired_ssl = if new_resource.require_x509
                    'X509'
                  else
                    (new_resource.require_ssl ? 'ANY' : '')
                  end
    if current['ssl_type'] != desired_ssl
      converge_by "Update MySQL account TLS requirement #{new_resource.username}@#{new_resource.host}" do
        client.query("ALTER USER #{account_name}#{tls_requirement}")
      end
    end
  end
end

action :drop do
  if account
    converge_by "Drop MySQL account #{new_resource.username}@#{new_resource.host}" do
      client.query("DROP USER #{account_name}")
    end
  end
end

action :grant do
  raise 'Create the MySQL account before granting privileges' unless account
  current = granted_privileges
  missing = desired_privileges - current.map { |row| row['PRIVILEGE_TYPE'] }
  needs_grant_option = new_resource.grant_option && current.any? { |row| desired_privileges.include?(row['PRIVILEGE_TYPE']) && row['IS_GRANTABLE'] != 'YES' }
  unless missing.empty? && !needs_grant_option
    converge_by "Grant MySQL privileges to #{new_resource.username}@#{new_resource.host}" do
      suffix = new_resource.grant_option ? ' WITH GRANT OPTION' : ''
      client.query("GRANT #{desired_privileges.join(', ')} ON #{scope} TO #{account_name}#{suffix}")
    end
  end
end

action :revoke do
  if account
    present = granted_privileges.map { |row| row['PRIVILEGE_TYPE'] } & desired_privileges
    unless present.empty?
      converge_by "Revoke MySQL privileges from #{new_resource.username}@#{new_resource.host}" do
        client.query("REVOKE #{present.join(', ')} ON #{scope} FROM #{account_name}")
      end
    end
  end
end

action_class do
  def connection
    { user: new_resource.ctrl_user, password: new_resource.ctrl_password, host: new_resource.ctrl_host, port: new_resource.ctrl_port, socket: new_resource.ctrl_socket, ssl_mode: new_resource.ssl_mode, ssl_ca: new_resource.ssl_ca, ssl_cert: new_resource.ssl_cert, ssl_key: new_resource.ssl_key }
  end

  def client
    @client ||= MysqlCookbook::SqlClient.new(connection)
  end

  def quote(value)
    MysqlCookbook::SqlClient.quote(value)
  end

  def identifier(value)
    MysqlCookbook::SqlClient.identifier(value)
  end

  def account_name
    "#{quote(new_resource.username)}@#{quote(new_resource.host)}"
  end

  def account
    client.query("SELECT plugin, HEX(authentication_string) AS authentication_string, ssl_type FROM mysql.user WHERE User=#{quote(new_resource.username)} AND Host=#{quote(new_resource.host)}").first
  end

  def authentication
    password = new_resource.password
    return '' if password.nil?
    if password.is_a?(MysqlCookbook::HashedPassword)
      " IDENTIFIED WITH mysql_native_password AS #{quote(password)}"
    elsif new_resource.use_native_auth
      " IDENTIFIED WITH mysql_native_password BY #{quote(password)}"
    else
      " IDENTIFIED BY #{quote(password)}"
    end
  end

  def tls_requirement
    return ' REQUIRE X509' if new_resource.require_x509
    new_resource.require_ssl ? ' REQUIRE SSL' : ' REQUIRE NONE'
  end

  def password_current?(current)
    if new_resource.password.is_a?(MysqlCookbook::HashedPassword)
      return current['plugin'] == 'mysql_native_password' && current['authentication_string'] == new_resource.password.to_s.unpack1('H*').upcase
    end
    return false if new_resource.use_native_auth && current['plugin'] != 'mysql_native_password'
    return false if !new_resource.use_native_auth && current['plugin'] == 'mysql_native_password'
    if current['plugin'] == 'mysql_native_password'
      require 'digest/sha1'
      expected = new_resource.password.empty? ? '' : '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(new_resource.password)).upcase
      return current['authentication_string'] == expected.unpack1('H*').upcase
    end
    # Authenticate over the same operator-selected endpoint, never log the secret.
    MysqlCookbook::SqlClient.new(connection.merge(user: new_resource.username, password: new_resource.password)).query('SELECT CURRENT_USER() AS account').first['account'] == "#{new_resource.username}@#{new_resource.host}"
  rescue MysqlCookbook::QueryError => error
    raise unless [1045, 3118].include?(error.error_code)
    false
  end

  def scope
    raise ArgumentError, 'table requires database_name' if new_resource.table && !new_resource.database_name
    "#{new_resource.database_name ? identifier(new_resource.database_name) : '*'}.#{new_resource.table && new_resource.table != '*' ? identifier(new_resource.table) : '*'}"
  end

  def granted_privileges
    grantee = quote("'#{new_resource.username}'@'#{new_resource.host}'")
    if new_resource.table && new_resource.table != '*'
      client.query("SELECT PRIVILEGE_TYPE, IS_GRANTABLE FROM information_schema.TABLE_PRIVILEGES WHERE GRANTEE=#{grantee} AND TABLE_SCHEMA=#{quote(new_resource.database_name)} AND TABLE_NAME=#{quote(new_resource.table)}")
    elsif new_resource.database_name
      client.query("SELECT PRIVILEGE_TYPE, IS_GRANTABLE FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE=#{grantee} AND TABLE_SCHEMA=#{quote(new_resource.database_name)}")
    else
      static = client.query("SELECT PRIVILEGE_TYPE, IS_GRANTABLE FROM information_schema.USER_PRIVILEGES WHERE GRANTEE=#{grantee}")
      dynamic = client.query("SELECT PRIV AS PRIVILEGE_TYPE, IF(WITH_GRANT_OPTION='Y','YES','NO') AS IS_GRANTABLE FROM mysql.global_grants WHERE User=#{quote(new_resource.username)} AND Host=#{quote(new_resource.host)}")
      static + dynamic
    end
  end

  def desired_privileges
    supported = client.query('SHOW PRIVILEGES').map { |row| row['Privilege'].upcase }
    requested = new_resource.privileges.map do |privilege|
      value = privilege.to_s.upcase
      supported.include?(value) ? value : value.tr('_', ' ').sub(/^REPL /, 'REPLICATION ').sub('CREATE TMP TABLE', 'CREATE TEMPORARY TABLES').sub('SHOW DB', 'SHOW DATABASES')
    end
    if requested == ['ALL'] || requested == ['ALL PRIVILEGES']
      requested = if new_resource.table && new_resource.table != '*'
                    ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'REFERENCES', 'INDEX', 'ALTER', 'CREATE VIEW', 'SHOW VIEW', 'TRIGGER']
                  elsif new_resource.database_name
                    ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'REFERENCES', 'INDEX', 'ALTER', 'CREATE TEMPORARY TABLES', 'LOCK TABLES', 'CREATE VIEW', 'SHOW VIEW', 'CREATE ROUTINE', 'ALTER ROUTINE', 'EXECUTE', 'EVENT', 'TRIGGER']
                  else
                    supported - ['GRANT OPTION', 'PROXY', 'USAGE']
                  end
    end
    raise ArgumentError, 'Unknown or invalid MySQL privilege' unless (requested - supported).empty? && requested.all? { |value| value.match?(/\A[A-Z][A-Z _]*\z/) }
    requested.uniq
  end
end
