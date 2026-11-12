# frozen_string_literal: true

name 'mysql'
run_list 'test::default'
cookbook 'mysql', path: '.'
cookbook 'test', path: './test/cookbooks/test'
