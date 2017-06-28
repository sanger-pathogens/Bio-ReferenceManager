package Bio::ReferenceManager::Indexers;

# ABSTRACT: Take in a fasta file, fix it up, save it

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;
use Cwd qw(abs_path getcwd);
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'fasta_file'      => ( is => 'rw', isa => 'Str',  required => 1 );
has 'overwrite_files' => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'java_exec'       => ( is => 'rw', isa => 'Str', default  => 'java' );

has 'indexing_executables' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {
        [
            { class => 'Bowtie2' },
            {
                class                  => 'Bwa',
                additional_executables => [ 'bwa-0.7.10', 'bwa-0.7.5a' ]
            },
            { class => 'Picard' },
            { class => 'RefStats' },
            {
                class                  => 'Samtools',
                additional_executables => ['samtools-1.3']
            },
            { class => 'Smalt' }
        ];
    }
);

# Create index files for the default versions (listed in the classes)
# and for additional versions.
sub create_index_files {
    my ($self) = @_;
    for my $index_software ( @{ $self->indexing_executables } ) {
        my $index_class = "Bio::ReferenceManager::Indexers::" . $index_software->{class};
        eval "require $index_class";

        # default settings
        $self->logger->info( "Creating index files for " . $index_software->{class} );
        my $indexer = $index_class->new(
            fasta_file      => $self->fasta_file,
            logger          => $self->logger,
            overwrite_files => $self->overwrite_files,
            java_exec       => $self->java_exec,
        );
        $indexer->run_indexing( $indexer->base_directory );
        $indexer->run_indexing( $indexer->versioned_directory_name() );

        # create index files in subdirs for other versons of the same software
        if ( defined( $index_software->{additional_executables} ) ) {
            for my $executable ( @{ $index_software->{additional_executables} } ) {
                $self->logger->info( "Creating index files for " . $executable );
                $indexer = $index_class->new(
                    fasta_file      => $self->fasta_file,
                    logger          => $self->logger,
                    overwrite_files => $self->overwrite_files,
                    executable      => $executable,
                    java_exec       => $self->java_exec
                );
                $indexer->run_indexing( $indexer->versioned_directory_name() );
            }
        }
    }
    return $self;
}

1;