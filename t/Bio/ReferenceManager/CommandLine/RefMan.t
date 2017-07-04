#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Files;
use File::Temp;
use Cwd;
use File::Copy;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

# get our copy of ref-stats into the PATH
$ENV{PATH} .= ":../bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::ReferenceManager::CommandLine::RefMan');
}


my $tmp_dir_object = File::Temp->newdir( DIR => getcwd, CLEANUP => 0 );
my $tmp_dirname = $tmp_dir_object->dirname();

my $script_name = 'Bio::ReferenceManager::CommandLine::RefMan';

`echo "valid_file	$tmp_dirname/proddir/valid/file/valid_file.fa" > t/data/CommandLine/expected_refs.index`;

my %scripts_and_expected_files = ( '-r '.$tmp_dirname.'/refstore -d '.$tmp_dirname.'/proddir t/data/CommandLine/valid_file.fa' => [ 't/data/CommandLine/expected_refs.index', $tmp_dirname.'/proddir/refs.index' ] );

mock_execute_script_and_check_output_verbose( $script_name, \%scripts_and_expected_files );
unlink('t/data/CommandLine/expected_refs.index');

done_testing();
