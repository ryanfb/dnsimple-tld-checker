#!/usr/bin/env ruby
require 'dnsimple'
require 'dotenv/load'

# Obtain your API token and Account ID
# https://support.dnsimple.com/articles/api-access-token/
dnsimple = Dnsimple::Client.new(
  access_token: ENV['DNSIMPLE_ACCESS_TOKEN']
)

ACCOUNT_ID = ENV['DNSIMPLE_ACCOUNT_ID']

ARGF.each_line do |tsv_line|
  domain = tsv_line.split("\t")[0]
  if domain.include?('.')
    domain = domain.split('.')[-2..].join('.')
    begin
      dnsimple_response = dnsimple.registrar.check_domain(ACCOUNT_ID, domain)
      domain_available = dnsimple_response.data.available
      if domain_available
        puts tsv_line
      end
    rescue Dnsimple::RequestError => e
      if e.message.include?('is not supported')
        warn "Error checking #{domain_to_check}: #{e.inspect}"
      else
        reset_at = e.http_response.headers['x-ratelimit-reset'].to_i
        reset_in = reset_at - Time.now.to_i
        warn "Error checking #{domain_to_check}: #{e.inspect}, sleeping #{reset_in} second(s) before retrying (next retry at: #{Time.at(reset_at)})"
        sleep reset_in
        retry
      end
    rescue URI::InvalidURIError => e
    end
  else
    puts tsv_line
  end
end
