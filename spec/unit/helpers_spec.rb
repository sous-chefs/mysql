require_relative '../../libraries/helpers.rb'

describe 'mysql_platform_map' do
  before do
    extend Opscode::Mysql::Helpers
  end

  # rhel-5
  context 'for rhel-5' do
    context 'when looking up default version' do
      it 'returns the correct versiono' do
        expect(
          default_version_for('centos', 'rhel', '5.8')
          ).to eq('5.0')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('centos', 'rhel', '5.8', '5.0')
          ).to eq('mysql-server')
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('centos', 'rhel', '5.8', '5.1')
          ).to eq('mysql51-mysql-server')
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('centos', 'rhel', '5.8', '5.5')
          ).to eq('mysql55-mysql-server')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('centos', 'rhel', '5.8', '5.6')
          ).to eq(nil)
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('rhel')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # rhel-6
  context 'for rhel-6' do
    context 'when looking up default version' do
      it 'returns the correct version for Mysql 5.0' do
        expect(
          default_version_for('centos', 'rhel', '6.4')
          ).to eq('5.1')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('centos', 'rhel', '6.4', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('centos', 'rhel', '6.4', '5.1')
          ).to eq('mysql-server')
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('centos', 'rhel', '6.4', '5.5')
          ).to eq('mysql-community-server')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('centos', 'rhel', '6.4', '5.6')
          ).to eq('mysql-community-server')
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('rhel')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # amazon-13.09
  context 'for amazon-2013.09' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('amazon', 'rhel', '2013.09')
          ).to eq('5.1')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('amazon', 'rhel', '2013.09', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('amazon', 'rhel', '2013.09', '5.1')
          ).to eq('mysql-community-server')
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('amazon', 'rhel', '2013.09', '5.5')
          ).to eq('mysql-community-server')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('amazon', 'rhel', '2013.09', '5.6')
          ).to eq('mysql-community-server')
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('rhel')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # fedora-19
  context 'for fedora-19' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('fedora', 'fedora', '19')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('fedora', 'fedora', '19', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('fedora', 'fedora', '19', '5.1')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('fedora', 'fedora', '19', '5.5')
          ).to eq('community-mysql-server')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('fedora', 'fedora', '19', '5.6')
          ).to eq(nil)
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('fedora')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # debian-7
  context 'for debian-7' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('debian', 'debian', '7.2')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('debian', 'debian', '7.2', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('debian', 'debian', '7.2', '5.1')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('debian', 'debian', '7.2', '5.5')
          ).to eq('mysql-server-5.5')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('debian', 'debian', '7.2', '5.6')
          ).to eq(nil)
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('debian')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # ubuntu-10.04
  context 'for ubuntu-10.04' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('ubuntu', 'debian', '10.04')
          ).to eq('5.1')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('ubuntu', 'debian', '10.04', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('ubuntu', 'debian', '10.04', '5.1')
          ).to eq('mysql-server-5.1')
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('ubuntu', 'debian', '10.04', '5.5')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('ubuntu', 'debian', '10.04', '5.6')
          ).to eq(nil)
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('debian')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # ubuntu-12.04
  context 'for ubuntu-12.04' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('ubuntu', 'debian', '12.04')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('ubuntu', 'debian', '12.04', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('ubuntu', 'debian', '12.04', '5.1')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('ubuntu', 'debian', '12.04', '5.5')
        ).to eq('mysql-server-5.5')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('ubuntu', 'debian', '12.04', '5.6')
          ).to eq(nil)
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('debian')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # ubuntu-13.10
  context 'for ubuntu-13.10' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('ubuntu', 'debian', '13.10')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('ubuntu', 'debian', '13.10', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('ubuntu', 'debian', '13.10', '5.1')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('ubuntu', 'debian', '13.10', '5.5')
          ).to eq('mysql-server-5.5')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('ubuntu', 'debian', '13.10', '5.6')
          ).to eq(nil)
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('debian')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # ubuntu-14.04
  context 'for ubuntu-14.04' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('ubuntu', 'debian', '14.04')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('ubuntu', 'debian', '14.04', '5.5')
          ).to eq('mysql-server-5.5')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('ubuntu', 'debian', '14.04', '5.6')
          ).to eq('mysql-server-5.6')
      end
    end
  end

  # smartos-5.11
  context 'for smartos-5.11' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('smartos', 'smartos', '5.11')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('smartos', 'smartos', '5.11', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('smartos', 'smartos', '5.11', '5.1')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('smartos', 'smartos', '5.11', '5.5')
          ).to eq('mysql-server')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('smartos', 'smartos', '5.11', '5.6')
          ).to eq('mysql-server')
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('debian')
          ).to eq('/var/lib/mysql')
      end
    end
  end

  # omnios-151006
  context 'for omnios-151006' do
    context 'when looking up default version' do
      it 'returns the correct version' do
        expect(
          default_version_for('omnios', 'omnios', '151006')
          ).to eq('5.5')
      end
    end

    context 'when looking up package' do
      it 'returns the correct package for Mysql 5.0' do
        expect(
          package_name_for('omnios', 'omnios', '151006', '5.0')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.1' do
        expect(
          package_name_for('omnios', 'omnios', '151006', '5.1')
          ).to eq(nil)
      end

      it 'returns the correct package for Mysql 5.5' do
        expect(
          package_name_for('omnios', 'omnios', '151006', '5.5')
          ).to eq('database/mysql-55')
      end

      it 'returns the correct package for Mysql 5.6' do
        expect(
          package_name_for('omnios', 'omnios', '151006', '5.6')
          ).to eq('database/mysql-56')
      end
    end

    context 'when looking up data_dir' do
      it 'returns the correct data_dir' do
        expect(
          default_data_dir_for('debian')
          ).to eq('/var/lib/mysql')
      end
    end

    context 'when looking up service_name on rhel' do
      it 'returns the correct service_name for Mysql 5.0' do
        expect(
          service_name_for('centos', 'rhel', '5.8', '5.0')
          ).to eq('mysqld')
      end

      it 'returns the correct service_name for Mysql 5.1' do
        expect(
          service_name_for('centos', 'rhel', '5.8', '5.1')
          ).to eq('mysql51-mysqld')
      end

      it 'returns the correct service_name for Mysql 5.5' do
        expect(
          service_name_for('centos', 'rhel', '5.8', '5.5')
          ).to eq('mysql55-mysqld')
      end
    end
  end
end
