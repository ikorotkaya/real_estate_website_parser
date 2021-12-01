require "httparty"
require "nokogiri"
require "byebug"

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
  page.search('a.nbk-block').each do |link|

    web_link = link.attribute("href").value
    if web_link.include?("/neubau/")

      p link.content.strip
      p web_link
    end
  end
end

5.times do |page_number|
  parse_house_links(download_page(page_number + 1))
end
