#!/usr/bin/perl
  
use LWP::UserAgent;
use CGI;

my %departments;
my %positions;
my %ignore;

$MAX_RECS=50;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $ua = new LWP::UserAgent;
$ua->timeout(120);
$cnt=0;
$positionUrlPrefix = "https://imvdb.com/browse/position/";
$position = "cin";
$backStr="Back to The Top";

print CGI->header;

getIgnoredPositions();
getDepartments();
printPositions();

#getSearchByPosition($position);

#--------------------------------------------------------
sub getIgnoredPositions{
  my @lines;
  open(F, "positions.ignore.csv");
  chomp(@lines = <F>);
  close F;
  foreach(@lines) {
    $ignore{$_}=1;
  }
}

#--------------------------------------------------------
sub getDepartments{
  my @lines;
  open(F, "departments.csv");
  chomp(@lines = <F>);
  close F;
  foreach(@lines) {
    my ($department, $include) = split(",", $_);
    if ($include == 1) {
      getPositions($department);
    }
  }
}

#--------------------------------------------------------
sub getPositions{
  my $thisDepartment = shift;
  my @lines;
  open(F2, "positions.csv");
  chomp(@lines = <F2>);
  close F2;
  foreach(@lines) {
    next if (exists $ignore{$_});
    next unless /^$thisDepartment/;
    my ($department, $position, $desc) = split(",", $_);
    next if $position eq "";
    $departments{$department}{$position} = $desc;
  }
}

#--------------------------------------------------------
sub printPositions{
  foreach (keys %departments) {
    print "$_\n";
    my $tmp = $departments{$_};
    foreach (sort keys %$tmp) {
      print "  $_\n";
    }
  }
}

#------------------------------------------------------------
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

#------------------------------------------------------------
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

#------------------------------------------------------------
sub getPage() {
  my $url=shift;
  my $request = new HTTP::Request('GET', $url);
  my $response = $ua->request($request);
  my $content = $response->content();
  return $content;
}
