#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::Indexers::Bwa');
}

my $obj;

ok( $obj = Bio::ReferenceManager::Indexers::Bwa->new( fasta_file => 'abc.fa' ), 'initialise with defaults' );
is( $obj->_get_version_command, 'bwa  2>&1', 'get version command' );
ok( my $software_version = $obj->software_version(), 'get software version' );
like( $software_version, qr/^[]\d]+\.[\d]+/, 'got a version number out' );
is( $obj->index_command, 'bwa index abc.fa', 'indexing command' );

is_deeply( $obj->expected_files('.'), [ './abc.fa.amb', './abc.fa.ann', './abc.fa.bwt', './abc.fa.pac', './abc.fa.sa' ], 'expected files' );
done_testing();
