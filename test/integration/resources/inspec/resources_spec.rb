control 'mysql_database' do
  impact 1.0
  title 'test creation and removal of databases'
  sql = mysql_session('root','arandompassword')

  describe sql.query('show databases') do
    its(:stdout) { should match(/databass/) }
    its(:stdout) { should_not match(/datatrout/) }
  end
end

control 'mysql_user' do
  impact 1.0
  title 'test creation, granting and removal of users'
  version = input('version')
  password_column = version.to_f >= 5.7 ? 'authentication_string' : 'password'

  sql = mysql_session('root','arandompassword')

  describe sql.query('select User,Host from mysql.user') do
    its(:stdout) { should match(/fozzie/) }
    its(:stdout) { should_not match(/kermit/) }
  end

  describe sql.query("SELECT #{password_column} FROM mysql.user WHERE user='fozzie' AND host='mars'") do
    its(:stdout) { should include '*EF112B3D562CB63EA3275593C10501B59C4A390D' }
  end

  describe sql.query("SELECT #{password_column} FROM mysql.user WHERE user='moozie' AND host='127.0.0.1'") do
    its(:stdout) { should include '*F798E7C0681068BAE3242AA2297D2360DBBDA62B' }
  end

  sql2 = mysql_session('moozie', 'zokkazokka', '127.0.0.1')

  describe sql2.query('show tables from databass') do
    its(:exit_status) { should eq 0 }
  end

  describe sql.query("SELECT #{password_column} FROM mysql.user WHERE user='rowlf' AND host = 'localhost'") do
    its(:stdout) { should include '*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9' }
  end

  describe sql.query("SELECT #{password_column} FROM mysql.user WHERE user='statler' AND host='localhost'") do
    its(:stdout) { should include '*2027D9391E714343187E07ACB41AE8925F30737E' }
  end

  describe sql.query('select Host from mysql.user where User like \'gonzo\'') do
    its(:stdout) { should include '10.10.10.%' }
  end

  describe sql.query("SELECT #{password_column} FROM mysql.user WHERE user='rizzo' AND host='127.0.0.1'") do
    its(:stdout) { should include '*125EA03B506F7C876D9321E9055F37601461E970' }
  end
end
