# Before that, we use "native" versions

unless node['mysql_test'].nil?
  yum_mysql_community_repo 'mysql_repo' do
    version node['mysql_test']['version']
  end
end
