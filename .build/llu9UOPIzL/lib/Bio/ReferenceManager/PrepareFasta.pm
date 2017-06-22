package Bio::ReferenceManager::PrepareFasta;

# ABSTRACT: Take in a fasta file, fix it up, save it

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;
use File::Copy;
use File::Temp;
use Cwd;

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

has 'dos2unix_exec'   => ( is => 'rw', isa => 'Str', default => 'dos2unix' );


has '_tmp_dir_object' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_tmp_dir'        => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__tmp_dir' );


sub _build__tmp_dir {
    my ($self) = @_;
    return $self->_tmp_dir_object->dirname();
}

sub fix_file_and_save()
{
        my ($self) = @_;
        $self->_run_dos2unix();
}

sub _dos2unix_output_filename()
{
        my ($self) = @_;
        return join('',($self->_tmp_dir, '/', 'dos2unix.fa'))
}

sub _run_dos2unix()
{
        my ($self) = @_;
        my $cmd = join(' ', ($self->dos2unix_exec, '-n', $fasta_file, $self->_dos2unix_output_filename))
        
        system($cmd);
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;
