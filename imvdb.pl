#!/usr/bin/perl
  
use LWP::UserAgent;

$MAX_RECS=2;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $ua = new LWP::UserAgent;
$ua->timeout(120);
$cnt=0;

getSearchByPosition("dir");


sub getSearchByPosition() {
  my $position = shift;
  print "Getting " . $position . " list...\n";
  $content = getPage("https://imvdb.com/browse/position/" . $position);
  print "printing...\n";
  my @lines = split("\n", $content);
  foreach (@lines) {
    next unless /imvdb\.com\/n\//;
    last if $cnt++ >= $MAX_RECS;
    s/<li>//g;
    s/<\/li>//g;
    print "$_\n";
  }
  print "done.\n";
}

sub getEntityBySlug() {
}

sub getPage() {
  my $url=shift;
  my $request = new HTTP::Request('GET', $url);
  my $response = $ua->request($request);
  my $content = $response->content();
  return $content;
}

