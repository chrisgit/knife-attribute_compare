# Namespace to avoid clashing
module ChrisGit
  # Wrapper to Chef Objects
  class AttributeObject
    def initialize(chef_object)
      @chef_object = chef_object
      convert_attributes()
    end

    def name
      @chef_object.name
    end

    def self.set_paths(*paths)
      @paths ||= []
      @paths += paths
    end

    class << self; attr_reader :paths end

    def json_compare
      JSON.pretty_generate(@chef_object.to_hash.rsort)
    end

    def attributes_path
      @attributes_path ||= begin
        self.class.paths.each_with_object({}) do |path,hsh|
          hsh.merge!(instance_variable_get("@#{path}"))
        end
      end
    end

    def attribute_variance(other)
      return {} unless other.is_a?(AttributeObject)
      (attributes_path.to_a - other.attributes_path.to_a).to_h
    end

    def [](key)
      attributes_path[key]
    end

    def where(key)
      key_found_in = nil
      self.class.paths.reverse.each do |path|
        value = instance_variable_get("@#{path}")[key]
        unless value.nil?
          key_found_in = path
          break
        end
      end
      key_found_in
    end

    private

    def convert_attributes
      self.class.paths.each do |path|
        converted_attributes = hash_to_dot_notation(@chef_object.send(path))
        instance_variable_set("@#{path}", converted_attributes)
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
      puts
      puts '-' * 40
      puts report_title
      puts '-' * 40
    end

    def report_value_differences(comparison_keys)
      report_header 'Keys containing different values'
      comparison_keys.each do |k|
        puts "key:#{k}"
        puts " - #{@chef_object1.name} value: #{@chef_object1[k]}"
        puts " - #{@chef_object2.name} value: #{@chef_object2[k]}"
      end
    end

    def report_missing_keys(primary_object, secondary_object, missing_keys)
      report_header "Keys in #{primary_object} but not in #{secondary_object}"
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

      raise 'Please check the path to your diff tool' unless Kernel.system("#{@diff_tool} #{object1_file.path} #{object2_file.path}")

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
  end
end

class ::Hash
  def rsort()
    keys.each do | k |
      self[k] = self[k].rsort if self[k].is_a?(Hash)
    end
    sort.to_h
  end
end

class ChefHelper
  def self.load_object(klass, name)
    klass.load(name)
    # Can throw
    # rescue NoMethodError
    #rescue Net::HTTPServerException => e
  end
end