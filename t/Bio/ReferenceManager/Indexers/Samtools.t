#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::Indexers::Samtools');
}

my $obj;

ok( $obj = Bio::ReferenceManager::Indexers::Samtools->new( fasta_file => 'abc.fa' ), 'initialise with defaults' );
is( $obj->_get_version_command, 'samtools  2>&1', 'get version command' );
ok( my $software_version = $obj->software_version(), 'get software version' );
like( $software_version, qr/^[]\d]+\.[\d]+/, 'got a version number out' );
is( $obj->index_command('abc.fa'), 'samtools faidx abc.fa', 'indexing command' );
is_deeply( $obj->expected_files('.'), [ './abc.fa.fai' ], 'expected files' );

my $samtools_htslib_version = "Version: 1.3 (using htslib 1.3)";
my $regex = $obj->version_regex;
$samtools_htslib_version =~ m/$regex/;
my $version_str =  $1;
is( $version_str, '1.3', 'Check that new version style can be extracted');

done_testing();
