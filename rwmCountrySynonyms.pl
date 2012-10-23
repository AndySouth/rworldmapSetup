#!/usr/local/bin/perl
# rwmCountrySynonyms.pl
# 23/5/12 andy south

# runs Country_Codes.pm from 
# then outputs data (ID,ISO3,names ...) to a text file that R can read in

# to run : perl - w rwmCountrySynonyms.pl

use strict;
use warnings;

#this runs Country_Codes.pm
use Country_Codes;



#country names
#print $Locale::Codes::Data{'country'}{'id2names'}{'0001'}[0], "\n" ;
#ISO codes
#my $key1 = '0001';
#print $Locale::Codes::Data{'country'}{'id2code'}{'alpha-3'}{$key1}, "\n" ;

#TO create an outfile with country names on each line
open(OUT,"> countrySynonyms.txt") or die $!;

#$key1 is the ID for each country starting at 0001
for my $key1 ( keys %{$Locale::Codes::Data{'country'}{'id2names'}} ) {
  #column1 : the perl ID
  print OUT $key1, "\t";

  #a test line showing which codes are missing
  print $key1," ", $Locale::Codes::Data{'country'}{'id2code'}{'alpha-3'}{$key1},":",$Locale::Codes::Data{'country'}{'id2names'}{$key1}[0], "\n" ;
  
  #column2 iso 3 letter code lower case
  print OUT $Locale::Codes::Data{'country'}{'id2code'}{'alpha-3'}{$key1}, "\t" ;

  #column 3 + alternate country names
  foreach (@{$Locale::Codes::Data{'country'}{'id2names'}{$key1}}) {
     print OUT $_, "\t";
  }
  print OUT "\n";

}

close OUT;


