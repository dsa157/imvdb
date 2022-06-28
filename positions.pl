#!/usr/bin/perl
  
use LWP::UserAgent;

my %departments;
my %positions;
my %ignore;

getIgnoredPositions();
getDepartments();
#getPositions();

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
      print "$department\n"; 
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
    #if not exists $departments{$department} {
      #%positions = {};
      #$departments{$department} = {};
    #}
    $departments{$department}{$position} = $desc;
print "-- $position\n";
  }
  foreach (keys %departments) {
    my $tmp = $departments{$_};
    foreach (sort keys %$tmp) {
      #print "  $_\n";
    }
  }
}
