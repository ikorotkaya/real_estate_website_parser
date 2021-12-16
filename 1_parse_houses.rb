require "httparty"
require "nokogiri"
require "byebug"
require "yaml"
require "geocoder"

def download_page(page_number)
  if page_number > 1
    response = HTTParty.get("https://www.neubaukompass.de/neubau-immobilien/berlin-region/#{page_number}/")
  else
    response = HTTParty.get("https://www.neubaukompass.de/neubau-immobilien/berlin-region/")
  end
  p "I download page number #{page_number}"
  # https://www.neubaukompass.de/neubau-immobilien/berlin-region/2/
  # puts response.body
  # puts response.code

  # Fetch and parse HTML document
  Nokogiri::HTML(response.body)
end
# Or mix and match

ALEX_COORDINATES = [52.52197645, 13.413637435864272]

Geocoder.configure(
  units: :km
)

def distance_from_alex(address)
  house_coordinates = Geocoder.search(address).first&.coordinates

  return if house_coordinates.nil?

  Geocoder::Calculations.distance_between(house_coordinates, ALEX_COORDINATES)
end

def parse_house_links(page)
  houses_on_page = [] #array of hashes for each house

  page.search('div.nbk-p-3.nbk-w-full').each do |house_card|
    link = house_card.search('a.nbk-block').find do |l|
      l.attribute("href").value.include?("/neubau/") && l.content.strip.size > 0
    end

    house = Hash.new

    house[:name] = link.content.strip.gsub!("\n                ", ". ") #delete part of the text from key element
    house[:link] = link.attribute("href").value

    address = house_card.search("p.nbk-paragraph.nbk-truncate").first.content.strip
    house[:address] = address
    house[:distance_from_alex] = distance_from_alex(address)

    houses_on_page.push(house)
  end

  houses_on_page
end

  # we want to print first 5 pages from website
  # 5.times do |page_number|
  #   parse_house_links(download_page(page_number + 1))
  # end

  #print all pages
def download_all_houses
  all_houses = []
  i = 1
  page_houses = parse_house_links(download_page(i))
  pagination = page_houses.size
  all_houses += page_houses

  while page_houses.size == pagination do
    i += 1
    page_houses = parse_house_links(download_page(i))
    all_houses += page_houses
  end

  all_houses
end


# parse_house_links(download_page(2)) #puts already in method
houses = download_all_houses #result of the method in variable

houses.each_with_index do |house, index|
  puts "House number #{index} #{house[:name]}"
  puts house[:link]
  puts
end

File.open("all_houses.yaml", "w") do |file|
  file.puts(houses.to_yaml)
end
