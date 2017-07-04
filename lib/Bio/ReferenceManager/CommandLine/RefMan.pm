package Bio::ReferenceManager::CommandLine::RefMan;

# ABSTRACT: index references

=head1 SYNOPSIS

index references

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Cwd qw(abs_path);
use File::Path qw(make_path);
use Bio::ReferenceManager;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose'     => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'input_files'  => ( is => 'rw', isa  => 'ArrayRef', default => sub { [] } );
has 'reference_store_dir'      => ( is => 'rw', isa => 'Str',           default  => '/nfs/pathogen/refs' );
has 'reference_metadata'       => ( is => 'rw', isa => 'Str',           default  => 'metadata.json' );
has 'production_reference_dir' => ( is => 'rw', isa => 'Str',           default  => '/lustre/scratch118/infgen/pathogen/pathpipe/refs' );
has 'processors'               => ( is => 'rw', isa => 'Int',           default  => 1 );

# for PrepareFasta
has 'name_as_hash'  => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dos2unix_exec' => ( is => 'rw', isa => 'Str',  default => 'dos2unix' );
has 'fastaq_exec'   => ( is => 'rw', isa => 'Str',  default => 'fastaq' );

# for Indexers
has 'overwrite_files' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'java_exec'       => ( is => 'rw', isa => 'Str',  default => 'java' );

# for RefsIndex
has 'index_filename' => ( is => 'rw', isa => 'Str', default => 'refs.index' );

sub BUILD {
    my ($self) = @_;

    my (
        $verbose,         $reference_store_dir, $reference_metadata, $production_reference_dir,
        $processors,      $name_as_hash,        $dos2unix_exec,      $fastaq_exec,
        $overwrite_files, $java_exec,           $index_filename,     $help
    );

    GetOptionsFromArray(
        $self->args,
        'v|verbose'              => \$verbose,
        'r|ref_dir=s'            => \$reference_store_dir,
        'm|ref_metadata=s'       => \$reference_metadata,
        'd|production_ref_dir=s' => \$production_reference_dir,
        'p|processors=i'         => \$processors,
        'n|name_as_hash'         => \$name_as_hash,
        'dos2unix_exec=s'        => \$dos2unix_exec,
        'fastaq_exec=s'          => \$fastaq_exec,
        'o|overwrite_files'      => \$overwrite_files,
        'java_exec=s'            => \$java_exec,
        'i|index_filename=s'     => \$index_filename,
        'h|help'                 => \$help,
    );

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }

    $self->verbose($verbose)                                   if ( defined($verbose) );
    $self->reference_store_dir($reference_store_dir)           if ( defined($reference_store_dir) );
    $self->reference_metadata($reference_metadata)             if ( defined($reference_metadata) );
    $self->production_reference_dir($production_reference_dir) if ( defined($production_reference_dir) );
    $self->processors($processors)                             if ( defined($processors) );
    $self->name_as_hash($name_as_hash)                         if ( defined($name_as_hash) );
    $self->dos2unix_exec($dos2unix_exec)                       if ( defined($dos2unix_exec) );
    $self->fastaq_exec($fastaq_exec)                           if ( defined($fastaq_exec) );
    $self->overwrite_files($overwrite_files)                   if ( defined($overwrite_files) );
    $self->java_exec($java_exec)                               if ( defined($java_exec) );
    $self->index_filename($index_filename)                     if ( defined($index_filename) );
    $self->help($help)                                         if ( defined($help) );

    if ( @{ $self->args } < 1 ) {
        $self->logger->error("Error: You need to provide at least 1 file");
        die $self->usage_text;
    }

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->logger->error("Error: Cant access file $filename");
            die $self->usage_text;
        }
        push( @{ $self->input_files }, abs_path($filename) );
    }

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;

    my $obj = Bio::ReferenceManager->new(
        fasta_files              => $self->input_files,
        reference_store_dir      => $self->reference_store_dir,
        reference_metadata       => $self->reference_metadata,
        production_reference_dir => $self->production_reference_dir,
        processors               => $self->processors,
        name_as_hash             => $self->name_as_hash,
        dos2unix_exec            => $self->dos2unix_exec,
        fastaq_exec              => $self->fastaq_exec,
        overwrite_files          => $self->overwrite_files,
        java_exec                => $self->java_exec,
        index_filename           => $self->index_filename,
        logger                   => $self->logger,
    );
    $obj->run;

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: refman [options] *.fa
Add references to the pipelines.

Options: -o       overwrite index files [False]
         -p INT   number of processors [1]
         -r STR   reference store directory [/nfs/pathogen/refs]
         -d STR   production references direcotry [/lustre/scratch118/.../refs]
         -m STR   reference metadata filename [metadata.json]
         -n       use a hash of the file as the reference name [FALSE]
         -i STR   toplevel index filename [refs.index]
         -v       verbose output to STDOUT
         -h       this help message
         
Advanced options:
         --java_exec     STR  java executable [java]
         --dos2unix_exec STR  dos2unix executable [dos2unix]
         --fastaq_exec   STR  fastaq executable [fastaq]

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
