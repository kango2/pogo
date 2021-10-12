#!/usr/bin/perl -w
use strict;

my %genetic_code  = (
'TCA' => 'S','TCC' => 'S','AGC' => 'S','AGT' => 'S','TCG' => 'S','TCT' => 'S',
'TTC' => 'F','TTT' => 'F',
'TTA' => 'L','TTG' => 'L','CTC' => 'L','CTG' => 'L','CTT' => 'L','CTA' => 'L',
'TAC' => 'Y','TAT' => 'Y',
'TAA' => '*','TAG' => '*','TGA' => '*',
'TGC' => 'C','TGT' => 'C',
'TGG' => 'W',
'CCA' => 'P','CCC' => 'P','CCG' => 'P','CCT' => 'P',
'CAT' => 'H','CAC' => 'H',
'CAA' => 'Q','CAG' => 'Q',
'CGA' => 'R','CGC' => 'R','AGA' => 'R','AGG' => 'R','CGG' => 'R','CGT' => 'R',
'ATA' => 'I','ATC' => 'I','ATT' => 'I',
'ATG' => 'M',
'ACA' => 'T','ACC' => 'T','ACG' => 'T','ACT' => 'T',
'AAC' => 'N','AAT' => 'N',
'AAA' => 'K','AAG' => 'K',
'GTA' => 'V','GTC' => 'V','GTG' => 'V','GTT' => 'V',
'GCA' => 'A','GCC' => 'A','GCG' => 'A','GCT' => 'A',
'GAC' => 'D','GAT' => 'D',
'GAA' => 'E','GAG' => 'E',
'GGA' => 'G','GGC' => 'G','GGG' => 'G','GGT' => 'G',
);

##7924
#556017
#495829
#263684
#137246
#-78394
#78394
#-71168
#71168
#27777
#588576
#7755
#682882
#651721
#9301

my ($queryfasta, $reffasta, $blastx, $qspeciestaxid, $qspeciesdatasetid, $qspeciesname, $idmappings, $outputdir) = @ARGV;
die "$outputdir doesnt exitst\n" unless (-d $outputdir);
$outputdir .= "/" unless ($outputdir =~ /\/$/);

my %speciesid = ();
open (F, "<$idmappings") or die $!;
while (<F>){
  chomp $_;
  my @a = split ("\t", $_);
  if ($a[1] eq "NCBI_TaxID"){
    $speciesid{$a[0]} = $a[2];
  }
}
close F;

my %cdnaseq = ();
my $seqid = "";
my $desc  = "";
open (F, "<$queryfasta") or die $!;
while (<F>){
  chomp $_;
  if ($_ =~ />(\S+) (.*)/){
    $seqid = $1;
    $desc  = $2;
    $cdnaseq{$seqid}{'description'} = $desc;
  }
  else{
    $cdnaseq{$seqid}{'seq'} .= $_;
  }
}
close F;

open (F, "<$reffasta") or die $!;
my %peptideseq = ();
$seqid = "";
$desc  = "";
while (<F>){
  chomp $_;
  if ($_ =~ />(\S+) (.*)/){
    $seqid = $1;
    $desc  = $2;
  }
  else{
    $peptideseq{$seqid}{'seq'} .= $_;
  }
}
close F;

