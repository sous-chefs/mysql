require 'chef/resource/lwrp_base'

#
class Chef::Resource::MysqlService < Chef::Resource

  def initialize(name=nil, run_context=nil)
    super
    @resource_name = :mysql_service
    @allowed_actions = [ :create ]
    @action = :create
    @provider = Chef::Provider::MysqlService

    @service_name = name
    @version = nil
    @port = '3306'
    @package_name = nil
    @data_dir = '/var/lib/mysql'
  end

  def service_name(arg = nil)
     set_or_return(:service_name, arg, :kind_of => String)
  end

  def version(arg = nil)
    set_or_return(:version, arg, :kind_of => String)
  end

  def package_name(arg = nil)
    set_or_return(:package_name, arg, :kind_of => String)
  end
 
  def data_dir(arg = nil)
    set_or_return(:data_dir, arg, :kind_of => String)
  end

  def port(arg = nil)
    set_or_return(
      :port,
      arg,
      :kind_of => String,
      :callbacks => {
        'should be a valid non-system port' => lambda { |p| Chef::Resource::MysqlService.validate_port(p) }
      }
      )    
  end
  
  private
  
  def self.validate_port(port)
    port.to_i > 1024 && port.to_i < 65_535
  end

end
