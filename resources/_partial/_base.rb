# frozen_string_literal: true

#
# Cookbook:: mysql
# Resource:: Partial:: _base
#
# Shared properties for all mysql resources.
#

property :run_group, String, default: 'mysql', desired_state: false
property :run_user, String, default: 'mysql', desired_state: false
property :version, String, default: lazy { default_major_version }, desired_state: false
property :include_dir, String, default: lazy { default_include_dir }, desired_state: false
property :major_version, String, default: lazy { major_from_full(version) }, desired_state: false
