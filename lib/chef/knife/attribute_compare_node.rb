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
        if @config[:diff_tool].nil?
          puts '--diff_tool not specified, using --report'
          config[:report] = true
        end
        raise 'Please enter two NODES for knife attribute compare node' if @name_args.count != 2

        node1 = ChefHelper.load_object(Chef::Node, @name_args[0])
        node2 = ChefHelper.load_object(Chef::Node, @name_args[1])

        device = comparison_device(node1, node2)
        device.run
      end

      private

      def comparison_device(node1, node2)
        wrapped_node1 = ChrisGit::ChefNodeExt.new(node1)
        wrapped_node2 = ChrisGit::ChefNodeExt.new(node2)
        return ChrisGit::DiffReport.new(wrapped_node1, wrapped_node2) if @config[:report]
        ChrisGit::DiffTool.new(config[:diff_tool], node1, node2)
      end

    end
  end
end

module ChrisGit
  class ChefNodeExt < AttributeObject
    set_paths :default_attrs, :normal_attrs, :override_attrs, :automatic_attrs
  end

end
