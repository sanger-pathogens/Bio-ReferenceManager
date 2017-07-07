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
    use_ok('Bio::ReferenceManager::NCBI::AssemblyMetadata');
}

my $obj;

ok($obj = Bio::ReferenceManager::NCBI::AssemblyMetadata->new(assembly_summary_filename => 't/data/NCBI/assembly_summary.txt', download_only_new => 0, dont_redownload_assembly_stats => 1), 'initialise obj all genomes');

ok(my $refseq_assemblies = $obj->extract_complete_genomes, 'extract out assembly metadata for all genomes');
is(@{$refseq_assemblies}, 17, 'Should be 17 assemblies');


ok($obj = Bio::ReferenceManager::NCBI::AssemblyMetadata->new(assembly_summary_filename => 't/data/NCBI/assembly_summary.txt', download_only_new => 1, index_filename => 't/data/NCBI/refs.index', dont_redownload_assembly_stats => 1), 'initialise obj all genomes');

ok( $refseq_assemblies = $obj->new_genomes, 'extract out assembly metadata for new genomes only');
is(@{$refseq_assemblies}, 15, 'Should be 15 assemblies');


done_testing();


