require 'spec_helper'
describe 'hiera_vault' do
  context 'with default values for all parameters' do
    it { should contain_class('hiera_vault') }
  end
end
