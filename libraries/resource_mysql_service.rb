require 'chef/resource/lwrp_base'

#
class Chef::Resource::MysqlService < Chef::Resource::LWRPBase
  self.resource_name = 'mysql_service'

  actions :create, :enable
  attribute :name, :kind_of => String, :required => true
  attribute :version, :kind_of => String
  attribute :package_name, :kind_of => String
  attribute :port, :kind_of => String, :callbacks => {
    'should be a valid non-system port' => lambda { |p| Chef::Resource::MysqlService.validate_port(p) }
  }
  attribute :data_dir, :kind_of => String

  private

  def self.validate_port(port)
    port.to_i > 1024 && port.to_i < 65_535
  end

end
