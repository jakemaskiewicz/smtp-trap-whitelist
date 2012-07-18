require 'yaml'

module Config
	raw_config = File.read("config.yml")
	SETTINGS = YAML.load(raw_config)
end
