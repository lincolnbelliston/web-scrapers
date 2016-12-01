require 'nokogiri'
require 'open-uri'
require 'csv'


CSV.open('flyingclassroom.csv','wb') do |csv|

csv << ["City","Country","Arrival","Lat","Long"]

url = "http://www.flyingclassroom.com/flight-tracker/"
page = Nokogiri::HTML(open(url).read)

data = page.css('div#content').css('div.entry-content').css('script').inner_text.strip.split('[')[1].split(']')[0].split('},{')

data.each do |place|
	
	row = []
	place.split(',').each do |value|

		row.push(value.split(':')[1].gsub("\"",""))
	end

	del_index = [6,2]
	del = []
	del_index.each do |d|	
	del.push(row.delete_at(d))
	end

	row = row - del
	csv << row
end
end
