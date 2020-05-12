# frozen_string_literal: true

require 'nokogiri'
require 'net/ping'

file = ARGV[0]
limit_toner = ARGV[1] || 100
not_available = []
supplies_view = '/sws.application/information/suppliesView.sws'
counters_view = '/sws.application/information/countersView.sws'
home_device_info = '/sws.application/home/homeDeviceInfo.sws'

puts 'Looking for printers with a black toner level lower than or equal to ' \
     + limit_toner.to_s
puts

def the_remain_toner(url)
  doc = Nokogiri.HTML(open(url))
  doc_list = doc.xpath('//tr/td[@id="remainCont"]')
  doc_list[0].to_s.gsub(%r{<\/?[^>]*>}, '')
end

def the_counter(url)
  doc1 = Nokogiri.HTML(open(url))
  doc1_list = doc1.xpath('//tr[@id="swstable_counterTotalList_expandTR_2"]/td')
  doc1_list.last.to_s.gsub(%r{<\/?[^>]*>}, '')
end

def the_info(url)
  doc2 = Nokogiri.HTML(open(url))
  doc2_list = doc2.xpath('//tr/td[@class="sws_home_right_table_style2"]')
  doc2_list = doc2_list.to_s.gsub(%r{<\/?[^>]*>}, '<>')
  all_info = doc2_list.split('<>')
  all_info.reject(&:empty?)
  all_info1 = all_info.reject { |info| info.include? '&#' }
  all_info1.reject(&:empty?)
end

def up?(host)
  check = Net::Ping::External.new(host)
  check.ping?
end

file_ip = File.readlines(file)
file_ip.sort_by! { |ip| ip.split('.').map(&:to_i) }
file_ip.each do |line_ip|
  line_ip = line_ip.gsub(/\s|\n|\r\n?/, '')
  check = up? line_ip
  if check == false
    not_available = not_available.push(line_ip)
    next
  end
  toner_info = the_remain_toner('http://' + line_ip.to_s + supplies_view.to_s)
  next unless toner_info.to_i <= limit_toner.to_i

  puts line_ip.to_s
  puts 'Remaining black toner:'.ljust(25, '_') + toner_info.to_s
  counter_info = the_counter('http://' + line_ip.to_s + counters_view.to_s)
  puts 'Total usage counter:'.ljust(25, '_') + \
       counter_info.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  g_info = the_info('http://' + line_ip.to_s + home_device_info.to_s)
  puts 'Model:'.ljust(25, '_') + g_info[0].to_s unless g_info[0].nil?
  puts 'Server:'.ljust(25, '_') + g_info[1].to_s unless g_info[1].nil?
  puts 'Serial:'.ljust(25, '_') + g_info[2].to_s unless g_info[2].nil?
  puts 'Ubication:'.ljust(25, '_') + g_info[3].to_s unless g_info[3].nil?
  puts 'Admin:'.ljust(25, '_') + g_info[4].to_s unless g_info[4].nil?
  puts 'Admin:'.ljust(25, '_') + g_info[5].to_s unless g_info[5].nil?
  puts 'Admin:'.ljust(25, '_') + g_info[6].to_s unless g_info[6].nil?
  puts 'Support:'.ljust(25, '_') + g_info[7].to_s unless g_info[7].nil?
  puts
end

unless not_available.nil?
  puts 'Not avalaible devices:'
  not_available.each(&method(:puts))
end
