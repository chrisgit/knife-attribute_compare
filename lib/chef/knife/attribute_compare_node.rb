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

        node1 = load_node(@name_args[0])
        node2 = load_node(@name_args[1])

        device = comparison_device(node1, node2)
        device.run
      end

      private

      def load_node(node)
        Chef::Node.load(node)
      end

      def comparison_device(node1, node2)
        return ChrisGit::NodeDiffReport.new(node1, node2) if @config[:report]
        ChrisGit::NodeDiffTool.new(node1, node2)
      end

    end
  end
end

class Hash
  def rsort!
    keys.each do | k |
      self[k] = self[k].rsort if self[k].is_a?(Hash)
    end
    sort.to_h
  end
end

module ChrisGit
  class ChefNodeExt < AttributeObject
    set_paths :default_attrs, :normal_attrs, :override_attrs, :automatic_attrs
  end

  class NodeDiffReport
    def initialize(node1,node2)
      @node1 = ChefNodeExt.new(node1)
      @node2 = ChefNodeExt.new(node2)
    end

    def run()
      node1variances = @node1.attribute_variance(@node2)
      node2variances = @node2.attribute_variance(@node1)

      # Get the intersection of the keys
      matched_keys = (node1variances.keys & node2variances.keys)
      report_value_differences(matched_keys) unless matched_keys.empty?

      # In node 1 but not in node 2
      in_node1_not_node2 = node1variances.keys.to_a - matched_keys
      report_missing_keys(@node1.name, @node2.name, in_node1_not_node2) unless in_node1_not_node2.empty?

      # In node 2 but not in node 1
      in_node2_not_node1 = node2variances.keys.to_a - matched_keys
      report_missing_keys(@node2.name, @node1.name, in_node2_not_node1) unless in_node2_not_node1.empty?
    end

    private

    def report_header(report_title)
      puts
      puts '-' * 40
      puts report_title
      puts '-' * 40
    end

    def report_value_differences(comparison_keys)
      report_header 'Keys containing different values'
      comparison_keys.each do |k|
        puts "key:#{k}"
        puts " - #{@node1.name} value: #{@node1[k]}"
        puts " - #{@node2.name} value: #{@node2[k]}"
      end
    end

    def report_missing_keys(primary_node, secondary_node, missing_keys)
      report_header "Keys in #{primary_node} but not in #{secondary_node}"
      missing_keys.each do |k|
        puts k
      end
    end
  end

  class NodeDiffTool
    def initialize(node1, node2)
      @node1 = node1
      @node2 = node2
    end

    def run()
      node1_attributes = node_attributes_file(@node1.rsort!)
      node2_attributes = node_attributes_file(@node2.rsort!)

      raise 'Please check the path to your diff tool' unless Kernel.system("#{config[:diff_tool]} #{node1_attributes.path} #{node2_attributes.path}")

      node1_attributes.unlink
      node2_attributes.unlink
    end

    private

    def node_attributes_file(node)
      attributes_only =
        {
          'default' => hash_to_dot_notation(node.default_attrs).sort,
          'override' => hash_to_dot_notation(node.override_attrs).sort
        }
      filename = "knife-attribute-#{node.name}"
      tf = Tempfile.new([filename, '.json'])
      tf.puts JSON.pretty_generate(attributes_only)
      tf.close
      tf
    end
  end
end
