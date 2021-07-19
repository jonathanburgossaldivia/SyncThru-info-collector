# frozen_string_literal: true

require 'nokogiri'
require 'net/ping'

@file = ARGV[0]
@limit_toner = ARGV[1] || 100
@supplies_view = '/sws.application/information/suppliesView.sws'
@counters_view = '/sws.application/information/countersView.sws'
@home_device_info = '/sws.application/home/homeDeviceInfo.sws'
@ping_timeout = 3
@not_available = []
@available = []
@info_user_toner = []
@info_user_toner_filter = []
RETURN = "\e[K"

puts "Looking for MFPs connected to the network\n\n"

def up?(host)
  check = Net::Ping::HTTP.new("#{host}/sws/index.sws", nil, @ping_timeout)
  check.ping?
end

def list_of_devices
  print "[!] Looking for available MFPs... \r"
  file_ip = File.readlines(@file)
  file_ip.sort_by! { |ip| ip.split('.').map(&:to_i) }
  file_ip.each do |line_ip|
    line_ip = line_ip.gsub(/\s|\n|\r\n?/, '')
    check = up? line_ip
    if check == true
      print RETURN
      @available.push(line_ip)
      print "[!] Found #{line_ip} connected, #{@available.count} connected MFPs...\r"
    elsif check == false
      @not_available.push(line_ip)
      next
    end
  end
end

def the_remain_toner(url)
  doc = Nokogiri.HTML(URI.parse(url).open)
  doc_list = doc.xpath('//tr/td[@id="remainCont"]')
  doc_list[0].to_s.gsub(%r{</?[^>]*>}, '')
end

def the_counter(url)
  doc1 = Nokogiri.HTML(URI.parse(url).open)
  doc1_list = doc1.xpath('//tr[@id="swstable_counterTotalList_expandTR_2"]/td')
  doc1_list.last.to_s.gsub(%r{</?[^>]*>}, '')
end

def the_info(url)
  doc2 = Nokogiri.HTML(URI.parse(url).open)
  doc2_list = doc2.xpath('//tr/td[@class="sws_home_right_table_style2"]')
  doc2_list = doc2_list.to_s.gsub(%r{</?[^>]*>}, '<>')
  all_info = doc2_list.split('<>')
  all_info.reject(&:empty?)
  all_info1 = all_info.reject { |info| info.include? '&#' }
  all_info1.reject(&:empty?)
end

def toner
  print "[!] Collecting information from MFPs with toner level lower than #{@limit_toner}, wait a moment please...\r"
  @available.each do |line_ip|
    toner_info = the_remain_toner("http://#{line_ip}#{@supplies_view}")
    next unless toner_info.to_i <= @limit_toner.to_i

    counter_info = the_counter("http://#{line_ip}#{@counters_view}")
    g_info = the_info("http://#{line_ip}#{@home_device_info}")
    @result = "#{line_ip}: Counter: #{counter_info}; Black toner: #{toner_info}; Model: #{g_info[0]}; Location: #{g_info[3]}"
    @info_user_toner.push(@result)
  end
  print RETURN
end

list_of_devices
toner
puts "[!] Search results; MFPs with toner level lower than #{@limit_toner}:\n\n"
puts @info_user_toner unless @info_user_toner.count.to_i.zero?
