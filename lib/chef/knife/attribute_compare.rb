require 'chef/knife'

class Chef
  class Knife
    # Compare attributes for Chef environments
    class AttributeCompare < Knife
      deps do
        require 'chef/environment'
      end

      banner 'knife attribute compare [ENVIRONMENT1] [ENVIRONMENT2] (options)'

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
        raise 'Please enter two ENVIRONMENTS for knife attribute compare' if @name_args.count != 2

        environment1 = load_environment(@name_args[0])
        environment2 = load_environment(@name_args[1])

        device = comparison_device(environment1, environment2)
        device.run
      end

      private

      def load_environment(environment)
        Chef::Environment.load(environment)
      end

      def comparison_device(environment1, environment2)
        return ChrisGit::EnvironmentDiffReport.new(environment1, environment2) if @config[:report]
        ChrisGit::EnvironmentDiffTool.new(environment1, environment2)
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
  class ChefEnvironmentExt
    def initialize(chef_environment)
      @environment = chef_environment
    end

    def name
      @environment.name
    end

    def attribute_variance(attribute_type, other)
      return nil unless other.is_a?(ChefEnvironmentExt)
      method = "#{attribute_type}_path".to_sym
      this_attr = send(method)
      other_attr = other.send(method)
      (this_attr.to_a - other_attr.to_a).to_h
    end

    def value_for(attribute_type, key)
      method = "#{attribute_type}_path".to_sym
      send(method)[key]
    end

    def default_attributes_path
      @default_attributes_path ||= begin
        hash_to_dot_notation(@environment.default_attributes)
      end
    end

    def override_attributes_path
      @override_attributes_path ||= begin
        hash_to_dot_notation(@environment.override_attributes)
      end
    end

    private

    def hash_to_dot_notation(object, prefix = nil)
      if (object.is_a?(Chef::Node) || object.is_a?(Hash)) && !(object.empty?)
        object.map do |key, value|
          descend_key = prefix ? "#{prefix}.#{key}" : key.to_s
          hash_to_dot_notation value, descend_key
        end.reduce(&:merge)
      else
        { prefix => object }
      end
    end

  end

  class EnvironmentDiffReport
    def initialize(environment1,environment2)
      @environment1 = ChefEnvironmentExt.new(environment1)
      @environment2 = ChefEnvironmentExt.new(environment2)
    end

    def run()
      report_attributes(:override_attributes)
      report_attributes(:default_attributes)
    end

    private

    def report_header(report_title)
      puts
      puts '-' * 40
      puts report_title
      puts '-' * 40
    end

    def report_value_differences(attribute_type, comparison_keys)
      report_header 'Keys containing different values'
      comparison_keys.each do |k|
        puts "key:#{k}"
        puts " - #{@environment1.name} value: #{@environment1.value_for(attribute_type, k)}"
        puts " - #{@environment2.name} value: #{@environment2.value_for(attribute_type, k)}"
      end
    end

    def report_missing_keys(primary_environment, secondary_environment, missing_keys)
      report_header "Keys in #{primary_environment} but not in #{secondary_environment}"
      missing_keys.each do |k|
        puts k
      end
    end

    def report_attributes(attribute_type)

      # Work out key and value differences in environments
      env1variances = @environment1.attribute_variance(attribute_type, @environment2)
      env2variances = @environment2.attribute_variance(attribute_type, @environment1)

      # Get the intersection of the keys
      matched_keys = (env1variances.keys & env2variances.keys)
      report_value_differences(attribute_type, matched_keys) unless matched_keys.empty?

      # In environment1 but not in environment 2
      in_env1_not_env2 = env1variances.keys.to_a - matched_keys
      report_missing_keys(@environment1.name, @environment2.name, in_env1_not_env2) unless in_env1_not_env2.empty?

      # In environment2 but not in environment 1
      in_env2_not_env1 = env2variances.keys.to_a - matched_keys
      report_missing_keys(@environment2.name, environment1.name, in_env2_not_env1) unless in_env2_not_env1.empty?
    end
  end

  class EnvironmentDiffTool
    def initialize(environment1, environment2)
      @environment1 = environment1
      @environment2 = environment2
    end

    def run()
      environment1_attributes = environment_attributes_file(@environment1.rsort!)
      environment2_attributes = environment_attributes_file(@environment2.rsort!)

      raise 'Please check the path to your diff tool' unless Kernel.system("#{config[:diff_tool]} #{environment1_attributes.path} #{environment2_attributes.path}")

      environment1_attributes.unlink
      environment2_attributes.unlink
    end

    private

    def environment_attributes_file(environment)
      # attributes_only = { 'override': environment.override_attributes.sort, 'default': environment.default_attributes.sort }
      attributes_only =
        {
          'override' => hash_to_dot_notation(environment.override_attributes).sort,
          'default' => hash_to_dot_notation(environment.default_attributes).sort
        }
      filename = "knife-attribute-#{environment.name}"
      tf = Tempfile.new([filename, '.json'])
      tf.puts JSON.pretty_generate(attributes_only)
      tf.close
      tf
    end
  end
end
