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

      def run
        raise 'Please specify :diff_tool in knife config or use --report' unless @config[:report] || @config[:diff_tool] 
        raise 'Please enter two ENVIRONMENTS for knife attribute compare' if @name_args.count != 2

        environment1 = load_environment(@name_args[0])
        environment2 = load_environment(@name_args[1])

        if @config[:report]
          comparison_report(environment1, environment2)
        else
          # extract attributes for diff tool
        end
      end

      private

      def load_environment(environment)
        Chef::Environment.load(environment)
      end

      def hash_to_dot_notation(object, prefix = nil)
        if (object.is_a?(Chef::Node) || object.is_a?(Hash)) && !(object.empty?)
          object.map do |key, value|
          if prefix
            hash_to_dot_notation value, "#{prefix}.#{key}"
          else
             hash_to_dot_notation value, key.to_s
          end
        end.reduce(&:merge) # .reduce(&:merge)
        else
          {prefix => object}
        end
      end

      def comparison_report(environment1, environment2)
        unless environment1.override_attributes.empty? && environment2.override_attributes.empty?
          report_header 'Override attributes'
          environment1_overrides = hash_to_dot_notation(environment1.override_attributes)
          environment2_overrides = hash_to_dot_notation(environment2.override_attributes)
          report(environment1, environment1_overrides, environment2, environment2_overrides)
        end
        unless environment1.default_attributes.empty? && environment2.default_attributes.empty? 
          report_header 'Default attributes'
          environment1_default = hash_to_dot_notation(environment1.default_attributes)
          environment2_default = hash_to_dot_notation(environment2.default_attributes)
          report(environment1, environment1_default, environment2, environment2_default)
        end
      end

      def report_header(report_title)
        puts
        puts '-' * 40
        puts report_title
        puts '-' * 40
      end

      def report_value_differences(comparison_keys, environment1, attributes1, environment2, attributes2)
        report_header 'Keys containing different values'
        comparison_keys.each do |k|
          puts "key:#{k}"
          puts " - #{environment1.name} value: #{attributes1[k]}"
          puts " - #{environment2.name} value: #{attributes2[k]}"
        end
      end

      def report_missing_keys(primary_environment, secondary_environment, missing_keys)
        report_header "Keys in #{primary_environment} but not in #{secondary_environment}"
        missing_keys.each do |k|
          puts k
        end
      end

      def report(environment1, attributes1, environment2, attributes2)
        env1primary = (attributes1.to_a - attributes2.to_a).to_h
        env2primary = (attributes2.to_a - attributes1.to_a).to_h
        # Matching keys, value variances
        # method: report_value_differences
        matched_keys = env1primary.keys.select { |k| env2primary.key?(k) }
        report_value_differences(matched_keys, environment1, env1primary, environment2, env2primary)
        # In environment1 but not in environment 2
        in_env1_not_env2 = env1primary.keys.reject { |k,_v| matched_keys.include?(k) }
        report_missing_keys(environment1, environment2, in_env1_not_env2)
        in_env2_not_env1 = env2primary.keys.reject { |k,_v| matched_keys.include?(k) }
        report_missing_keys(environment2, environment1, in_env2_not_env1)
      end
    end
  end
end
