require 'chef/knife'
require_relative 'attribute_compare_core'

class Chef
  class Knife
    # Compare attributes for Chef Nodes
    class AttributeCompareNode < Knife
      deps do
        require 'chef/node'
      end

      banner 'knife attribute compare node [NODE1] [NODE2] (options)'

      option :report,
        :long => '--report',
        :description => 'Show report',
        :boolean => true

      option :diff_tool,
        :long => '--diff_tool EDITOR',
        :description => 'Diff tool to use'

      def run
        runner = ChrisGit::AttributeCompare.new(Chef::Node, ui, @name_args[0], @name_args[1], config)
        runner.run
      end
    end
  end
end
