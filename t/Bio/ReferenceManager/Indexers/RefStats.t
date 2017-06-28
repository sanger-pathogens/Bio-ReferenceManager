#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::Indexers::RefStats');
}

my $obj;

ok( $obj = Bio::ReferenceManager::Indexers::RefStats->new( fasta_file => 'abc.fa' ), 'initialise with defaults' );
is( $obj->_get_version_command, 'ref-stats  2>&1',                       'get version command' );
is( $obj->software_version(),   '',                                      'got no version number out' );
is( $obj->index_command,        'ref-stats -r abc.fa > abc.fa.refstats', 'indexing command' );
is_deeply( $obj->expected_files, ['abc.fa.refstats'], 'expected files' );

done_testing();
