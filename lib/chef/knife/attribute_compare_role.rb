require 'chef/knife'
require_relative 'attribute_compare_core'

class Chef
  class Knife
    # Compare attributes for Chef Roles
    class AttributeCompareRole < Knife
      deps do
        require 'chef/node'
      end

      banner 'knife attribute compare role [ROLE1] [ROLE2] (options)'

      option :report,
        :long => '--report',
        :description => 'Show report',
        :boolean => true

      option :diff_tool,
        :long => '--diff_tool EDITOR',
        :description => 'Diff tool to use'

      def run
        runner = ChrisGit::AttributeCompare.new(Chef::Role, ui, @name_args[0], @name_args[1], config)
        runner.run
      end
    end
  end
end
