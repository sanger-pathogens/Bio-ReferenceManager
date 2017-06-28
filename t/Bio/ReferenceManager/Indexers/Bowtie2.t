#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::Indexers::Bowtie2');
}

my $obj;

ok( $obj = Bio::ReferenceManager::Indexers::Bowtie2->new( fasta_file => 'abc.fa' ), 'initialise with defaults' );
is( $obj->_get_version_command, 'bowtie2-build --version 2>&1', 'get version command' );
ok( my $software_version = $obj->software_version(), 'get software version' );
like( $software_version, qr/^[]\d]+\.[\d]+/, 'got a version number out' );
is( $obj->index_command, 'bowtie2-build abc.fa abc.fa', 'indexing command' );

is_deeply( $obj->expected_files, [ 'abc.fa.1.bt2', 'abc.fa.2.bt2', 'abc.fa.3.bt2', 'abc.fa.4.bt2' ], 'expected files' );

done_testing();
