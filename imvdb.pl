#!/usr/bin/perl
  
use LWP::UserAgent;
use CGI;

$MAX_RECS=50;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $ua = new LWP::UserAgent;
$ua->timeout(120);
$cnt=0;
$positionUrlPrefix = "https://imvdb.com/browse/position/";
$position = "cin";
$backStr="Back to The Top";

print CGI->header;

getSearchByPosition($position);


sub getSearchByPosition() {
  print "Getting " . $position . " list...<br>\n";
  print "<table>";
  my $position = shift;
  $content = getPage($positionUrlPrefix . $position);
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
  print "</table>";
}

sub getEntityBySlug() {
  my $url=shift;
  my $name=shift;
  my $suffix = "/videography-by-dept";
  my $url2 = $url . $suffix;
  my $content = getPage($url2);
  my @lines = split("\n", $content);
  foreach (@lines) {
    next unless /videography-by-dept\#/;
    next if /backStr/;
    print "<tr><td><a href='$url'>$name</a></td><td>$_</td></tr>\n";
  };
}

sub getPage() {
  my $url=shift;
  my $request = new HTTP::Request('GET', $url);
  my $response = $ua->request($request);
  my $content = $response->content();
  return $content;
}
