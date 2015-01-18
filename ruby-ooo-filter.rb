#!/usr/bin/env ruby

require 'mail'
require 'optparse'
require 'logger'

def configure_logging
  # logging
  $logger = Logger.new('ruby-ooo-filter.log')

  $logger.formatter = proc do |serverity, time, progname, msg|
    "#{time} #{msg}\n"
  end
end

def get_subjects
  file = File.open("subjects.txt")
  subjects = Array.new
  file.each_line { |line| subjects.push(line)}
  return subjects
end

def filter_mail (forward_address)
  # read mail and subjects
  input = ARGF.read
  mail = Mail.read_from_string(input)
  subjects = get_subjects
  if(subjects.any? {|subject| subject.casecmp(mail.subject)})
    $logger.info "From: #{mail.from} - Subject: #{mail.subject} - auto reply detected - discarding email"
    exit
  else
    $logger.info "From: #{mail.from} - Subject: #{mail.subject} - no auto reply detected - forwarding to #{forward_address}"
  	mail.to forward_address
    # deliver mail here!
  end
end

########################
# MAIN
########################

configure_logging

# options
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: ruby-ooo-filter.rb [options] E-MAIL"
  opts.on('-f', '--forward-address E-MAIL-ADDRESS', 'Address where E-Mails are forwarded to') do |arg|
    options[:f] = arg
  end
end
optparse.parse!

# call filter
filter_mail(options[:f])