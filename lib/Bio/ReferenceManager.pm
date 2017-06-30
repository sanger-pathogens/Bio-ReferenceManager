package Bio::ReferenceManager;

# ABSTRACT: Main class for working with references

=head1 SYNOPSIS

Main class for working with references

=cut

use Moose;
use Bio::ReferenceManager::Indexers;
use Bio::ReferenceManager::PrepareFasta;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';


has 'fasta_files'          => ( is => 'ro', isa => 'Str',  required => 1 );
has 'reference_store_dir'  => ( is => 'rw', isa => 'Str',  required => 1 );
has 'reference_metadata'   => ( is => 'rw', isa => 'Str',  default => 'metadata.json' );
has 'production_reference_dir' => ( is => 'rw', isa => 'Str',  required => 1 );

# Populate from prepare_fasta_files
has 'references' => ( is => 'rw', isa => 'ArrayRef',  default => sub{[]} );

# for PrepareFasta
has 'name_as_hash'        => ( is => 'rw', isa => 'Bool', default  => 1 );
has 'dos2unix_exec' => ( is => 'rw', isa => 'Str', default => 'dos2unix' );
has 'fastaq_exec'   => ( is => 'rw', isa => 'Str', default => 'fastaq' );

sub run
{
     my ($self) = @_;
     $self->prepare_fasta_files();
     
}

sub prepare_fasta_files
{
    my ($self) = @_;

    for my $fasta_file ( @{ $self->fasta_files } ) {
        my $obj = Bio::ReferenceManager::PrepareFasta->new(
            fasta_file   => $fasta_file,
            name_as_hash => $self->name_as_hash,
            reference_store_dir => $self->reference_store_dir,
            dos2unix_exec => $self->dos2unix_exec,
            fastaq_exec => $self->fastaq_exec,
            logger => $self->logger,
        );
        $obj->fix_file_and_save;
        push(@{$self->references}, $obj->reference);
        write_text($self->references_metadata, to_json $obj->reference->to_hash);
    }
    return $self;
}

#
#
#
#Format the files and deposit in long term archive (nfs) - save metadata to each directory
#Copy the files to the working directory (lustre)
#Index the files
#Add to refs.index
#Add to all databases
#Annotate bacteria



__PACKAGE__->meta->make_immutable;
no Moose;
1;