my %translationseen = ();
open (F, "<$blastx") or die $!;
while (<F>){
  chomp $_;
  my @a = split ("\t", $_);
  $a[11] =~ s/\s*//g;
  next if ($a[3] <= 30 || $a[10] > 0.001);
  push(@{$cdnaseq{$a[0]}{'alignments'}}, join("\t", @a[1..$#a]));
  my ($cds, $translation, $cds_start, $cds_end, $cdna, $strand) = get_translation(@a);
  if (length($translation) > 30){
    my $id = $a[0];
    unless (exists $translationseen{$a[0]}){
      $cdnaseq{$a[0]}{'seq'} = $cdna;
      $cdnaseq{$a[0]}{'translation'} = $translation;
      $cdnaseq{$a[0]}{'cds'} = $cds;
      $cdnaseq{$a[0]}{'cds_start'} = $cds_start;
      $cdnaseq{$a[0]}{'cds_end'} = $cds_end;
      @{$cdnaseq{$a[0]}{'translation_alignment'}} = @a[1..$#a];
      $translationseen{$a[0]}="";
    }
  }
}
close F;

open (CDS,   ">$outputdir$qspeciesname.CDS.fa") or die $!;
open (CDNA,  ">$outputdir$qspeciesname.CDNA.fa") or die $!;
open (AASEQ, ">$outputdir$qspeciesname.AA.fa") or die $!;
open (AA2NT, ">$outputdir$qspeciesname.AA2NT.txt") or die $!;
open (SIM,   ">$outputdir$qspeciesname.similarity.txt") or die $!;
open (SEQ,   ">$outputdir$qspeciesname.sequence.txt") or die $!;
open (ANN,   ">$outputdir$qspeciesname.annotation.txt") or die $!;
open (NC,    ">$outputdir$qspeciesname.NCCDNA.fa") or die $!;

foreach my $id (keys %cdnaseq){
  if (exists $cdnaseq{$id}{'translation'}){
    print AA2NT "$id.p\t$id\t$cdnaseq{$id}{'cds_start'}\t$cdnaseq{$id}{'cds_end'}\t1\n";
    print SEQ   "$qspeciesdatasetid\t$id.p\t$qspeciestaxid\t".join(":", @{$cdnaseq{$id}{'translation_alignment'}})."\t$cdnaseq{$id}{'translation'}\t5\n";
    print CDS   ">$id\n$cdnaseq{$id}{'cds'}\n";
    print ANN   "$id.p\ttrinity\tna\tna\n";
    print AASEQ ">$id\n$cdnaseq{$id}{'translation'}\n";
    print CDNA  ">$id Start:$cdnaseq{$id}{'cds_start'} End:$cdnaseq{$id}{'cds_end'}\n$cdnaseq{$id}{'seq'}\n";
  }
  else{
    print NC ">$id Start:-1 End:-1\n$cdnaseq{$id}{'seq'}\n";
  }
  print SEQ "$qspeciesdatasetid\t$id\t$qspeciestaxid\t$cdnaseq{$id}{'description'}\t$cdnaseq{$id}{'seq'}\t4\n";
  print ANN "$id\ttrinity\tna\tna\n";
  foreach my $aln (@{$cdnaseq{$id}{'alignments'}}){
    my @aln = split("\t", $aln);
    my @b = split (/\|/, $aln[0]);
    print SIM "2\t$qspeciesdatasetid\t$id\t$qspeciestaxid\t1\t$b[1]\t".((exists $speciesid{$b[1]}) ? $speciesid{$b[1]} : "0000")."\t".join("\t", @aln[1..$#aln])."\n";
  }
}

sub get_translation {
  my ($qid, $sid, $pid, $alen, $mm, $gapo, $qstart, $qend, $sstart, $send, $evalue, $bitscore) = @_;
  my $frame = ($qstart < $qend) ? 1 : -1;
  
  ###check if you can look upstream/downstream or not
  my $cdna = $cdnaseq{$qid}{'seq'};
  my $aln_cds_start = $qstart;
  my $aln_cds_end   = $qend;
  ###reverse the sequence for -ve frame
  if ($frame < 0){
    $cdna = reverse($cdna);
    $cdna =~ tr/ACGT/TGCA/;
    $aln_cds_start = length($cdna) - $qstart + 1;
    $aln_cds_end   = length($cdna) - $qend   + 1;
  }
  ####get the translation as defined by the alignments
  my $aln_translation = "";
  my $aln_cds         = substr($cdna, $aln_cds_start - 1, $aln_cds_end - $aln_cds_start + 1);
  
  for (my $i=0;$i<=length($aln_cds)-3;$i+=3){
    $aln_translation .= (exists $genetic_code{substr($aln_cds, $i, 3)}) ? $genetic_code{substr($aln_cds, $i, 3)} : "X";
  }
  
  #if ($qid eq "comp703_c0_seq1"){
  #  print "BEFORE:\n";
  #  print "$aln_translation\n";
  #  print join("\t", ($qid, $sid, $pid, $alen, $mm, $gapo, $qstart, $qend, $sstart, $send, $evalue, $bitscore))."\n";
  #}
  ###rules for extension are that it needs to go up to the stop codon and then search for start codon within it
  my $five_extra_translation = undef;
  my $newstart = undef;
  my %five_translations = ();
  for (my $i=$aln_cds_start - 4;$i>=0;$i-=3){
    my $this_aa = (exists $genetic_code{substr($cdna, $i, 3)}) ? $genetic_code{substr($cdna, $i, 3)} : "X";
    if ($this_aa eq "M"){
      $five_extra_translation = (defined $five_extra_translation) ? "$this_aa$five_extra_translation" : "$this_aa";
      $newstart = $i + 1;
      $five_translations{'M'}{$newstart} = $five_extra_translation;
    }
    elsif ($this_aa eq "*"){
      $newstart = $i + 4;
      $five_translations{'other'}{$newstart} = (defined $five_extra_translation) ? "$five_extra_translation" : "";
      goto STOPFOUND;
    }
    else {
      $five_extra_translation = (defined $five_extra_translation) ? "$this_aa$five_extra_translation" : "$this_aa";
      $newstart = $i+1;
    }
  }
  $five_translations{'other'}{$newstart} = $five_extra_translation if (defined $five_extra_translation && defined $newstart);
STOPFOUND:
  
  ###if the extra translation has found the start codon then well and good, if not then see if there is a start codon in the aln_translation
  if (exists $five_translations{'M'}){
    foreach my $mposition (sort {$a<=>$b} keys %{$five_translations{'M'}}){
      $aln_cds_start = $mposition;
      $aln_cds = substr($cdna, $aln_cds_start - 1, $aln_cds_end - $aln_cds_start + 1);
      $aln_translation = "$five_translations{'M'}{$mposition}$aln_translation";
      last;
    }
  }
  else{
    my $methionine_position = index($aln_translation, "M");
    ###start codon found within the alignment range
    if ($methionine_position >= 0 && $sstart <= length($peptideseq{$sid}) / 10 && $methionine_position <= length($aln_translation) / 10){
      $aln_cds_start = $aln_cds_start + ($methionine_position * 3);
      $aln_cds = substr($cdna, $aln_cds_start - 1, $aln_cds_end - $aln_cds_start + 1);
      $aln_translation = substr($aln_translation, $methionine_position);
    }
    ###no start codon found
    else{
      if (exists $five_translations{'other'}){
        foreach my $mposition (sort {$a<=>$b} keys %{$five_translations{'other'}}){
          $aln_cds_start = $mposition;
          $aln_cds = substr($cdna, $aln_cds_start - 1, $aln_cds_end - $aln_cds_start + 1);
          $aln_translation = "$five_translations{'other'}{$mposition}"."$aln_translation";
          last;
        }
      }
    }
  }
  #####check if the stop codon is already present in the translation, if so then adjust the coordinates and sequences
  my $stopcodon_position = index($aln_translation, "*");
  if ($stopcodon_position >= 0){
    $aln_cds_end = $aln_cds_start + ($stopcodon_position * 3 - 1) + 3; ###added three to include the stop codon
    $aln_cds = substr($cdna, $aln_cds_start - 1, $aln_cds_end - $aln_cds_start + 1);
    $aln_translation = substr($aln_translation, 0, $stopcodon_position+1); ##added 1 to length for including the stop codon
  }
  ###no stop codon found so search for it downstream of the existing sequence
  else{
    my $three_extra_translation = undef;
    my $newend = undef;
    for (my $i=$aln_cds_end; $i<=length($cdna) - 3; $i+=3){
      my $this_aa = (exists $genetic_code{substr($cdna, $i, 3)}) ? $genetic_code{substr($cdna, $i, 3)} : "X";
      if ($this_aa eq "*"){
        ###mask the following after testing
        $three_extra_translation .= $this_aa;
        $newend = $i + 3;
        last;
      }
      else{
        $three_extra_translation .= $this_aa;
        $newend = $i + 3;
      }
    }
    if (defined $three_extra_translation && defined $newend){
      $aln_cds_end = $newend;
      $aln_cds = substr($cdna, $aln_cds_start - 1, $aln_cds_end - $aln_cds_start + 1);
      $aln_translation .= $three_extra_translation;
    }
  }
  return ($aln_cds, $aln_translation, $aln_cds_start, $aln_cds_end, $cdna, $frame);
}

