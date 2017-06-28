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

ok( $obj = Bio::ReferenceManager::Indexers::RefStats->new(), 'initialise with defaults');
is( $obj->_get_version_command, 'ref-stats  2>&1', 'get version command' );
is($obj->software_version(), '', 'got no version number out');

done_testing();
