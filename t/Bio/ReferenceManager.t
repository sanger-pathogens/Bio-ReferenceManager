#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;
use DBICx::TestDatabase;
use Digest::MD5::File;
use Log::Log4perl qw(:easy);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager');
}

my $dbh = DBICx::TestDatabase->new('Bio::ReferenceManager::VRTrack::Schema');
$dbh->resultset('Assembly')->create( { name => 'abc', reference_size => 123 } );

my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
my $tmp_dirname = $tmp_dir_object->dirname();

my $obj;

ok(
    $obj = Bio::ReferenceManager->new(
        fasta_files              => ['t/data/ReferenceManager/valid_file.fa'],
        reference_store_dir      => $tmp_dirname . '/temprefs',
        production_reference_dir => $tmp_dirname . '/productiondir',
        name_as_hash             => 0,
        dbh                      => $dbh
    ),
    'initialise with valid file with original filename'
);

ok( $obj->run,                                                       'prepare the fasta files' );
ok( -e $tmp_dirname . '/temprefs/valid/file/valid_file.fa',          'check file exists' );
ok( -e $tmp_dirname . '/temprefs/valid/file/metadata.json',          'check metadata exists' );
ok( -e $tmp_dirname . '/productiondir/valid/file/valid_file.fa',     'check production fasta file exists' );
ok( -e $tmp_dirname . '/productiondir/valid/file/metadata.json',     'check production metadata exists' );
ok( -e $tmp_dirname . '/productiondir/valid/file/valid_file.fa.fai', 'check samtools file exists' );
ok( -e $tmp_dirname . '/productiondir/refs.index',                   'Create top level index of references' );

my $assembly_search = $dbh->resultset('Assembly')->search({  name => 'valid_file'})->first();
is($assembly_search->name,'valid_file', 'got the name of the assembly');
is($assembly_search->reference_size,3000, 'got the length of the assembly');


ok(
    $obj = Bio::ReferenceManager->new(
        fasta_files              => ['t/data/ReferenceManager/valid_file.fa'],
        reference_store_dir      => $tmp_dirname . '/temprefs',
        production_reference_dir => $tmp_dirname . '/productiondir',
        name_as_hash             => 1,
        dbh                      => $dbh
    ),
    'initialise with valid file and hashes as names'
);

ok( $obj->run, 'prepare the fasta files with hash' );
ok(
    -e $tmp_dirname . '/temprefs/hash/696fccea7acfb446b4e724611432db7b/' . '696fccea7acfb446b4e724611432db7b.fa',

    'check file exists with hash'
);
ok( -e $tmp_dirname . '/temprefs/hash/696fccea7acfb446b4e724611432db7b/metadata.json', 'check metadata exists' );

ok( -e $tmp_dirname . '/productiondir/hash/696fccea7acfb446b4e724611432db7b/' . '696fccea7acfb446b4e724611432db7b.fa',
    'check production file exists with hash' );
ok( -e $tmp_dirname . '/productiondir/hash/696fccea7acfb446b4e724611432db7b/metadata.json', 'check production metadata exists' );
ok( -e $tmp_dirname . '/productiondir/refs.index',                                          'check toplevel refs index exists' );


$assembly_search = $dbh->resultset('Assembly')->search({  name => '696fccea7acfb446b4e724611432db7b'})->first();
is($assembly_search->name,'696fccea7acfb446b4e724611432db7b', 'got the name of the assembly where its a hash');
is($assembly_search->reference_size,3000, 'got the length of the assembly where its a hash');

done_testing();
