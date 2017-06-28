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

my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 0 );
my $tmp_dirname = $tmp_dir_object->dirname();
my $obj;

copy( 't/data/Indexers/valid_file.fa', $tmp_dirname );

# Picard not included here because of java issues on OSX
ok(
    $obj = Bio::ReferenceManager::Indexers->new(
        fasta_file => $tmp_dirname . '/valid_file.fa',
        indexing_executables =>
          [ { class => 'Bowtie2' }, { class => 'Bwa' }, { class => 'RefStats' }, { class => 'Samtools' }, { class => 'Smalt' } ]
    ),
    'initialise object with all defaults'
);

ok( $obj->create_index_files, 'create all default index files' );
print $tmp_dirname ."\n";

for my $file (('.fai', '.1.bt2', '.2.bt2', '.3.bt2', '.4.bt2','.rev.1.bt2','.rev.2.bt2', '.amb', '.ann', '.bwt', '.pac', '.sa', '.refstats','.default.sma', '.default.smi' ))
{
    ok(-e $tmp_dirname.'/valid_file.fa'.$file,'check expected output file exists for '.$file);
}

done_testing();
