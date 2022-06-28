#!/usr/bin/perl
  
use LWP::UserAgent;

my %departments;
my %positions;
my %ignore;

getIgnoredPositions();
getDepartments();
printPositions();

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
