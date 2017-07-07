#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;
use File::Copy;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::NCBI::RefSeqAssembly');
}

my $obj;

ok($obj = Bio::ReferenceManager::NCBI::RefSeqAssembly->new(species => 'Campylobacter coli', strain => "ABC", accession => 'GCF_001865555.1', ftp_directory => 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/865/555/GCF_001865555.1_ASM186555v1'), 'initialise object');

is($obj->downloaded_filename, 'GCF_001865555.1_ASM186555v1_genomic.fna.gz', 'Download filename');
is($obj->download_url, 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/865/555/GCF_001865555.1_ASM186555v1/GCF_001865555.1_ASM186555v1_genomic.fna.gz', 'Download url');
is($obj->normalised_species_name, 'Campylobacter_coli_ABC_GCF_001865555_1', 'normalised species name');



ok($obj = Bio::ReferenceManager::NCBI::RefSeqAssembly->new(species => 'Buchnera aphidicola str. Bp (Baizongia pistaciae)', strain => "strain=Bp (Baizongia pistaciae)", accession => 'GCF_001234567.1', ftp_directory => 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/865/555/GCF_001234567.1_ASM186555v1'), 'initialise object with a strain equals string');

is($obj->normalised_species_name, 'Buchnera_aphidicola_str_Bp_Baizongia_pistaciae_GCF_001234567_1', 'normalised species name with duplicate strain removed');


done_testing();

