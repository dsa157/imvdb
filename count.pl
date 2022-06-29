#!/usr/bin/perl
  

my $str = "Directorial (25), Producers (1), Production Management (1), Writing (1), Camera Department (1), Post-Production Department (1), Editorial (1)";
$str = "Editorial (1)";
#$str = "xxx";

print countCredits($str), "\n";

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
