#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;
use Digest::MD5::File;
use Log::Log4perl qw(:easy);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager');
}

my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
my $tmp_dirname = $tmp_dir_object->dirname();

my $obj;

ok(
    $obj = Bio::ReferenceManager->new(
        fasta_files              => ['t/data/ReferenceManager/valid_file.fa'],
        reference_store_dir      => $tmp_dirname . '/temprefs',
        production_reference_dir => $tmp_dirname . '/productiondir',
        name_as_hash => 0,
    ),
    'initialise with valid file with original filename'
);

ok($obj->run, 'prepare the fasta files');
ok(-e $tmp_dirname.'/temprefs/valid/file/valid_file.fa' , 'check file exists');
ok(-e $tmp_dirname.'/temprefs/valid/file/metadata.json' , 'check metadata exists');
ok(-e $tmp_dirname.'/productiondir/valid/file/valid_file.fa' , 'check production fasta file exists');
ok(-e $tmp_dirname.'/productiondir/valid/file/metadata.json' , 'check production metadata exists');
ok(-e $tmp_dirname.'/productiondir/valid/file/valid_file.fa.fai' , 'check samtools file exists');
ok(-e $tmp_dirname.'/productiondir/refs.index' , 'Create top level index of references');

ok(
    $obj = Bio::ReferenceManager->new(
        fasta_files              => ['t/data/ReferenceManager/valid_file.fa'],
        reference_store_dir      => $tmp_dirname . '/temprefs',
        production_reference_dir => $tmp_dirname . '/productiondir',
        name_as_hash => 1
    ),
    'initialise with valid file and hashes as names'
);

ok($obj->run, 'prepare the fasta files with hash');
ok(-e $tmp_dirname .'/temprefs/hash/696fccea7acfb446b4e724611432db7b/'.'696fccea7acfb446b4e724611432db7b.fa' , 'check file exists with hash');
ok(-e $tmp_dirname .'/temprefs/hash/696fccea7acfb446b4e724611432db7b/metadata.json' , 'check metadata exists');

ok(-e $tmp_dirname .'/productiondir/hash/696fccea7acfb446b4e724611432db7b/'.'696fccea7acfb446b4e724611432db7b.fa' , 'check production file exists with hash');
ok(-e $tmp_dirname .'/productiondir/hash/696fccea7acfb446b4e724611432db7b/metadata.json' , 'check production metadata exists');
ok(-e $tmp_dirname .'/productiondir/refs.index' , 'check toplevel refs index exists');


done_testing();
