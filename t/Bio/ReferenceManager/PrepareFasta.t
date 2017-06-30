#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;
use Digest::MD5::File;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::PrepareFasta');
}


my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
my $tmp_dirname = $tmp_dir_object->dirname();

my $obj;

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/invalid_file.fa',
        reference_store_dir => $tmp_dirname,
    ),
    'invalid file init'
);
is( $obj->is_valid_fasta('t/data/PrepareFasta/invalid_file.fa'), 0, 'check if the file is valid' );

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/odd_chars_in_sequence.fa',
        reference_store_dir => $tmp_dirname
    ),
    'odd chars in sequence init'
);
ok( $obj->_run_dos2unix(),     'run the dos2unix command' );
ok( $obj->fix_file_and_save(), 'fix file' );
compare_ok( 't/data/PrepareFasta/expected_odd_chars_in_sequence.fa', $obj->reference->final_filename(), 'fix odd characters in sequence' );

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/odd_chars_in_sequence.fa',
        name_as_hash        => 0,
        reference_store_dir => $tmp_dirname
    ),
    'use input name as output name init'
);
$obj->fix_file_and_save();
is( $obj->reference->final_filename(), $tmp_dirname . '/odd/chars/odd_chars_in_sequence.fa', 'output name should match input' );
compare_ok(
    't/data/PrepareFasta/expected_odd_chars_in_sequence.fa',
    $obj->reference->final_filename(),
    'same contents with input name as output filename '
);

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/sequence_names_odd_characters.fa',
        reference_store_dir => $tmp_dirname
    ),
    'odd chars in sequence name init'
);
ok( $obj->fix_file_and_save(), 'fix file' );
compare_ok(
    't/data/PrepareFasta/expected_sequence_names_odd_characters.fa',
    $obj->reference->final_filename(),
    'fix odd characters in sequence name'
);

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/sequence_names_out_of_order.fa',
        reference_store_dir => $tmp_dirname
    ),
    'seq names out of order init'
);
ok( $obj->fix_file_and_save(), 'fix file' );
compare_ok( 't/data/PrepareFasta/expected_sequence_names_out_of_order.fa', $obj->reference->final_filename(),
    'fix seq names out of order' );

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/windows_format.fa',
        reference_store_dir => $tmp_dirname
    ),
    'windows format init'
);
ok( $obj->fix_file_and_save(), 'fix file' );
compare_ok( 't/data/PrepareFasta/expected_windows_format.fa', $obj->reference->final_filename(), 'fix windows format' );

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/valid_file.fa',
        name_as_hash        => 1,
        reference_store_dir => $tmp_dirname
    ),
    'Valid file with hash has name'
);
$obj->fix_file_and_save();
my $expected_file = $tmp_dirname.'/hash/696fccea7acfb446b4e724611432db7b/696fccea7acfb446b4e724611432db7b.fa';
is( $obj->reference->final_filename(),$expected_file, 'Check has directory structure' );
ok(-e $expected_file, 'File exists');

ok(
    $obj = Bio::ReferenceManager::PrepareFasta->new(
        fasta_file          => 't/data/PrepareFasta/valid_file.fa',
        name_as_hash        => 0,
        reference_store_dir => $tmp_dirname
    ),
    'Valid file with sample as name'
);
$obj->fix_file_and_save();
$expected_file = $tmp_dirname.'/valid/file/valid_file.fa';
is( $obj->reference->final_filename(),$expected_file, 'Check has directory structure' );
ok(-e $expected_file, 'File exists');


done_testing();
