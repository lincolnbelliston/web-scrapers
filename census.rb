#This script clicks on a topic, downloads the tables for each year, and compiles the data in to one file, in order to easily compare years. It cycles through all the topics on the page.

require 'watir-webdriver'
require 'spreadsheet'
require 'csv'
require 'nokogiri'
require 'open-uri'

url = "http://www.census.gov/acs/www/data/data-tables-and-tools/ranking-tables/"
years = ['2005','2006','2007','2008','2009','2010','2011','2012','2013','2014']
Dir.chdir('../../../Downloads')

#Set firefox to automatically save downloads
profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/vnd.ms-excel'

browser = Watir::Browser.new(:firefox,:profile => profile)

browser.goto url
browser.select_list(:name => "rankings_length").select "All"

#BUILD ARRAY OF TABLE_names
page = Nokogiri::HTML(open(url).read)

tables = page.css('div#middledrill').css('table#rankings').css('tr').drop(2)

tables.each do |table|
  
  table_name = table.css('td')[0].inner_text.strip
  table_ref = table.css('td')[2].inner_text.strip
  
  Dir.chdir('Ranking_tables')
  
  if File.exists?("#{table_name.gsub(" ","_").gsub("\"","").gsub("/","_or_").gsub(".",",")}.csv")
  
  Dir.chdir('..')
  else
  Dir.chdir('..')
  
  browser.link(:text => table_name).click
  browser.a(:text => "2013").wait_until_present
  
  x = 0 #number of years dropped
  a = 0 #index of year vector
  delete_list = []
  years.each do |year|
    begin
      browser.a(:text => year).click
    rescue #make an array of years w/ no data
      delete_list.push(a)
    else
      browser.a(:text => "Download").when_present.click
      
      j = 0
      while browser.radio(:value => 'XLS').set? == false
        begin
          browser.radio(:value => 'XLS').when_present.set
        rescue
          browser.a(:text => "Download").click
          browser.radio(:value => 'XLS').when_present.set
        end #begin/rescue
      end #of while browser.radio.set?
        browser.button(:text => "OK").click

        download = false
        while download == false
          download = browser.button(:text => "Download").when_present.enabled?
        end #of while download

          browser.button(:text => "Download").click
          sleep 1
    end #of begin/rescue

  a += 1  
  end #of years.each do
   
    title = table_name.gsub(" ","_").gsub("\"","").gsub("/","_or_").gsub(".",",")

    alpha_key = []
    data = []
    i_year = 0

    #Create an array of years less years w/ no data
    i_del = 0
    delete_years = []
      delete_list.each do |d|
        d = d - i_del
        delete_years.push(years.delete_at(d))
        i_del += 1
        end
        
    
    file_years = years - delete_years 
    file_years.each do |y|
      file_name1 = "ACS_#{y[2..3]}"
      file_name2 = "#{table_ref}"

      file = Dir.glob("*#{file_name1}_???_#{file_name2}*")[0]

      alpha_key = []
      data_hash = Hash.new  
      r_0 = Hash.new


    
      book = Spreadsheet.open file

      sheet1 = book.worksheet 0
      sheet1.each do |row|
 
        r = Hash[row[2] => row[4]]
        data_hash = r.merge(r_0)
    
        alpha_key.push(r.keys.sort)
        r_0 = data_hash
  
      end #of sheet1.each

      alpha_key = alpha_key.flatten.compact!.sort.drop(1) - ["Geographical Area"]
      data[i_year] = data_hash
    
      i_year += 1
    
    end #of years.drop(x).each do |y|

  if Dir.exists?('Ranking_tables')
  else
    Dir.mkdir('Ranking_tables')  
  end #of Dir.exists?
  
  Dir.chdir('Ranking_tables')
        
  CSV.open("#{title}.csv",'wb') do |csv|
    csv << ["State","Data"]
    csv << [nil].concat(file_years)   
    alpha_key.each do |state|
    
      dat_row = []

      i_year.times do |i|
      dat_row.push(data[i][state])   
      end #of i_year do 
    
      csv << [state].concat(dat_row)
        
    end #of alpha_key do
 
  end #of CSV.open 
  Dir.chdir('..')

  browser.goto url
  browser.select_list(:name => "rankings_length").select "All"
    if browser.a(:class => 'fsrDeclineButton').exists?
      browser.a(:class => 'fsrDeclineButton').click
    end #of Decline button exists?  
  end #of File.exists? loop
end #of table loop

 