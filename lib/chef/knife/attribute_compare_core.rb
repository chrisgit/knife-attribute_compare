# Namespace to avoid clashing
# Bundle via Git http://guides.rubygems.org/publishing/
# Build https://www.digitalocean.com/community/tutorials/how-to-package-and-distribute-ruby-applications-as-a-gem-using-rubygems
module ChrisGit
  class AttributeCompare
    def initialize(klass, ui, object1_name, object2_name, config)
      @klass = klass
      @ui = ui
      @object1_name = object1_name
      @object2_name = object2_name
      @report = config[:report]
      @diff_tool = config[:diff_tool]
    end

    def run()
      validate_parameters()
      object1 = wrap(load_object(@object1_name))
      object2 = wrap(load_object(@object2_name))
      compare(object1, object2)
    end

    private

    def validate_parameters()
      validate_diff_tool()
      validate_compare_parameters()
    end

    def validate_diff_tool()
      set_report('--diff_tool parameter not specified, using --report') if @diff_tool.nil?
      @diff_tool = ChrisGit::PathHelper.sanitise_path(@diff_tool)
      set_report("The diff tool #{@diff_tool} is not found, using --report") unless File.exist?(@diff_tool)
    end

    def validate_compare_parameters()
      object_to_compare = @klass.to_s.gsub('Chef::', '').downcase
      raise format('Please enter two %ss for knife attribute compare %s', object_to_compare, object_to_compare) if @object1_name.nil? || @object2_name.nil?
    end

    def set_report(message)
      @ui.warn message
      @report = true
    end

    def compare(object1, object2)
      comparison_device = @report ? ChrisGit::DiffReport.new(object1, object2) : ChrisGit::DiffTool.new(@diff_tool, object1, object2)
      comparison_device.run
    end

    def load_object(object_name)
      @ui.info "loading #{object_name}"
      @klass.load(object_name)
      # Can throw
      # rescue NoMethodError
      #rescue Net::HTTPServerException => e
    end

    def wrap(chef_object)
      return EnvironmentAttributes.new(chef_object) if @klass == Chef::Environment
      return NodeAttributes.new(chef_object) if @klass == Chef::Node
      return RoleAttributes.new(chef_object) if @klass == Chef::Role
      nil
    end
  end

  # Wrapper to Chef Objects
  class AttributeObject
    attr_reader :attributes

    def initialize(chef_object)
      @attributes = {}
      @chef_object = chef_object
      convert_attributes_to_dot_path()
    end

    def name
      @chef_object.name
    end

    class << self
      attr_reader :property_names

      def attribute_properties(*property_names)
        @property_names ||= []
        @property_names += property_names
      end
    end

    def json_compare
      JSON.pretty_generate(@chef_object.to_hash.rsort)
    end

    def attribute_variance(other)
      return {} unless other.is_a?(AttributeObject)
      (attributes.to_a - other.attributes.to_a).to_h
    end

    def [](key)
      attributes[key]
    end

    private

    def convert_attributes_to_dot_path()
      self.class.property_names.each do |property_name|
        converted_attributes = hash_to_dot_notation(@chef_object.send(property_name))
        @attributes.merge!(converted_attributes)
      end
    end

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

  class EnvironmentAttributes < AttributeObject
    attribute_properties :default_attributes, :override_attributes
  end

  class NodeAttributes < AttributeObject
    attribute_properties :default_attrs, :normal_attrs, :override_attrs, :automatic_attrs
  end

  class RoleAttributes < AttributeObject
    attribute_properties :default_attributes, :override_attributes
  end

  class DiffReport
    def initialize(chef_object1,chef_object2)
      @chef_object1 = chef_object1
      @chef_object2 = chef_object2
    end

    def run()
      # Work out key and value differences in chef_objects
      # Intentionally not written like a diff tool, i.e. using > and < to signify differences
      object1variances = @chef_object1.attribute_variance(@chef_object2)
      object2variances = @chef_object2.attribute_variance(@chef_object1)

      # Get the intersection of the keys
      matched_keys = (object1variances.keys & object2variances.keys)
      report_value_differences(matched_keys) unless matched_keys.empty?

      in_object1_not_object2 = object1variances.keys.to_a - matched_keys
      report_missing_keys(@chef_object1.name, @chef_object2.name, in_object1_not_object2) unless in_object1_not_object2.empty?

      # In environment2 but not in environment 1
      in_object2_not_object1 = object2variances.keys.to_a - matched_keys
      report_missing_keys(@chef_object2.name, @chef_object2.name, in_object2_not_object1) unless in_object2_not_object1.empty?
    end

    private

    def report_header(report_title)
      puts format("\n%s\n%s\n%s\n", '-' * 40, report_title, '-' * 40)
    end

    def report_value_differences(comparison_keys)
      report_header 'Keys containing different values'
      comparison_keys.each do |k|
        puts format('key:%s', k)
        puts format(' - %s value: %s', @chef_object1.name, @chef_object1[k])
        puts format(' - %s value: %s', @chef_object2.name, @chef_object2[k])
      end
    end

    def report_missing_keys(primary_object, secondary_object, missing_keys)
      report_header format('Keys in %s but not in %s', primary_object, secondary_object)
      missing_keys.each do |k|
        puts k
      end
    end
  end

  class DiffTool
    def initialize(diff_tool, chef_object1, chef_object2)
      @diff_tool = diff_tool
      @chef_object1 = chef_object1
      @chef_object2 = chef_object2
    end

    def run()
      object1_file = create_diff_file(@chef_object1)
      object2_file = create_diff_file(@chef_object2)

      # Change this to call a method ... easier to make Kernel.system or backticks
      command = format('"%s" "%s" "%s"', @diff_tool, object1_file.path, object2_file.path)
      raise 'Please check the path to your diff tool' unless run_command(command)

      object1_file.unlink
      object2_file.unlink
    end

    private

    def create_diff_file(chef_object)
      filename = "knife-attribute-#{chef_object.name}"
      tf = Tempfile.new([filename, '.json'])
      tf.puts chef_object.json_compare
      tf.close
      tf
    end

    def run_command(command)
      `"#{command}"`
    end
  end
end

class ::Hash
  def rsort()
    keys.each do |key|
      self[key] = self[key].rsort if self[key].is_a?(Hash)
    end
    sort.to_h
  end
end
