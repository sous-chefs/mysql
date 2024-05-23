module MysqlCookbook
  class MysqlBase < Chef::Resource
    require_relative 'helpers'

    # All resources are composites

    ################
    # Type Constants
    ################

    Boolean = property_type(
      is: [true, false],
      default: false
    ) unless defined?(Boolean)

    ###################
    # Common Properties
    ###################
    property :run_group, String, default: 'mysql', desired_state: false
    property :run_user, String, default: 'mysql', desired_state: false
    property :version, String, default: '8.0', desired_state: false
    property :include_dir, String, default: lazy { default_include_dir }, desired_state: false
    property :major_version, String, default: lazy { major_from_full(version) }, desired_state: false

    action_class
  end
end
