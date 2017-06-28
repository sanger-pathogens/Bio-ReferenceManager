package Bio::ReferenceManager::Indexers;

# ABSTRACT: Take in a fasta file, fix it up, save it

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;
use Cwd qw(abs_path getcwd);
use Bio::ReferenceManager::Indexers::Bowtie2;
use Bio::ReferenceManager::Indexers::Bwa;
use Bio::ReferenceManager::Indexers::Picard;
use Bio::ReferenceManager::Indexers::RefStats;
use Bio::ReferenceManager::Indexers::Samtools;
use Bio::ReferenceManager::Indexers::Smalt;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'fasta_file' => ( is => 'rw', isa => 'Str', required => 1 );

sub create_bowtie2_index {
    my ($self) = @_;
    my $indexer = Bio::ReferenceManager::Indexers::Bowtie2->new( fasta_file => $self->fasta_file, logger => $self->logger );
    $indexer->run_indexing( getcwd() );
    $indexer->run_indexing( $indexer->versioned_directory_name() );

    # you can use a different version here by setting the executable to be a different name e.g.
    # Bio::ReferenceManager::Indexers::Bowtie2->new(fasta_file => $self->fasta_file, executable => 'bowtie2-build-1.2.3')
}

sub create_bwa_index {
    my ($self) = @_;
    my $indexer = Bio::ReferenceManager::Indexers::Bwa->new( fasta_file => $self->fasta_file, logger => $self->logger );
    $indexer->run_indexing( getcwd() );
    $indexer->run_indexing( $indexer->versioned_directory_name() );
}

sub create_picard_index {
    my ($self) = @_;
    my $indexer = Bio::ReferenceManager::Indexers::Picard->new( fasta_file => $self->fasta_file, logger => $self->logger );
    $indexer->run_indexing( getcwd() );
    $indexer->run_indexing( $indexer->versioned_directory_name() );
}

sub create_refstats_index {
    my ($self) = @_;
    my $indexer = Bio::ReferenceManager::Indexers::RefStats->new( fasta_file => $self->fasta_file, logger => $self->logger );
    $indexer->run_indexing( getcwd() );
    $indexer->run_indexing( $indexer->versioned_directory_name() );
}

sub create_samtools_index {
    my ($self) = @_;
    my $indexer = Bio::ReferenceManager::Indexers::Samtools->new( fasta_file => $self->fasta_file, logger => $self->logger );
    $indexer->run_indexing( getcwd() );
    $indexer->run_indexing( $indexer->versioned_directory_name() );
}

sub create_smalt_index {
    my ($self) = @_;
    my $indexer = Bio::ReferenceManager::Indexers::Smalt->new( fasta_file => $self->fasta_file, logger => $self->logger );
    $indexer->run_indexing( getcwd() );
    $indexer->run_indexing( $indexer->versioned_directory_name() );
}

1;
