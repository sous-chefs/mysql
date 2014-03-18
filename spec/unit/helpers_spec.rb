require_relative '../../libraries/helpers.rb'

describe 'mysql_platform_map' do

  context 'for rhel-5' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['5']['5.0']
        ).to eq('mysql-server')
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['5']['5.1']
        ).to eq('mysql51-mysql-server')
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['5']['5.5']
        ).to eq('mysql55-mysql-server')
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['5']['5.6']
        ).to eq(nil)
    end
  end

  context 'for rhel-6' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['6']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['6']['5.1']
        ).to eq('mysql-server')
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['6']['5.5']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['rhel']['6']['5.6']
        ).to eq(nil)
    end
  end

  context 'for amazon-2013.09' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['amazon']['2013.09']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['amazon']['2013.09']['5.1']
        ).to eq('mysql-server')
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['amazon']['2013.09']['5.5']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['amazon']['2013.09']['5.6']
        ).to eq(nil)
    end
  end

  context 'for fedora-19' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['fedora']['19']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['fedora']['19']['5.1']
        ).to eq('community-mysql-server')
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['fedora']['19']['5.5']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['fedora']['19']['5.6']
        ).to eq(nil)
    end
  end

  context 'for debian-7' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['debian']['7']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['debian']['7']['5.1']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['debian']['7']['5.5']
        ).to eq('mysql-server-5.5')
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['debian']['7']['5.6']
        ).to eq(nil)
    end
  end

  context 'for ubuntu-10.04' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['10.04']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['10.04']['5.1']
        ).to eq('mysql-server-5.1')
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['10.04']['5.5']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['10.04']['5.6']
        ).to eq(nil)
    end
  end

  context 'for ubuntu-12.04' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['12.04']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['12.04']['5.1']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['12.04']['5.5']
        ).to eq('mysql-server-5.5')
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['12.04']['5.6']
        ).to eq(nil)
    end
  end

  context 'for ubuntu-13.10' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['13.10']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['13.10']['5.1']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['13.10']['5.5']
        ).to eq('mysql-server-5.5')
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['ubuntu']['13.10']['5.6']
        ).to eq(nil)
    end
  end

  context 'for smartos-1303' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['smartos']['1303']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['smartos']['1303']['5.1']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['smartos']['1303']['5.5']
        ).to eq('mysql-server-5.5')
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['smartos']['1303']['5.6']
        ).to eq('mysql-server-5.6')
    end
  end

  context 'for omnios-151006' do
    it 'returns the package for Mysql 5.0' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['omnios']['151006']['5.0']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.1' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['omnios']['151006']['5.1']
        ).to eq(nil)
    end

    it 'returns the package for Mysql 5.5' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['omnios']['151006']['5.5']
        ).to eq('database/mysql-55')
    end

    it 'returns the package for Mysql 5.6' do
      expect(
        Opscode::Mysql::Helpers::MysqlPackageMap.mysql_package_map['omnios']['151006']['5.6']
        ).to eq('database/mysql-56')
    end
  end
end
