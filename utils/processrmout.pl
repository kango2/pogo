#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use File::Basename;



my ($genomefasta, $splitsdir, $rmoutdir, $outputdir) = @ARGV;

my $lineWrap = 70;

##get the order of sequences in original fasta and the length of the wrap
my ($genomeseq, $headers) = readFasta($genomefasta, "nc");

##list split files for the genome
my $genomebase = basename($genomefasta);
opendir(DIR, $splitsdir);
my @splitfiles = grep(/$genomebase/,readdir(DIR));
closedir(DIR);

##concatenate output files
unlink("$outputdir/$genomebase.tbl") if (-e "$outputdir/$genomebase.tbl");
unlink("$outputdir/$genomebase.ori.out") if (-e "$outputdir/$genomebase.ori.out");
unlink("$outputdir/$genomebase.cat.gz") if (-e "$outputdir/$genomebase.cat.gz");
unlink("$outputdir/$genomebase.tmp.out") if (-e "$outputdir/$genomebase.tmp.out");
unlink("$outputdir/$genomebase.out.tmp.gff") if (-e "$outputdir/$genomebase.out.tmp.gff");
unlink("$outputdir/$genomebase.tmp.masked") if (-e "$outputdir/$genomebase.tmp.masked");

for my $sfile (sort @splitfiles) {
  system("cat $rmoutdir/$sfile.tbl >>$outputdir/$genomebase.tbl");
  system("cat $rmoutdir/$sfile.ori.out >>$outputdir/$genomebase.ori.out");
  system("cat $rmoutdir/$sfile.cat.gz >>$outputdir/$genomebase.cat.gz");
  system("cat $rmoutdir/$sfile.out >>$outputdir/$genomebase.tmp.out");
  system("cat $rmoutdir/$sfile.out.gff >>$outputdir/$genomebase.out.tmp.gff");
  system("cat $rmoutdir/$sfile.masked >>$outputdir/$genomebase.tmp.masked");
}

##remove repeated headers from the outfile
system("head -n3 $outputdir/$genomebase.tmp.out >$outputdir/$genomebase.out");
system("grep -vP ^'\\s+SW\\s+perc\\s+' $outputdir/$genomebase.tmp.out | grep -v '^\$' | grep -vP ^'score\\s+div' >>$outputdir/$genomebase.out");
unlink("$outputdir/$genomebase.tmp.out");

##remove comment lines from gff
system("head -n2 $outputdir/$genomebase.out.tmp.gff >$outputdir/$genomebase.out.gff");
system("grep -v ^'#' $outputdir/$genomebase.out.tmp.gff | sed 's/ \t/\t/g' | sed 's/\t /\t/g' >>$outputdir/$genomebase.out.gff");
unlink("$outputdir/$genomebase.out.tmp.gff");

##rewrite the masked file to retain original order of sequences
my ($rmgenomeseq, $rmheaders) = readFasta("$outputdir/$genomebase.tmp.masked", "nc");
open (O, ">$outputdir/$genomebase.masked") or die $!;
foreach my $s (@$genomeseq){
  print O ">$s->{'header'}\n";
  my $mseq = $rmgenomeseq->[$$rmheaders{$s->{'header'}}]->{'seq'};
  for (my $i = 0; $i < length($mseq); $i += $lineWrap){
    print O substr($mseq, $i, $lineWrap)."\n";
  }
}
close O;
unlink("$outputdir/$genomebase.tmp.masked");

# merge and order gff files according to the sequence order in orginal fasta
#  - label repeats if they are simple or complex
#  - introduce the repeat ID concept
# merge .cat.gz files which contain alignments, and move them to project specific trash can

sub readFasta {
  my ($file, $alphabetcase) = @_;
  my @seq = ();
	my %header_lookup = ();
	my ($header, $seq, $description);
  if ($file =~ /\.gz$/){
    open (F, "gunzip -c $file |") or die $!;
  }
  else{
    open (F, "<$file") or die $!;
  }
  while (<F>){
    chomp $_;
    if ($_ =~ />(\S+)\s*(.*)/){
      if (defined $seq && length($seq)>0) {
        if ($alphabetcase eq "lc") {
          $seq = lc($seq);
        }
        elsif ($alphabetcase eq "uc") {
          $seq = uc($seq);
        }
				push (@seq, {'header'=>$header, 'description'=>$description, 'seq'=>$seq});
 				$header_lookup{$header} = $#seq;
	    }
      $header = $1;
      $description = $2;
      $description = "NoDescription" unless (length($description) > 0);
      $seq = "";
    }
    else {
      $seq .= $_;
    }
  }
  close F;
  if (defined $seq && length($seq)>0) {
    if ($alphabetcase eq "lc") {
      $seq = lc($seq);
    }
    elsif ($alphabetcase eq "uc") {
      $seq = uc($seq);
    }
	  push (@seq, {'header'=>$header, 'description'=>$description, 'seq'=>$seq});
		$header_lookup{$header} = $#seq;
  }
  return (\@seq, \%header_lookup);
}
