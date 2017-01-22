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
end

class Hash
  def rsort!
    keys.each do | k |
      self[k] = self[k].rsort if self[k].is_a?(Hash)
    end
    sort.to_h
  end
end
