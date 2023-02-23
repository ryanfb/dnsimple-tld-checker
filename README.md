# dnsimple-tld-checker

Ruby script(s) for checking all available [DNSimple TLDs](https://dnsimple.com/tlds) for domain availability, alongside their prices.

Need a domain registrar? Not yet signed up for DNSimple? Use my referral link to sign up here: <https://dnsimple.com/r/a18daa6869b815>

You'll need to set your DNSimple account ID and API access token in the environment variables `DNSIMPLE_ACCOUNT_ID` and `DNSIMPLE_ACCESS_TOKEN` respectively. You can also set these in a `.env` file in the working directory. You can learn how to generate an access token here: <https://support.dnsimple.com/articles/api-access-token/>

Usage:

    bundle exec ./dnsimple-tld-checker.rb myname myproduct myidea

Standard output will be e.g.:

```
domain  registration    renewal
myname.academy  $35.00  $35.00
myname.accountant       $144.00 $144.00
myname.accountants      $105.00 $105.00
myname.actor    $44.00  $44.00
myname.adult    $110.00 $110.00
myname.aero     $80.00  $80.00
...
```

The output is tab-separated and suitable for piping to a .tsv file.

The script uses a simple WHOIS check and heuristic for quickly checking availability. No available libraries I found were suitable for the variety of TLDs supported by DNSimple, and the DNSimple checkDomain API endpoint has a very restrictive rate limit.

Because of this, a second script is provided which can take a list of full domains and verify their availability via the DNSimple API. An example use case is that you can use `dnsimple-tld-checker.rb` to brainstorm a list of possible domains, then filter down the list to ones you want to check are really available for registration via the DNSimple API with `dnsimple-tld-verifier.rb`. The `dnsimple-tld-verifier.rb` script will only output lines where the first entry is a verified available domain.

Example usage:

    bundle exec ./dnsimple-tld-checker.rb myname > myname.tsv
    vim myname.tsv; echo 'only keeping domains I like'
    bundle exec ./dnsimple-tld-verifier.rb myname.tsv > myname-verified.tsv
