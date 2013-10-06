def query(sql)
  cmd_prefix = test_client_host ? "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@#{test_client_host}" : ''
  result = %x{echo "#{sql}" | #{cmd_prefix} mysql --host=#{test_server_host} --user=#{test_user} --password=#{test_password} --skip-column-names #{test_database}}
  assert $?.success? # rubocop:disable SpecialGlobalVars
  result
end
alias_method :insert, :query
alias_method :update, :query
alias_method :delete, :query

attr_reader :tv_chefs

def delete_chef(name)
  delete("DELETE FROM tv_chef WHERE name = '#{name}'")
end

def insert_chef(name)
  insert("INSERT INTO tv_chef (name) VALUES('#{name}')")
end

def select_tv_chefs
  @tv_chefs = query('SELECT name FROM tv_chef ORDER BY name').split("\n")
  @tv_chefs
end

def test_client_host
  ENV['TEST_CLIENT_HOST']
end

def test_database
  'mysql_test'
end

def test_server_host
  ENV['TEST_SERVER_HOST'] || 'localhost'
end

def test_password
  'neshFiapog'
end

def test_user
  'test_user'
end

def update_chef_name(old_name, new_name)
  update("UPDATE tv_chef SET name = '#{new_name}' WHERE name = '#{old_name}'")
end
