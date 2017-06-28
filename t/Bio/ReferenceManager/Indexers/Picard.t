#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::Indexers::Picard');
}
my $cwd = getcwd();
my $obj;

ok( $obj = Bio::ReferenceManager::Indexers::Picard->new(
     executable => $cwd.'/t/bin/dummy_picard',
     fasta_file => 'abc.fa'
), 'initialise with defaults');
ok(my $software_version = $obj->software_version(), 'get software version');
like($software_version, qr/^[]\d]+\.[\d]+/, 'got a version number out');
is( $obj->index_command, $cwd.'/t/bin/dummy_picard R=abc.fa O=abc.fa.dict', 'indexing command');

done_testing();
