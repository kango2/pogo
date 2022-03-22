#!/usr/bin/perl
use strict;
use warnings;

## Utility to convert hifiasm gfa files to contig fasta file

my ($inputgfa, $outputfasta, $contigprefix) = @ARGV;

if ($inputgfa =~ /\.gz$/) {
	open (F, "gzip -c $inputgfa |") or die $!;
}
else {
	open (F, "<$inputgfa") or die $!;
}

if ($outputfasta =~ /\.gz$/) {
	open (O, "| gzip > $outputfasta") or die $!;
}
else {
	open (O, ">$outputfasta") or die $!;
}

while (my $line = <F>) {
	chomp $line;
	if ($line =~ /^S/){
		my @a = split("\t", $line);
		print O ">$contigprefix.$a[1]\n";
		for (my $i=0; $i<length($a[2]); $i+=60){ 
			print O substr($a[2],$i,60) ."\n"
		}
	}
}
close F;
close O;
