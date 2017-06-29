package Bio::ReferenceManager::CommandLine::PrepareFiles;

# ABSTRACT: prepare input files

=head1 SYNOPSIS

prepare input files

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::ReferenceManager::PrepareFasta;
use Cwd qw(abs_path);
use File::Path qw(make_path);
use JSON;
use File::Slurper 'write_text';
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose'      => ( is => 'rw', isa  => 'Bool', default => 0 );
has 'input_files'  => ( is => 'rw', isa  => 'ArrayRef', default => sub { [] } );
has 'name_as_hash' => ( is => 'rw', isa  => 'Bool', default => 1 );
has 'processors'   => ( is => 'rw', isa  => 'Int', default => 1 );
has 'references_metadata'   => ( is => 'rw', isa  => 'Str', default => 'references_metadata' );
has 'output_directory' => ( is => 'rw', isa  => 'Str', default => 'references' );


sub BUILD {
    my ($self) = @_;

    my ( $dont_use_hashes, $verbose, $processors, $output_directory,$references_metadata, $help );

    GetOptionsFromArray(
        $self->args,
        'd|dont_use_hashes' => \$dont_use_hashes,
        'r|references_metadata=s' => \$references_metadata,
        'p|processors=i'      => \$processors,
        'v|verbose'           => \$verbose,
        'o|output_directory=s'  => \$output_directory,
        'h|help'              => \$help,
    );

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }

    $self->help($help)                       if ( defined($help) );
    $self->name_as_hash(0) if ( defined($dont_use_hashes) );
    $self->processors($processors)           if ( defined($processors) );
    $self->output_directory($output_directory) if(defined($output_directory));
    $self->references_metadata($references_metadata) if(defined($references_metadata));

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
    
    
    if ( ! -d $self->output_directory ) {

        make_path( $self->output_directory, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $file, $message ) = %$diag;
                die("Error creating output directory $message");
            }
        }
    }

    my @references;
    my @references_hash;
    for my $fasta_file ( @{ $self->input_files } ) {
        my $obj = Bio::ReferenceManager::PrepareFasta->new(
            fasta_file   => $fasta_file,
            verbose      => $self->verbose,
            name_as_hash => $self->name_as_hash,
            reference_store_dir => $self->output_directory,
            logger => $self->logger,
        );
        $obj->fix_file_and_save;
        push(@references, $obj->reference);
        push(@references_hash, $obj->reference->to_hash);
    }
    write_text($self->references_metadata, to_json \@references_hash);
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: refman_prepare_reference_files [options]
Take in references and prepare them for adding to the reference tracking system.

Options: -d       dont use hashes for filenames [False]
         -r STR   File to store reference metadata [references_metadata]
         -p INT   number of processors [1]
         -o STR   output directory [references]
         -v       verbose output to STDOUT
         -h       this help message

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
