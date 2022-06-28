#!/usr/bin/perl
  
use LWP::UserAgent;

my %departments;
my %positions;
my @lines;

open(F, "positions.csv");
chomp(@lines = <F>);
close F;
getDepartments(@lines);

sub getDepartments{
  foreach(@lines) { 
    my ($department, $position, $desc) = split(",", $_);
    next if $position eq "";
    #if not exists $departments{$department} {
      #%positions = {};
      #$departments{$department} = {};
    #}
    $departments{$department}{$position} = $desc;
  }
  foreach (keys %departments) {
    next unless /Editorial/;
    my $tmp = $departments{"Editorial"};
    foreach (keys %$tmp) {
      print $_, "\n";
    }
  }
  
}
