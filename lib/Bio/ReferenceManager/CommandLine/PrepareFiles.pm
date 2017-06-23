package Bio::ReferenceManager::CommandLine::PrepareFiles;

# ABSTRACT: prepare input files

=head1 SYNOPSIS

prepare input files

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Log::Log4perl qw(:easy);
use Bio::ReferenceManager::PrepareFasta;
use Cwd qw(abs_path);
use File::Path qw(make_path);

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'input_files'  => ( is => 'rw', isa  => 'ArrayRef', default => sub { [] } );
has 'name_as_hash' => ( is => 'rw', isa  => 'Bool', default => 1 );
has 'processors'   => ( is => 'rw', isa  => 'Int', default => 1 );
has 'verbose'      => ( is => 'rw', isa  => 'Bool', default => 0 );
has 'output_directory' => ( is => 'rw', isa  => 'Str', default => 'references' );
has 'logger'       => ( is => 'ro', lazy => 1, builder => '_build_logger' );

sub _build_logger {
    my ($self) = @_;
    Log::Log4perl->easy_init($ERROR);
    my $logger = get_logger();
    return $logger;
}

sub BUILD {
    my ($self) = @_;

    my ( $dont_use_hashes, $verbose, $processors, $output_directory, $help );

    GetOptionsFromArray(
        $self->args,
        'd|dont_use_hashes=s' => \$dont_use_hashes,
        'p|processors=i'      => \$processors,
        'v|verbose'           => \$verbose,
        'o|output_directory'  => \$output_directory,
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

    for my $fasta_file ( @{ $self->input_files } ) {
        my $obj = Bio::ReferenceManager::PrepareFasta->new(
            fasta_file   => $fasta_file,
            verbose      => $self->verbose,
            name_as_hash => $self->name_as_hash,
            reference_store_dir => $self->output_directory
        );
        $obj->fix_file_and_save;
    }
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: prepare_reference_files [options]
Take in references and prepare them for adding to the reference tracking system.

Options: -d       dont use hashes for filenames [False]
         -p INT   number of processors [1]
         -v       verbose output to STDOUT
         -h       this help message

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
