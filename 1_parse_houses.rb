require "httparty"
require "nokogiri"
require "byebug"
require "yaml"

def download_page(page_number)
  if page_number > 1
    response = HTTParty.get("https://www.neubaukompass.de/neubau-immobilien/berlin-region/#{page_number}/")
  else
    response = HTTParty.get("https://www.neubaukompass.de/neubau-immobilien/berlin-region/")
  end

  # https://www.neubaukompass.de/neubau-immobilien/berlin-region/2/
  # puts response.body
  # puts response.code

  # Fetch and parse HTML document
  Nokogiri::HTML(response.body)
end
# Or mix and match

def parse_house_links(page)
  house_links_on_page = [] #array of hashes for each house

  page.search('a.nbk-block').each do |link|
    web_link = link.attribute("href").value

    if web_link.include?("/neubau/")
      each_house_link = Hash.new
      each_house_link[:name] = link.content.strip
      each_house_link[:name].gsub!("\n                ", ". ") #delete part of the text from key element
      each_house_link[:link] = web_link
      if each_house_link[:name] != "" # no double links in house_links_array
        house_links_on_page.push(each_house_link)
      end
      # p link.content.strip
      # p web_link
    end
  end
  house_links_on_page
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
