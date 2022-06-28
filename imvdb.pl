#!/usr/bin/perl
  
use LWP::UserAgent;
use CGI;

$MAX_RECS=200;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $ua = new LWP::UserAgent;
$ua->timeout(120);
$cnt=0;
$position = "cin";

print CGI->header;
print "Getting " . $position . " list...<br>\n";
print "<table>";

getSearchByPosition($position);

print "</table>";

sub getSearchByPosition() {
  my $position = shift;
  $content = getPage("https://imvdb.com/browse/position/" . $position);
  my @lines = split("\n", $content);
  foreach (@lines) {
    next unless /imvdb\.com\/n\//;
    last if $cnt++ >= $MAX_RECS;
    s/<li>//g;
    s/<\/li>//g;
    s/<\/a>//g;
    s/(.*)<a\ href=\"//g;
    s/\"//g;
    my($url,$name)=split(/>/);
    getEntityBySlug($url, $name);
  }
}

