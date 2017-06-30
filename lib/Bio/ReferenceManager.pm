package Bio::ReferenceManager;

# ABSTRACT: Main class for working with references

=head1 SYNOPSIS

Main class for working with references

=cut

use Moose;
use File::Basename;
use Parallel::ForkManager;

use Bio::ReferenceManager::Indexers;
use Bio::ReferenceManager::PrepareFasta;
use Bio::ReferenceManager::RefsIndex;
use Bio::ReferenceManager::VRTrack::Assemblies;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'fasta_files'              => ( is => 'ro', isa => 'ArrayRef[Str]', required => 1 );
has 'reference_store_dir'      => ( is => 'rw', isa => 'Str',           required => 1 );
has 'reference_metadata'       => ( is => 'rw', isa => 'Str',           default  => 'metadata.json' );
has 'production_reference_dir' => ( is => 'rw', isa => 'Str',           required => 1 );
has 'processors'               => ( is => 'rw', isa => 'Int',           default  => 1 );

# Populate from prepare_fasta_files
has 'references' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

# for PrepareFasta
has 'name_as_hash'  => ( is => 'rw', isa => 'Bool', default => 1 );
has 'dos2unix_exec' => ( is => 'rw', isa => 'Str',  default => 'dos2unix' );
has 'fastaq_exec'   => ( is => 'rw', isa => 'Str',  default => 'fastaq' );

# for Indexers
has 'overwrite_files' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'java_exec'       => ( is => 'rw', isa => 'Str',  default => 'java' );

# for RefsIndex
has 'index_filename' => ( is => 'ro', isa => 'Str', default => 'refs.index' );

sub run {
    my ($self) = @_;
    $self->logger->info("Preparing FASTA files");
    $self->prepare_fasta_files();

    $self->logger->info("Copying files to production");
    $self->copy_files_to_production();

    $self->logger->info("Indexing files");
    $self->index_files;

    $self->logger->info("Add to Refs index file");
    $self->add_to_refs_index();

    $self->logger->info("Add references to the databases");
    $self->add_to_databases();

}

sub prepare_fasta_files {
    my ($self) = @_;
my $pm = new Parallel::ForkManager( $self->processors );
    for my $fasta_file ( @{ $self->fasta_files } ) {
        $pm->start and next;    # fork here
        my $obj = Bio::ReferenceManager::PrepareFasta->new(
            fasta_file          => $fasta_file,
            name_as_hash        => $self->name_as_hash,
            reference_store_dir => $self->reference_store_dir,
            dos2unix_exec       => $self->dos2unix_exec,
            fastaq_exec         => $self->fastaq_exec,
            logger              => $self->logger,
        );
        $obj->fix_file_and_save;
        $obj->write_metadata_to_json( $self->reference_metadata );
        push( @{ $self->references }, $obj->reference );
$pm->finish;
    }
    $pm->wait_all_children;
    return $self;
}

sub copy_files_to_production {
    my ($self) = @_;
    my $pm = new Parallel::ForkManager( $self->processors );
    for my $reference ( @{ $self->references } ) {
        $pm->start and next;    # fork here
        my ( $filename, $source_directory, $suffix ) = fileparse( $reference->final_filename, qr/\.[^.]*/ );
        my $destination_directory = join( '/', ( $self->production_reference_dir, $reference->relative_directory ) );
        $reference->production_directory($destination_directory);

        my $cmd = "rsync -aq $source_directory/* $destination_directory";
        $self->logger->info("Copying files: $cmd");
        system($cmd);
        $pm->finish;
    }
    $pm->wait_all_children;
    return $self;
}

sub index_files {
    my ($self) = @_;
    my $pm = new Parallel::ForkManager( $self->processors );

    for my $reference ( @{ $self->references } ) {
        $pm->start and next;    # fork here
        my $indexer = Bio::ReferenceManager::Indexers->new(
            output_base_dir => $reference->production_directory,
            fasta_file      => $reference->production_fasta,
            overwrite_files => $self->overwrite_files,
            java_exec       => $self->java_exec,
            logger          => $self->logger,
        );
        $indexer->create_index_files;
        $pm->finish;
    }
    $pm->wait_all_children;
    return $self;
}

# Must be run sequentially, never in parallel
sub add_to_refs_index {
    my ($self) = @_;
    my $refs_index_filename = join( '/', ( $self->production_reference_dir, $self->index_filename ) );

    for my $reference ( @{ $self->references } ) {
        my $refsindex = Bio::ReferenceManager::RefsIndex->new(
            index_filename     => $refs_index_filename,
            reference_filename => $reference->production_directory,
            logger             => $self->logger,
        );
        $refsindex->add_reference_to_index;
    }
    return $self;
}

# Must be run sequentially
sub add_to_databases {
    my ($self) = @_;
    my @reference_names = map { $_->basename } @{ $self->references };

    my $dbh;

    # XXX create a database connection;
    # loop over each database
    my $assemblies = Bio::ReferenceManager::VRTrack::Assemblies->new( dbh => $dbh, references => \@reference_names );

}

#Annotate bacteria

__PACKAGE__->meta->make_immutable;
no Moose;
1;
