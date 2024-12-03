require 'casino'
require 'casino/inflections'
require 'yaml'

module Casino
  class Engine < Rails::Engine
    isolate_namespace Casino

    rake_tasks { require 'casino/tasks' }

    initializer :yaml_configuration do |app|
      apply_yaml_config load_file('config/cas.yml')
    end

    private
    def apply_yaml_config(yaml)
      cfg = (YAML.load(ERB.new(yaml).result)||{}).fetch(Rails.env, {})
      cfg.each do |k,v|
        value = if v.is_a? Hash
          Casino.config.fetch(k.to_sym,{}).merge(v.symbolize_keys)
        else
          v
        end
        Casino.config.send("#{k}=", value)
      end
    end

    def load_file(filename)
      fullpath = File.join(Rails.root, filename)
      IO.read(fullpath) rescue ''
    end

  end
end
