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

ok($obj = Bio::ReferenceManager::NCBI::AssemblyMetadata->new(assembly_summary_filename => 't/data/NCBI/assembly_summary.txt'), 'initialise obj');

ok(my $refseq_assemblies = $obj->extract_complete_genomes, 'extract out assembly metadata');
is(@{$refseq_assemblies}, 6, 'Should be 6 assemblies');


done_testing();
