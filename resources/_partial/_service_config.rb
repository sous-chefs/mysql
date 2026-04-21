# frozen_string_literal: true

#
# Cookbook:: mysql
# Resource:: Partial:: _service_config
#
# Shared properties for mysql_service and related resources.
#

property :bind_address, String, desired_state: false
property :charset, String, default: 'utf8', desired_state: false
property :data_dir, String, default: lazy { default_data_dir }, desired_state: false
property :error_log, String, default: lazy { default_error_log }, desired_state: false
property :initial_root_password, String, default: 'ilikerandompasswords', desired_state: false
property :instance, String, name_property: true, desired_state: false
property :mysqld_options, Hash, default: {}, desired_state: false
property :pid_file, String, default: lazy { default_pid_file }, desired_state: false
property :port, [String, Integer], default: '3306', desired_state: false
property :socket, String, default: lazy { default_socket_file }, desired_state: false
property :tmp_dir, String, desired_state: false

# Templates reference @config.socket_file — provide an alias on the resource
alias_method :socket_file, :socket

# Template references @config.lc_messages_dir — unused but must respond
def lc_messages_dir
  nil
end
