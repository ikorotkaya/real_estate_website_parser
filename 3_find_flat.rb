require "httparty"
require "nokogiri"
require "byebug"
require "yaml"
require "pp"

houses = YAML.load(File.read("all_houses_with_flats.yaml"))

houses.each_with_index do |house, index|
  pp house
  puts
end
