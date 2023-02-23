#!/usr/bin/env ruby
require 'dnsimple'
require 'dotenv/load'
require 'money'

Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
Money.locale_backend = nil

# Obtain your API token and Account ID
# https://support.dnsimple.com/articles/api-access-token/
dnsimple = Dnsimple::Client.new(
  access_token: ENV['DNSIMPLE_ACCESS_TOKEN']
)

ACCOUNT_ID = ENV['DNSIMPLE_ACCOUNT_ID']

dnsimple_tlds = dnsimple.tlds.all_tlds
tld_suffixes = dnsimple_tlds.data.map{|t| t.tld}.reject{|t| t.include?('.')}

puts "domain\tregistration\trenewal"
ARGV.each do |domain_base|
  tld_suffixes.each do |tld_suffix|
    domain_to_check = "#{domain_base}.#{tld_suffix}"
    domain_available = false
    whois_output = `whois #{domain_to_check} 2>/dev/null | grep -i '^domain status'`
    domain_available = !whois_output.include?('Prohibited') 
    if domain_available
      price_check_response = dnsimple.registrar.get_domain_prices(ACCOUNT_ID, domain_to_check)
      puts "#{domain_to_check}\t#{Money.from_cents((price_check_response.data.registration_price.to_f * 100.0).to_i, "USD").format}\t#{Money.from_cents((price_check_response.data.registration_price.to_f * 100.0).to_i, "USD").format}"
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
  end
end
