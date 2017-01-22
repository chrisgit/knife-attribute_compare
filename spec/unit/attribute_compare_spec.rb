require 'spec_helper'

describe 'ChrisGit' do
  describe 'ChefEnvironmentExt' do
    describe '#attribute_variance' do
      let(:fake_node_class) { Class.new }
      describe 'when both objects attributes match' do
        it 'returns empty hash' do
          stub_const('Chef::Node', fake_node_class)
          environment = double()
          allow(environment).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES)
          env_one = ChrisGit::ChefEnvironmentExt.new(environment)
          env_two = ChrisGit::ChefEnvironmentExt.new(environment)

          expect(env_one.attribute_variance(:default_attributes, env_two)).to eq({})
        end
      end
      describe 'when hash keys of both objects match but values do not' do
        it 'returns keys and values that do not match' do
          stub_const('Chef::Node', fake_node_class)
          production = double()
          allow(production).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES)

          production_other = double()
          allow(production_other).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES_DIFFERENT_VALUES)

          env_one = ChrisGit::ChefEnvironmentExt.new(production)
          env_two = ChrisGit::ChefEnvironmentExt.new(production_other)

          variance = { 'chef-server.version' => '1.0.0', 'chef-server.configuration.nginx.port' => 4433 }
          expect(env_one.attribute_variance(:default_attributes, env_two)).to eq(variance)
        end
      end

      describe 'when hash keys do not match' do
        describe 'when the primary object has more keys' do
          it 'returns keys and values in the primary object that do not exist in the other object' do
            stub_const('Chef::Node', fake_node_class)
            production = double()
            allow(production).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES)

            production_other = double()
            allow(production_other).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES_LESS_KEYS)

            env_one = ChrisGit::ChefEnvironmentExt.new(production)
            env_two = ChrisGit::ChefEnvironmentExt.new(production_other)

            variance = { 'chef-server.configuration.nginx.port' => 4433 }
            expect(env_one.attribute_variance(:default_attributes, env_two)).to eq(variance)
          end
        end

        describe 'when the primary object has less keys' do
          it 'returns an empty hash' do
            stub_const('Chef::Node', fake_node_class)
            production = double()
            allow(production).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES_LESS_KEYS)

            production_other = double()
            allow(production_other).to receive(:default_attributes).and_return(PRODUCTION_DEFAULT_ATTRIBUTES)
            env_one = ChrisGit::ChefEnvironmentExt.new(production)
            env_two = ChrisGit::ChefEnvironmentExt.new(production_other)

            expect(env_one.attribute_variance(:default_attributes, env_two)).to eq({})
          end
        end
      end
    end
  end
end
