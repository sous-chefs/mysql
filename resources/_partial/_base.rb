# frozen_string_literal: true

property :run_group, String, default: 'mysql', desired_state: false
property :run_user, String, default: 'mysql', desired_state: false
property :version, String, default: '8.4', desired_state: false
property :major_version, String, default: lazy { version.split('.').first(2).join('.') }, desired_state: false
property :include_dir, String, default: lazy { default_include_dir }, desired_state: false

include MysqlCookbook::HelpersBase
