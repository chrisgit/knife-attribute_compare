require 'spec_helper'

describe 'ChrisGit' do
  describe 'ChefEnvironmentExt' do
    describe '#attribute_variance' do
      let(:fake_node_class) { Class.new }
      let(:test_environment) do
        test_environment = double()
        allow(test_environment).to receive(:default_attributes).and_return(TEST_ENVIRONMENT_DEFAULT_ATTRIBUTES)
        allow(test_environment).to receive(:override_attributes).and_return({})
        test_environment
      end
      let(:staging_environment) do
        staging_environment = double()
        allow(staging_environment).to receive(:default_attributes).and_return(STAGING_ENVIRONMENT_DEFAULT_ATTRIBUTES)
        allow(staging_environment).to receive(:override_attributes).and_return({})
        staging_environment
      end
      let(:preproduction_environment) do
        preproduction_environment = double()
        allow(preproduction_environment).to receive(:default_attributes).and_return(PREPROD_ENVIRONMENT_DEFAULT_ATTRIBUTES)
        allow(preproduction_environment).to receive(:override_attributes).and_return({})
        preproduction_environment
      end

      describe 'when both objects attributes match' do
        it 'returns empty hash' do
          stub_const('Chef::Node', fake_node_class)
          env_one = ChrisGit::EnvironmentAttributes.new(test_environment)
          env_two = ChrisGit::EnvironmentAttributes.new(test_environment)

          expect(env_one.attribute_variance(env_two)).to eq({})
        end
      end

      describe 'when hash keys of both objects match but values do not' do
        it 'returns keys and values that do not match' do
          stub_const('Chef::Node', fake_node_class)

          env_one = ChrisGit::EnvironmentAttributes.new(test_environment)
          env_two = ChrisGit::EnvironmentAttributes.new(staging_environment)

          variance = { 'chef-server.version' => '1.0.0', 'chef-server.configuration.nginx.port' => 4433 }
          expect(env_one.attribute_variance(env_two)).to eq(variance)
        end
      end

      describe 'when hash keys do not match' do
        describe 'when the primary object has more keys' do
          it 'returns keys and values in the primary object that do not exist in the other object' do
            stub_const('Chef::Node', fake_node_class)

            env_one = ChrisGit::EnvironmentAttributes.new(test_environment)
            env_two = ChrisGit::EnvironmentAttributes.new(preproduction_environment)

            variance = { 'chef-server.configuration.nginx.port' => 4433 }
            expect(env_one.attribute_variance(env_two)).to eq(variance)
          end
        end

        describe 'when the primary object has less keys' do
          it 'returns an empty hash' do
            stub_const('Chef::Node', fake_node_class)

            env_one = ChrisGit::EnvironmentAttributes.new(preproduction_environment)
            env_two = ChrisGit::EnvironmentAttributes.new(test_environment)

            expect(env_one.attribute_variance(env_two)).to eq({})
          end
        end
      end
    end
  end
end
