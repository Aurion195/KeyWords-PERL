#!/usr/bin/perl
use strict;
use warnings;

my $dir = "10_JPCO/" ;
my @text = ("10_JPCO/jpco_1_1_011001.txt") ;


foreach(@text) {
    my $value ;
    open($value, "<", $_) or die "Can't open input.txt: $!" ;
    my @ligne = <$value> ;
    foreach(@ligne) {
        print"$_\n" ;
    }
}