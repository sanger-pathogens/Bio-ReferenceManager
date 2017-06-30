#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use Bio::ReferenceManager::Reference;
    use_ok('Bio::ReferenceManager::VRTrack::Assemblies');
}

my $dbh = DBICx::TestDatabase->new('Bio::ReferenceManager::VRTrack::Schema');
$dbh->resultset('Assembly')->create({  name => 'abc',  reference_size => 123});
$dbh->resultset('Assembly')->create({  name => 'abc2',  reference_size => 1234});

my $obj;

my $reference1 = Bio::ReferenceManager::Reference->new(final_filename => '/path/to/abc.fa', sequence_length => 123, basename => 'abc');
my $reference2 = Bio::ReferenceManager::Reference->new(final_filename => '/path/to/abc2.fa', sequence_length => 1234, basename => 'abc2');
my $reference_not_in_db = Bio::ReferenceManager::Reference->new(final_filename => '/path/to/novel.fa', sequence_length => 9876, basename => 'novel');

ok($obj = Bio::ReferenceManager::VRTrack::Assemblies->new(dbh => $dbh, references => [$reference1, $reference2]), 'initialise assembly where all references are in the database already');
is_deeply([], $obj->references_needing_to_be_added, 'no references should need to be added');
is(0, $obj->insert_references_into_assembly_table, 'no references added');

ok($obj = Bio::ReferenceManager::VRTrack::Assemblies->new(dbh => $dbh, references => [$reference1, $reference2,$reference_not_in_db]), 'initialise assembly where one reference out of 3 needs to be added');
is_deeply([$reference_not_in_db], $obj->references_needing_to_be_added, '1 reference should be added');
is(1, $obj->insert_references_into_assembly_table, '1 reference added');

done_testing();
