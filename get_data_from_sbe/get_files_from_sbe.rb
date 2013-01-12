require 'nokogiri'
require 'net/http'
require 'uri'

SBE_site = 'www.sbe.virginia.gov'
Page_suffix = 'RegistrationStats.html'
Years_to_get =['2012','2011']
Div_tag = 'span9'
Excel_filename_regex = /Registrant\_Counts\_By\_Locality\.xls/
Excel_filename = 'Registrant_Counts_By_Locality.xls'
Output_path = 'rawdata'

Years_to_get.each do |year_to_get|
  base_page = Nokogiri::HTML.parse(Net::HTTP.get(SBE_site,'/'+year_to_get+Page_suffix))
  base_page.css('div.'+Div_tag+' a').map{ |link| link['href'] }.find_all{|item| item =~ Excel_filename_regex }.each do |full_path|
    year_month_to_get = year_to_get+'-'+full_path.split('/')[3]
    local_excel_filename = Output_path+'/'+year_month_to_get+'-'+Excel_filename
    if not File.exists?(local_excel_filename)
      puts 'Getting '+year_month_to_get
      excel_file = Net::HTTP.get(SBE_site,'/'+URI.escape(full_path))
      open(local_excel_filename, "wb") do |file|
          file.write(excel_file)
      end
    else
      puts 'Skipping '+year_month_to_get
    end
  end
end
