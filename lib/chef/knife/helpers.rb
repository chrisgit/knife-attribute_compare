module ChrisGit
  class PathHelper
    def self.sanitise_path(path)
      return '' if path.nil?
      path.strip!
      path = path.remove_double_quotes(path)
      path.gsub(/\\+/, '/')
    end

    def self.remove_double_quotes(path)
      path = path[1..-1] if path.start_with?('""')
      path = path[0..-2] if path.end_with?('""')
      path
    end
  end
end
