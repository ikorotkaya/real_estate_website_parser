require "httparty"
require "nokogiri"
require "byebug"
require "yaml"
require "pp"

houses = YAML.load(File.read("all_houses.yaml"))

# [
#   {
#     name: "HOUSENAME",
#     link: "/neubau/XXX",
#     flats: [
#       {
#         link: "/neubau/YYY",
#         price: 258000,
#         size: 53.8,
#         rooms_count: 2,
#         name: "EK20 ..."
#       }
#     ]
#   }
# ]

def download_house_page(link)
  response = HTTParty.get("https://www.neubaukompass.de#{link}")

  Nokogiri::HTML(response.body)
end

def parse_flat_links(link)
  flats = []
  page = download_house_page(link)

  flats_block = page.search(".accordion").find do |block|
    block.text.include?("Wohneinheiten")
  end

  if flats_block.nil?
    puts "--> Can't find flats block for #{link}"

    return []
  else
    flats_block.search("a.nbk-block").each do |flat_block|
      href = flat_block.attribute("href").value

      next unless href.include?("/neubau/")

      one_flat = Hash.new
      one_flat[:link] = href
      params = flat_block.search("p.nbk-paragraph").map(&:text).map(&:strip)
      one_flat[:price] = params[0].gsub(".", "").gsub(" €", "").to_i
      one_flat[:size] = params[1].gsub(" m²", "").gsub(",", ".").to_f
      one_flat[:rooms_count] = params[2].split("\n").first.to_i
      one_flat[:name] = params[3]

      flats.push(one_flat)
    end
  end
  return flats
end

houses.each_with_index do |house, index|
  puts "--> Downloading house: #{index + 1}"

  house[:flats] = parse_flat_links(house[:link])

  sleep(rand(1..5))
end

File.open("all_houses_with_flats.yaml", "w") do |file|
  file.puts(houses.to_yaml)
end
