require 'chef/knife'
require_relative 'attribute_compare_core'

class Chef
  class Knife
    # Compare attributes for Chef environments
    class AttributeCompareEnvironment < Knife
      deps do
        require 'chef/environment'
      end

      banner 'knife attribute compare environment [ENVIRONMENT1] [ENVIRONMENT2] (options)'

      option :report,
        :long => '--report',
        :description => 'Show report',
        :boolean => true

      option :diff_tool,
        :long => '--diff_tool EDITOR',
        :description => 'Diff tool to use'

      def run
        if @config[:diff_tool].nil?
          puts '--diff_tool not specified, using --report'
          config[:report] = true
        end
        raise 'Please enter two ENVIRONMENTS for knife attribute compare environment' if @name_args.count != 2

        environment1 = ChefHelper.load_object(Chef::Environment, @name_args[0])
        environment2 = ChefHelper.load_object(Chef::Environment, @name_args[1])

        device = comparison_device(environment1, environment2)
        device.run
      end

      private

      def comparison_device(environment1, environment2)
        wrapped_environment1 = ChrisGit::ChefEnvironmentExt.new(environment1)
        wrapped_environment2 = ChrisGit::ChefEnvironmentExt.new(environment2)
        return ChrisGit::DiffReport.new(wrapped_environment1, wrapped_environment2) if @config[:report]
        ChrisGit::DiffTool.new(config[:diff_tool], wrapped_environment1, wrapped_environment2)
      end

    end
  end
end

module ChrisGit
  class ChefEnvironmentExt < AttributeObject
    set_paths :default_attributes, :override_attributes
  end
end
