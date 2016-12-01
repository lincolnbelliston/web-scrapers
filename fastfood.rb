require 'open-uri'
require 'nokogiri'
require 'csv'

base_url = "https://en.wikipedia.org"
home_url = "https://en.wikipedia.org/wiki/List_of_fast_food_restaurant_chains"

page = Nokogiri::HTML(open(home_url).read)

CSV.open("fastfood.csv",'wb') do |csv|
csv << ["Company","Headquarters","Founded"]

#Generate restaurant URLs
restaurant_urls = page.css('div#content.mw-body').css('div#bodyContent.mw-body-content').css('div#mw-content-text.mw-content-ltr').css('ul')[9..54].css('li').css('a').map{|link| link['href']}



#I\terate through each restaurant
restaurant_urls.each do |restaurant|

	url = base_url + restaurant
	begin
	rest_page = Nokogiri::HTML(open(url).read)
	rescue
	headquarters = "irr"
	else

	company = rest_page.css('div#content.mw-body').css('h1#firstHeading.firstHeading').inner_text.strip

	
	search = false
	i = 0
	
#Search summary box for headquarters
	while search == false
		begin
		hq = rest_page.css('div#content.mw-body').css('div#bodyContent.mw-body-content').css('div#mw-content-text.mw-content-ltr').css('table.infobox.vcard').css('tr')[i].css('th')
		rescue 
		search = false
		else
		search = hq.inner_text.strip == "Headquarters"
		end	


		if i > 10
		search = true
		hq = nil
		end

	i +=1
	end

	if hq == nil
	headquarters = "irr"
	else
	headquarters = rest_page.css('div#content.mw-body').css('div#bodyContent.mw-body-content').css('div#mw-content-text.mw-content-ltr').css('table.infobox.vcard').css('tr')[i-1].css('td').inner_text.strip
	end

	


#Search box for date founded
	search = false
	i = 0

	while search == false
		begin
		foun = rest_page.css('div#content.mw-body').css('div#bodyContent.mw-body-content').css('div#mw-content-text.mw-content-ltr').css('table.infobox.vcard').css('tr')[i].css('th')
		rescue
		search = false
		else
		search = foun.inner_text.strip == "Founded"
		end

		if i > 10
		search = true
		foun = nil
		end
	
	i +=1
	end

	if foun == nil
	founded = "irr"
	else
	founded = rest_page.css('div#content.mw-body').css('div#bodyContent.mw-body-content').css('div#mw-content-text.mw-content-ltr').css('table.infobox.vcard').css('tr')[i-1].css('td').inner_text.strip
	end

	end

row = [company, headquarters, founded]
csv << row
end
end 
