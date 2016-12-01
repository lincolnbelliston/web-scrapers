require 'nokogiri'
require 'spreadsheet'
require 'open-uri'

if !Dir.exist?('world_history_timeline')
	Dir.mkdir('world_history_timeline')
end
Dir.chdir('world_history_timeline')


base_url = 'http://www.timemaps.com'
years = ['3500bc', '2500bc', '1500bc', '1000bc', '500bc', '200bc', '30bc','200', '500', '750', '979', '1215', '1453', '1648', '1789', '1837', '1871', '1914', '1960', '2005']

continents = ['World','North America', 'South America', 'Europe', 'Africa', 'Middle East', 'South Asia', 'East Asia', 'South East Asia', 'Oceania','Mexico Central America','Canada','USA','Peru','Chile','Venezuela','Argentina','Brazil','Spain','Britain','France','North Africa','Low Countries','Germany','Italy','Scandinavia','Poland Czech Hungary','Greece','Turkey','Russia','West Africa','South Africa','Central Africa','Egypt','North East Africa','Syria','Iraq','Arabia','Iran','China','Korea','Japan','Australia','New Zealand']

book_out = Spreadsheet::Workbook.new
sheet_out = book_out.create_worksheet

sheet_out[0,0] = 'Continent'
sheet_out[0,1] = 'Year'
sheet_out[0,2] = 'Text'
sheet_out[0,3] = 'Image file name'


lines = []
sheet = []
curr_row = 1
prog = 0
index = continents.length * years.length + 1
first = true


continents_url = continents.map {|x| base_url + '/history/' + x.downcase.gsub(' ','-') + '-2005ad'}
continents_url[0] = 'http://www.timemaps.com/history'
continents_url[31] = 'http://www.timemaps.com/history/south-africa-ad2005'
continents_url[32] = 'http://www.timemaps.com/history/central-africa-ad2005'
continents_url[34] = 'http://www.timemaps.com/history/nubia-ad2005'


(0...continents_url.length).each do |i|

folder = continents[i]
if !Dir.exist?(folder)
Dir.mkdir(folder)
end
Dir.chdir(folder)


	url = continents_url[i]
	page = Nokogiri::HTML(open(url))


	if first == true
	first_timemap = page.css('div#container').css('div[class="footer timemap-footer"]').css('div[class="else_box"]')[0].css('div[class="whatelse-article"]').css('div[class="tu-content"]').css('p').to_a
	timemaps = page.css('div#container').css('div[class="footer timemap-footer"]').css('div[class="else_box"]')[1..-1]

	else
	first_timemap = page.css('div#container').css('div[class="article"]').css('div[class="timemap first-timemap"]').css('div[class="map-content"]').css('div[class="info-col"]').css('p').to_a
	timemaps = page.css('div#container').css('div[class="article"]').css('div[class="timemap "]')
	end



k = years.length - (timemaps.length + 1)
y = 0

#First timemap has different HTML tags, so it's processed separately.		
		(0...first_timemap.length).each do |j|
		lines[j] = first_timemap[j].inner_text.strip

		end
	text = lines.join(' ')
	

	if first == true
	pic_url = page.css('div#container').css('div[class="article"]').css('div#timemap-container').css('div[class="timemap first-timemap"]').css('div[class="map-content"]').css('div[class="map"]').css('img').first['src']	
	file_name = pic_url.split('/').last
	else
	pic_url = page.css('div#container').css('div[class="article"]').css('div#timemap-container').css('div[class="timemap first-timemap"]').css('div[class="map-content"]').css('div[class="map region-map"]').css('img').first['src']
	file_name = pic_url.split('/')[-3..-1].join
	end

	url = base_url+pic_url
	if !File.exist?(file_name)

		File.open(file_name,'wb') do |file|
		file.write(open(url).read)
		end
	end	
	
	file_path = "/world_history_timeline/#{continents[i]}/#{file_name}" 

	sheet_out[curr_row,0] = continents[i]
	sheet_out[curr_row,1] = years[k]
	sheet_out[curr_row,2] = text
	sheet_out[curr_row,3] = file_path
	
	curr_row += 1
	y += 1
	prog += 1 
	per = prog.to_f / index.to_f * 100

system("clear")
puts "Saving images: #{per.round}% #{continents[i]}"
					
#Process the remaining timemaps
	
		timemaps.each do |timemap|

		if first == true
		data = page.css('div#container').css('div[class="footer timemap-footer"]').css('div[class="else_box"]')[y].css('div[class="whatelse-article"]').css('div[class="tu-content"]').css('p').to_a

		else
		data = timemap.css('div[class="map-content"]').css('div[class="info-col"]').css('p').to_a
		end

		lines = []
		

			(0...data.length).each do |j|
			
			lines[j] = data[j].inner_text.strip
	
			end


	if first == true
	pic_url = page.css('div#container').css('div[class="article"]').css('div#timemap-container').css('div[class="timemap "]')[y-1].css('div[class="map-content"]').css('div[class="map"]').css('img')[0]['src']
	file_name = 'world'+pic_url.split('/').last
	else
	pic_url = page.css('div#container').css('div[class="article"]').css('div[class="timemap "]')[y-1].css('div[class="map-content"]').css('div[class="map region-map"]').css('img').first['src']
        file_name = pic_url.split('/')[-3..-1].join
	end

        url = base_url+pic_url
	if !File.exist?(file_name)
		File.open(file_name,'wb') do |file|
			file.write(open(url).read)
		end
	end
		text = lines.join(' ')
		file_path = "/world_history_timeline/#{continents[i]}/#{file_name}"
	
		sheet_out[curr_row,0] = continents[i]
		sheet_out[curr_row,1] = years[y+k]
		sheet_out[curr_row,2] = text
		sheet_out[curr_row,3] = file_path

		curr_row += 1
		prog += 1
		y += 1
		per = prog.to_f / index.to_f * 100

system("clear")		
puts "Saving images: #{per.round}% #{continents[i]}"

		end
prog = prog + k
first = false
Dir.chdir('..')
end

per = prog.to_f / index.to_f * 100
system("clear")
puts "Saving images: #{per.round}%"

book_out.write('world_history_timeline.xls')


