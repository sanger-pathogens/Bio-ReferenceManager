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

ok( $obj = Bio::ReferenceManager::Indexers::Bwa->new(), 'initialise with defaults');
is( $obj->_get_version_command, 'bwa  2>&1', 'get version command' );
ok(my $software_version = $obj->software_version(), 'get software version');
like($software_version, qr/^[]\d]+\.[\d]+/, 'got a version number out');

done_testing();
