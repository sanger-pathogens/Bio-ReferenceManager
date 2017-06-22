package Bio::ReferenceManager::PrepareFasta;

# ABSTRACT: Take in a fasta file, fix it up, save it

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;
use File::Copy;
use Bio::Perl;

#Take FASTA(s) as input
#Run in parallel
#Dos2unix
#Is it a valid FASTA file? 
#Replace non-ACGTN- with N
#Fix sequence names (max length, name present, illegal characters)
#Sort sequences by name
#Hash the file
#Copy the file to central store, named with Hash (in directory called Hash).
#Store original filename as metadata + any other info about sample (species etc..). JSON flatfile for all references or sqlite.
#
#
#dos2unix
#Is it valid FASTA?
#fastaq acgtn_only
#fastaq sort_by_name
#enumerate_names


has 'fasta_file'            => ( is => 'ro', isa => 'Str', required => 1 );
has 'reference_store_dir'   => ( is => 'rw', isa => 'Str', required => 1 );






no Moose;
__PACKAGE__->meta->make_immutable;

1;
