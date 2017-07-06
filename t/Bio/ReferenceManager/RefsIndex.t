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
    use_ok('Bio::ReferenceManager::RefsIndex');
}
my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
my $tmp_dirname = $tmp_dir_object->dirname();
copy( 't/data/RefsIndex/valid_refs.index' , $tmp_dirname );

my $obj;

# Check a new reference gets added
ok($obj = Bio::ReferenceManager::RefsIndex->new(index_filename => $tmp_dirname.'/valid_refs.index', reference_filename => '/path/to/somewhere/newreference.fa'), 'initialise adding a new reference');
is($obj->reference_prefix, 'newreference', 'get the filename minus extension');
is_deeply($obj->reference_names_to_files, {ref1 => '/path/to/refs/ref1.fa',ref2 => '/path/to/refs/ref2.fa'} , 'get the current references');
ok($obj->add_reference_to_index, 'add the reference to the file');
is_deeply($obj->reference_names_to_files, {ref1 => '/path/to/refs/ref1.fa',ref2 => '/path/to/refs/ref2.fa', newreference => '/path/to/somewhere/newreference.fa'} , 'reference should now be in the file');


# Check that a reference doesnt get added twice
copy( 't/data/RefsIndex/valid_refs.index' , $tmp_dirname );
ok($obj = Bio::ReferenceManager::RefsIndex->new(index_filename => $tmp_dirname.'/valid_refs.index', reference_filename => '/path/to/refs/ref1.fa'), 'initialise adding a new reference');
ok($obj->add_reference_to_index, 'dont add a reference because its there already');

compare_ok( 't/data/RefsIndex/valid_refs.index', $tmp_dirname.'/valid_refs.index', 'The index file should not have changed since the reference was already there' );

done_testing();
