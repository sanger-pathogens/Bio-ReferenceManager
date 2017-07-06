package Bio::ReferenceManager::CommandLine::IndexReferences;

# ABSTRACT: index references

=head1 SYNOPSIS

index references

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Cwd qw(abs_path);
use File::Path qw(make_path);
use Parallel::ForkManager;
use Bio::ReferenceManager::Indexers;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose'     => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'input_files' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'output_directory' => ( is => 'rw', isa => 'Str',  default => 'references' );
has 'processors'       => ( is => 'rw', isa => 'Int',  default => 1 );
has 'overwrite_files'  => ( is => 'rw', isa => 'Bool', default => 0 );
has 'java_exec'        => ( is => 'rw', isa => 'Str',  default => 'java' );

sub BUILD {
    my ($self) = @_;

    my ( $verbose, $processors, $output_directory, $overwrite_files, $java_exec, $help );

    GetOptionsFromArray(
        $self->args,
        'f|overwrite_files'    => \$overwrite_files,
        'j|java_exec=s'        => \$java_exec,
        'p|processors=i'       => \$processors,
        'v|verbose'            => \$verbose,
        'o|output_directory=s' => \$output_directory,
        'h|help'               => \$help,
    );

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }

    $self->help($help)                         if ( defined($help) );
    $self->overwrite_files($overwrite_files)   if ( defined($overwrite_files) );
    $self->processors($processors)             if ( defined($processors) );
    $self->output_directory($output_directory) if ( defined($output_directory) );
    $self->java_exec($java_exec)               if ( defined($java_exec) );

    $self->output_directory(abs_path($self->output_directory));

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

    if ( !-d $self->output_directory ) {

        make_path( $self->output_directory, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $file, $message ) = %$diag;
                die("Error creating output directory $message");
            }
        }
    }

    # parallelise - nothing is fed back from the subprocesses.
    my $pm = new Parallel::ForkManager($self->processors);
    for my $fasta_file ( @{ $self->input_files } ) {
        $pm->start and next; # fork here
        my $indexers = Bio::ReferenceManager::Indexers->new(
            fasta_file      => $fasta_file,
            overwrite_files => $self->overwrite_files,
            java_exec       => $self->java_exec,
            output_base_dir => $self->output_directory,
            logger          => $self->logger
        );
        $indexers->create_index_files();
        $pm->finish;
    }
    $pm->wait_all_children;

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: refman_index_references [options]
Take in references and index them with various applications.

Options: -f       overwrite index files [False]
         -j STR   java executable [java]
         -p INT   number of processors [1]
         -o STR   output directory [references]
         -v       verbose output to STDOUT
         -h       this help message

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
