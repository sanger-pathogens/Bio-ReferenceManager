package Bio::ReferenceManager::PrepareFasta;

# ABSTRACT: Take in a fasta file, fix it up, save it

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;
use File::Copy;
use File::Temp;
use Cwd;
use Bio::SeqIO;
use Digest::MD5::File qw(file_md5_hex);

#Dos2unix
#Is it a valid FASTA file?
#Replace non-ACGTN- with N
#Fix sequence names (max length, name present, illegal characters)
#Sort sequences by name
#Hash the file
#Copy the file to central store, named with Hash (in directory called Hash).
#Store original filename as metadata + any other info about sample (species etc..). JSON flatfile for all references or sqlite.
#
#enumerate_names

has 'fasta_file'          => ( is => 'ro', isa => 'Str',  required => 1 );
has 'reference_store_dir' => ( is => 'rw', isa => 'Str',  required => 1 );
has 'verbose'             => ( is => 'rw', isa => 'Bool', default  => 0 );

has 'dos2unix_exec' => ( is => 'rw', isa => 'Str', default => 'dos2unix' );
has 'fastaq_exec'   => ( is => 'rw', isa => 'Str', default => 'fastaq' );

has '_tmp_dir_object' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_tmp_dir' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__tmp_dir' );

sub _build__tmp_dir {
    my ($self) = @_;
    return $self->_tmp_dir_object->dirname();
}

sub fix_file_and_save {
    my ($self) = @_;
    $self->_run_dos2unix();
    $self->is_valid_fasta($self->_dos2unix_output_filename);
    $self->_run_acgtn_only();
    $self->_run_sort_by_name();
    
    my $md5 = file_md5_hex($self->_sort_by_name_output_filename);
    copy($self->_sort_by_name_output_filename, $self->final_output_filename($md5));
}

sub _dos2unix_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'dos2unix.fa' ) );
}

sub _run_dos2unix {
    my ($self) = @_;
    my $cmd = join( ' ', ( $self->dos2unix_exec, '-n', $self->fasta_file, $self->_dos2unix_output_filename ) );

    print $cmd if ( $self->verbose );

    system($cmd);
}

sub is_valid_fasta {
    my ( $self, $filename ) = @_;
    my $seqio_obj = Bio::SeqIO->new(
        -file     => $filename,
        -format   => "fasta",
        -alphabet => 'dna'
    );
    eval {
        while ( my $seq_obj = $seqio_obj->next_seq ) {

            # do something with the sequence
            $seq_obj->seq;
        }
    };
    $@ ? return 0 : return 1;
}

sub _acgtn_only_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'acgtn_only.fa' ) );
}

sub _run_acgtn_only {
    my ($self) = @_;
    my $cmd = join( ' ', ( $self->fastaq_exec, 'acgtn_only', $self->_dos2unix_output_filename, $self->_acgtn_only_output_filename ) );

    print $cmd if ( $self->verbose );

    system($cmd);
}

sub _sort_by_name_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'sort_by_name.fa' ) );
}

sub _run_sort_by_name {
    my ($self) = @_;
    my $cmd = join( ' ', ( $self->fastaq_exec, 'sort_by_name', $self->_acgtn_only_output_filename, $self->_sort_by_name_output_filename ) );

    print $cmd if ( $self->verbose );

    system($cmd);
}

sub final_output_filename
{
    my ($self, $md5) = @_;
    return join('/',($self->reference_store_dir, $md5.'.fa'));
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
