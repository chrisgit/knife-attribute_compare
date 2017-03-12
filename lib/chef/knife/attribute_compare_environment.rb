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
        runner = ChrisGit::AttributeCompare.new(Chef::Environment, ui, @name_args[0], @name_args[1], config)
        runner.run
      end
    end
  end
end
