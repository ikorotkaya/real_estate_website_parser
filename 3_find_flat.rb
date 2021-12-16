require "httparty"
require "nokogiri"
require "byebug"
require "yaml"
require "pp"
require "cgi"

houses = YAML.load(File.read("all_houses_with_flats.yaml"))

flats = houses.reduce([]) do |f, house|
  house[:flats].each do |flat|
    flat[:address] = house[:address]
    flat[:distance_from_alex] = house[:distance_from_alex]
  end

  f += house[:flats]
end

puts "Total flats: #{flats.size}"

flats = flats.filter { |f| f[:rooms_count] > 2 }

puts "Total flats with 3+ rooms: #{flats.size}"

flats = flats.filter { |f| f[:price] <= 800_000 }

puts "Total flats price <800K: #{flats.size}"

flats = flats.filter { |f| f[:size] > 75 }

puts "Total flats with size 75+ sqm: #{flats.size}"

flats = flats.filter { |f| !f[:name].include?("VERKAUFT") }

puts "Total flats available: #{flats.size}"

flats = flats.filter { |f| f[:distance_from_alex].nil? || f[:distance_from_alex] < 20 }

puts "Distance less than 20km: #{flats.size}"

puts "FLATS\n"

# flats.each_with_index do |flat, index|
#   puts "#{index + 1}. #{flat[:name]}"
#   puts "https://www.neubaukompass.de#{flat[:link]}"
#   puts
# end

liked_flats = YAML.load(File.read("liked_flats.yaml"))
disliked_flats = YAML.load(File.read("disliked_flats.yaml"))

flats = flats.filter { |f| !liked_flats.include?(f[:link]) }
flats = flats.filter { |f| !disliked_flats.include?(f[:link]) }

flats.each do |flat|
  puts flat[:link]
  puts flat[:address]
  puts "Distance from Alex #{flat[:distance_from_alex]}"

  system `open https://www.neubaukompass.de#{flat[:link]}`
  system `open https://google.com/maps/search/#{CGI.escape(flat[:address])}`

  puts "If you like this flat, type '+'"
  user_answer = gets.strip

  if user_answer == "+"
    liked_flats.push(flat[:link])
    File.open("liked_flats.yaml", "w") do |file| #put each flat in the file right away
      file.puts(liked_flats.to_yaml)
    end
  else
    disliked_flats.push(flat[:link])
    File.open("disliked_flats.yaml", "w") do |file|
      file.puts(disliked_flats.to_yaml)
    end
  end
end
