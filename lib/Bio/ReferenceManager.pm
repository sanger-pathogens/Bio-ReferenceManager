package Bio::ReferenceManager;

# ABSTRACT: Main class for working with references

=head1 SYNOPSIS

Main class for working with references

=cut

use Moose;
use File::Basename;
use Parallel::ForkManager;
use File::Path qw(make_path);
use Cwd qw(abs_path getcwd);

use Bio::ReferenceManager::Indexers;
use Bio::ReferenceManager::PrepareFasta;
use Bio::ReferenceManager::RefsIndex;
use Bio::ReferenceManager::VRTrack::Assemblies;
use Bio::ReferenceManager::VRTrack::DatabaseManager;
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

# for databases
has 'driver' => ( is => 'ro', isa => 'Str', default => 'mysql' );
has 'dbh' => ( is => 'ro', isa => 'Maybe[Bio::ReferenceManager::VRTrack::Schema]', required => 0 );

has 'annotate'           => ( is => 'rw', isa => 'Bool', default => 1 );
has 'annotate_memory_gb' => ( is => 'rw', isa => 'Num',  default => 5 );

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

    if ( $self->annotate ) {
        $self->logger->info("Annotating genomes with Prokka");
        $self->annotate_genomes();
    }

    return $self;
}

sub prepare_fasta_files {
    my ($self) = @_;

    for my $fasta_file ( @{ $self->fasta_files } ) {
        my $obj = Bio::ReferenceManager::PrepareFasta->new(
            fasta_file          => $fasta_file,
            name_as_hash        => $self->name_as_hash,
            reference_store_dir => $self->reference_store_dir,
            dos2unix_exec       => $self->dos2unix_exec,
            fastaq_exec         => $self->fastaq_exec,
            logger              => $self->logger,
            overwrite_files     => $self->overwrite_files,
        );
        $obj->fix_file_and_save;
        $obj->write_metadata_to_json( $self->reference_metadata );
        push( @{ $self->references }, $obj->reference );

    }
    return $self;
}

sub copy_files_to_production {
    my ($self) = @_;

    my $pm = new Parallel::ForkManager( $self->processors );
    for my $reference ( @{ $self->references } ) {
        my ( $filename, $source_directory, $suffix ) = fileparse( $reference->final_filename, qr/\.[^.]*/ );
        my $destination_directory = join( '/', ( $self->production_reference_dir, $reference->relative_directory ) );
        make_path($destination_directory);
        $reference->production_directory($destination_directory);

        ###### BEGIN Parallel #######
        $pm->start and next;    # fork here
        my $cmd = "rsync -aq $source_directory/* $destination_directory";
        $self->logger->info("Copying files: $cmd");
        system($cmd);
        $pm->finish;
        ###### END Parallel #######
    }
    $pm->wait_all_children;
    return $self;
}

sub index_files {
    my ($self) = @_;
    my $pm = new Parallel::ForkManager( $self->processors );

    for my $reference ( @{ $self->references } ) {
        my $output_base_dir = $reference->production_directory;
        my $fasta_file      = $reference->production_fasta;

        ###### BEGIN Parallel #######
        $pm->start and next;    # fork here
        my $indexer = Bio::ReferenceManager::Indexers->new(
            output_base_dir => $output_base_dir,
            fasta_file      => $fasta_file,
            overwrite_files => $self->overwrite_files,
            java_exec       => $self->java_exec,
            logger          => $self->logger,
        );
        $indexer->create_index_files;
        $pm->finish;
        ###### END Parallel #######
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
            reference_filename => $reference->production_fasta,
            logger             => $self->logger,
        );
        $refsindex->add_reference_to_index;
    }
    return $self;
}

# Must be run sequentially
sub add_to_databases {
    my ($self) = @_;

    my $dbh;
    my $dm = Bio::ReferenceManager::VRTrack::DatabaseManager->new(
        driver => $self->driver,
        logger => $self->logger
    );

    my $assemblies;
    if ( defined( $self->dbh ) ) {
        $assemblies = Bio::ReferenceManager::VRTrack::Assemblies->new(
            dbh        => $self->dbh,
            references => $self->references,
            logger     => $self->logger
        );
        $assemblies->insert_references_into_assembly_table;
    }
    else {
        for my $data_source ( @{ $dm->data_sources } ) {
            $dbh = $dm->connect_to_database($data_source);

            $assemblies = Bio::ReferenceManager::VRTrack::Assemblies->new(
                dbh        => $dbh,
                references => $self->references,
                logger     => $self->logger
            );
            $assemblies->insert_references_into_assembly_table;
        }
    }
    return $self;
}

# Todo: move to a separate class
# Annotate bacteria
sub annotate_genomes {
    my ($self) = @_;
    for my $reference ( @{ $self->references } ) {

        # run annotation from reference directory
        my $original_directory = getcwd();
        chdir( abs_path( $reference->production_directory ) );

        my $annotation_cmd = join(
            ' ',
            (
                'bsub.py',                         $self->annotate_memory_gb,
                $reference->basename . '_log',     'annotate_bacteria',
                '-a',                              $reference->production_fasta,
                '-o',                              $reference->production_directory . '/annotation',
                '--sample_name',                   $reference->basename,
                '--keep_original_order_and_names', '--genus',
                $reference->genus
            )
        );
        $self->logger->info( "Annotation command: " . $annotation_cmd );
        system($annotation_cmd);

        # Change back to the original working directory
        chdir($original_directory);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
