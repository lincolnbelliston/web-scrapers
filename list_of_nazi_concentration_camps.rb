require 'open-uri'
require 'csv'
require 'nokogiri'

url = "https://en.wikipedia.org/wiki/List_of_Nazi_concentration_camps"

page = Nokogiri::HTML(open(url).read)

CSV.open("list_of_nazi_concentration_camps.csv",'wb') do |csv|

csv << ['Camp Name','Country','Camp Type','Dates of use','Est. Prisoners','Est. Deaths']

	trow = page.css('div#bodyContent.mw-body-content').css('div#mw-content-text.mw-content-ltr').css('table')[0].css('tr')

	trow.drop(1).each do |trow|

	name =	trow.css('td')[1].inner_text.strip
	country = trow.css('td')[2].inner_text.strip
	type = trow.css('td')[3].inner_text.strip
	dates = trow.css('td')[4].inner_text.strip
	pris = trow.css('td')[5].inner_text.strip
	deaths = trow.css('td')[6].inner_text.strip

	row = [name,country,type,dates,pris,deaths]

	csv << row

	end
end
