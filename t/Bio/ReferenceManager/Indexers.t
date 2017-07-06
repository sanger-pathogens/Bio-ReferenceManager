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

copy( 't/data/Indexers/valid_file.fa', $tmp_dirname );

ok(
    $obj = Bio::ReferenceManager::Indexers->new(
        output_base_dir      => $tmp_dirname,
        fasta_file           => $tmp_dirname . '/valid_file.fa',
        indexing_executables => [ { class => 'Bowtie2' } ]
    ),
    'initialise object with defaults for 1 indexer'
);

ok( $obj->create_index_files, 'create all default index files' );

for my $file ( ( '.1.bt2', '.2.bt2', '.3.bt2', '.4.bt2', '.rev.1.bt2', '.rev.2.bt2' ) ) {
    ok( -e $tmp_dirname . '/valid_file.fa' . $file, 'check expected output file exists for ' . $file );
}

# Picard not included here because of java issues on OSX
ok(
    $obj = Bio::ReferenceManager::Indexers->new(
        output_base_dir => $tmp_dirname,
        fasta_file      => $tmp_dirname . '/valid_file.fa',
        indexing_executables =>
          [ { class => 'Bowtie2' }, { class => 'Bwa' }, { class => 'RefStats' }, { class => 'Samtools' }, { class => 'Smalt' } ]
    ),
    'initialise object with defaults for all indexers, except picard'
);

ok( $obj->create_index_files, 'create all default index files' );
for my $file (
    (
        '.fai', '.1.bt2', '.2.bt2', '.3.bt2', '.4.bt2',    '.rev.1.bt2',   '.rev.2.bt2', '.amb',
        '.ann', '.bwt',   '.pac',   '.sa',    '.refstats', '.default.sma', '.default.smi'
    )
  )
{
    ok( -e $tmp_dirname . '/valid_file.fa' . $file, 'check expected output file exists for ' . $file );
}

# Check that subdirectories are created for each indexer and that the expected files are there for each.
my %indexer_to_files = ( 'Bowtie2' => [ '.1.bt2', '.2.bt2', '.3.bt2', '.4.bt2', '.rev.1.bt2', '.rev.2.bt2' ],
'Bwa' => ['.amb', '.ann', '.bwt', '.pac', '.sa'],
'RefStats' => ['.refstats'],
'Samtools' => ['.fai'],
'Smalt'  => ['.default.sma', '.default.smi' ],
 );

for my $software ( keys %indexer_to_files ) {
    my $index_class = "Bio::ReferenceManager::Indexers::" . $software;
    eval "require $index_class";

    my $indexer_directory =
      $index_class->new( output_base_dir => $tmp_dirname, fasta_file => $tmp_dirname . '/valid_file.fa' )->versioned_directory_name();
    ok( -d $indexer_directory, 'directory created with files' );
    
    for my $file (@{$indexer_to_files{$software}})
    {
        ok( -e $indexer_directory . '/valid_file.fa' . $file, 'check expected output file exists for ' . $file.' in subdirectory for default '.$software );
    }
}

done_testing();

