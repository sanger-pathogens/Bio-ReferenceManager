#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;
use File::Copy;
use Digest::MD5::File;

BEGIN { unshift( @INC, './lib' ) }
# get our copy of ref-stats into the PATH
$ENV{PATH} .= ":../bin";


BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::Indexers');
}

my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
my $tmp_dirname = $tmp_dir_object->dirname();
my $obj;

copy('t/data/Indexers/valid_file.fa', $tmp_dirname);

ok( $obj = Bio::ReferenceManager::Indexers->new(fasta_file => $tmp_dirname.'/valid_file.fa', indexing_executables => [
    { class => 'Bowtie2' },
    { class => 'Bwa'},
    { class => 'RefStats' },
    { class => 'Samtools'},
    { class => 'Smalt' }
]), 'initialise object with all defaults' );

ok($obj->create_index_files, 'create all default index files');

done_testing();
