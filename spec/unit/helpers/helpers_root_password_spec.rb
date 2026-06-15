# frozen_string_literal: true

require 'spec_helper'
require 'shellwords'
require 'json'
require 'tempfile'
require_relative '../../../libraries/helpers'

RSpec.describe MysqlCookbook::HelpersBase do
  let(:helper) do
    Object.new.extend(described_class)
  end

  describe '#root_password' do
    before do
      allow(helper).to receive(:etc_dir).and_return(Dir.mktmpdir)
    end

    after do
      FileUtils.rm_rf(helper.etc_dir)
    end

    context 'when .root_password file exists' do
      before do
        File.write("#{helper.etc_dir}/.root_password", 'captured_random_pw')
      end

      it 'reads the password from the file' do
        expect(helper.root_password).to eq('captured_random_pw')
      end

      it 'ignores initial_root_password when file exists' do
        allow(helper).to receive(:initial_root_password).and_return('user_provided')
        expect(helper.root_password).to eq('captured_random_pw')
      end
    end

    context 'when .root_password file does not exist' do
      it 'returns empty string' do
        expect(helper.root_password).to eq('')
      end
    end
  end
end
