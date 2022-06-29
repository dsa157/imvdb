#!/usr/bin/perl
  
use LWP::UserAgent;
use CGI;

my %departments;
my %positions;
my %ignore;
my %pages;
my %existingRecords;
my $outfile = "imvdb.tsv";
my $MAX_RECS=500;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $ua = new LWP::UserAgent;
$ua->timeout(120);
$cnt=1;
$positionUrlPrefix = "https://imvdb.com/browse/position/";
$backStr="Back to The Top";
$videographyStr="videography-by-dept";

print CGI->header;

print "Max Records = $MAX_RECS<br>\n";

readExistingRecords();
getIgnoredPositions();
getDepartments();
printPositions();
print <<_EOT_;
done.
view <a href="imvdb.tsv">Tab Separated Data File</a>
_EOT_

#--------------------------------------------------------
sub readExistingRecords{
  open(F, "<$outfile");
  while(<F>) {
    chomp;
    my ($id, $rest) = split("\t", $_);
    #print "$id\n";
    $existingRecords{$id}=1;
  }
  close(F);
}

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
  open(F, ">>$outfile");
  foreach (keys %departments) {
    my $department = $_;
    my $tmp = $departments{$_};
    foreach (sort keys %$tmp) {
      #print "  $_\n";
      getEntitiesByPosition($department, $_);
      last if $cnt > $MAX_RECS;
    }
  }
  close(F);
}

#------------------------------------------------------------
sub getEntitiesByPosition() {
  my $department = shift;
  my $position = shift;
  print "Getting $department $position list...<br>\n";
  print "<table border=1>\n";
  $url = $positionUrlPrefix . $position;
  $content = getPage($url);
  my @lines = split("\n", $content);
  foreach (@lines) {
    next unless /imvdb\.com\/n\//;
    last if $cnt > $MAX_RECS;
    s/<li>//g;
    s/<\/li>//g;
    s/<\/a>//g;
    s/(.*)<a\ href=\"//g;
    s/\"//g;
    my($url,$name)=split(/>/);
    getEntityBySlug($url, $name);
  }
  print "</table>\n";
}

#------------------------------------------------------------
sub getEntityBySlug() {
  my $url=shift;
  my $name=shift;
  my $suffix = "/$videographyStr";
  my $url2 = $url . $suffix;
  return if exists $existingRecords{$url};
  return if exists $pages{$url2};
  $pages{$url2}=1;
  #print "$url2\n";
  my $content = getPage($url2);
  my @lines = split("\n", $content);
  my $entity = new Entity;
  $entity->{_url} = $url;
  $entity->{_name} = $name;
  foreach (@lines) {
    getTwitter($entity, $_) if /Tweets/;
    $entity->{_links} = "has links" if /Links/;
    next unless /$videographyStr\#/;
    next if /$backStr/;
    my $positionsStr = $_;
    $entity->{_positions} = $positionsStr;
  }
  $existingRecords{$name}=1;
  my $positionCount = countCredits($entity->{_positions});
  if ($positionCount > 1) {
    printWebTableRow($entity); 
    printTsvRow($entity); 
    $cnt++;
  }
}

#------------------------------------------------------------
sub printWebTableRow() {
  my $entity = shift;
  print <<_EOT_;
<tr>
<td>$cnt</td>
<td><a href='$entity->{_url}'>$entity->{_name}</a></td>
<td>$entity->{_positions}</td>
<td>$entity->{_twitter}</td>
<td>$entity->{_links}</td>
</tr>

_EOT_
}

#------------------------------------------------------------
sub printTsvRow() {
  my $entity = shift;
  print F <<_EOT_;
$entity->{_url}	$entity->{_name}	$entity->{_positions}	$entity->{_twitter}	$entity->{_links}
_EOT_
}

#------------------------------------------------------------
sub getTwitter() {
  my $entity = shift;
  my $line = shift;
  $line =~ s/^(.*)screen-name\=\"//g;
  $line =~ s/\"(.*)$//g;
  $entity->{_twitter} = $line;
}

#------------------------------------------------------------
sub getPage() {
  my $url=shift;
  my $request = new HTTP::Request('GET', $url);
  my $response = $ua->request($request);
  my $content = $response->content();
  return $content;
}

#--------------------------------------------------
sub countCredits() {
 my $str = shift;
 my $count = shift;
#print "-- $str\n";
 my($str1, $rest) = split('\(', $str, 2);
 my($count1, $rest2) = split('\)', $rest, 2);
 $count1 = 0 if !defined($count1);
 $count += $count1;
 if ($count1 > 0) {
   $count = countCredits($rest2, $count);
 }
 else {
  return $count;
 }
 #print "$count\n";
}

#------------------------------------------------------------
package Entity;
sub new {
   my $class = shift;
   my $self = {};
   $self->{_url}       = undef;
   $self->{_name}      = undef;
   $self->{_positions} = undef;
   $self->{_twitter}   = undef;
   $self->{_links}     = undef;
   bless $self, $class;
   return $self;
}

