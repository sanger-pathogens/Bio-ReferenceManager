#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::PrepareFasta');
}

my $tmp_dir_object = File::Temp->newdir( CLEANUP => 1 ); 
my $tmp_dirname = $tmp_dir_object->dirname();

my $obj;

ok($obj = Bio::ReferenceManager::PrepareFasta->new(fasta_file => 't/data/PrepareFasta/odd_chars_in_sequence.fa', 
reference_store_dir => $tmp_dirname ), 'odd chars in sequence init');
ok($obj->fix_file_and_save(), 'fix file');
compare_ok('t/data/PrepareFasta/expected_odd_chars_in_sequence.fa',
    $tmp_dirname."/xxxx/xxx.fa",
    'fix odd characters in sequence'
);

ok($obj = Bio::ReferenceManager::PrepareFasta->new(fasta_file => 't/data/PrepareFasta/sequence_names_odd_characters.fa', 
reference_store_dir => $tmp_dirname ), 'odd chars in sequence name init');
ok($obj->fix_file_and_save(), 'fix file');
compare_ok('t/data/PrepareFasta/expected_sequence_names_odd_characters.fa',
    $tmp_dirname."/xxxx/xxx.fa",
    'fix odd characters in sequence name'
);

ok($obj = Bio::ReferenceManager::PrepareFasta->new(fasta_file => 't/data/PrepareFasta/sequence_names_out_of_order.fa', 
reference_store_dir => $tmp_dirname ), 'seq names out of order init');
ok($obj->fix_file_and_save(), 'fix file');
compare_ok('t/data/PrepareFasta/expected_sequence_names_out_of_order.fa',
    $tmp_dirname."/xxxx/xxx.fa",
    'fix seq names out of order'
);

ok($obj = Bio::ReferenceManager::PrepareFasta->new(fasta_file => 't/data/PrepareFasta/windows_format.fa', 
reference_store_dir => $tmp_dirname ), 'windows format init');
ok($obj->fix_file_and_save(), 'fix file');
compare_ok('t/data/PrepareFasta/expected_windows_format.fa',
    $tmp_dirname."/xxxx/xxx.fa",
    'fix windows format'
);

done_testing();
