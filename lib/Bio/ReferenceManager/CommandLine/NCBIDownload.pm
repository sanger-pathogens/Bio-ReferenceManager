package Bio::ReferenceManager::CommandLine::NCBIDownload;

# ABSTRACT: download references from NCBI

=head1 SYNOPSIS

download references from NCBI

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Cwd qw(abs_path);
use File::Path qw(make_path);
use Bio::ReferenceManager::NCBI::AssemblyMetadata;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose'     => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'url' => ( is => 'rw', isa => 'Str', default => 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt' );
has 'downloaded_filename'            => ( is => 'rw', isa => 'Str',  default => 'assembly_summary.txt' );
has 'output_directory'               => ( is => 'rw', isa => 'Str',  default => 'downloaded_assemblies' );
has 'download_only_new'              => ( is => 'rw', isa => 'Bool', default => 1 );
has 'dont_redownload_assembly_stats' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'index_filename'  => ( is => 'rw', isa => 'Str', default => '/lustre/scratch118/infgen/pathogen/pathpipe/refs/refs.index' );
has 'assembly_type'   => ( is => 'rw', isa => 'Str', default => "Complete Genome" );
has 'assembly_latest' => ( is => 'rw', isa => 'Str', default => "latest" );

sub BUILD {
    my ($self) = @_;

    my (
        $url,              $downloaded_filename, $download_everything, $dont_redownload_assembly_stats,
        $index_filename,   $verbose,             $assembly_type,       $assembly_latest,
        $output_directory, $overwrite_files,     $java_exec,           $help
    );

    GetOptionsFromArray(
        $self->args,
        'u|url=s'                        => \$url,
        'downloaded_filename=s'          => \$downloaded_filename,
        'e|download_everything'          => \$download_everything,
        'dont_redownload_assembly_stats' => \$dont_redownload_assembly_stats,
        'i|index_filename=s'             => \$index_filename,
        'assembly_type=s'                => \$assembly_type,
        'assembly_latest=s'              => \$assembly_latest,
        'v|verbose'                      => \$verbose,
        'o|output_directory=s'           => \$output_directory,
        'h|help'                         => \$help,
    );

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }

    $self->url($url)                                                       if ( defined($url) );
    $self->downloaded_filename($downloaded_filename)                       if ( defined($downloaded_filename) );
    $self->download_only_new(0)                                            if ( defined($download_everything) );
    $self->dont_redownload_assembly_stats($dont_redownload_assembly_stats) if ( defined($dont_redownload_assembly_stats) );
    $self->index_filename($index_filename)                                 if ( defined($index_filename) );
    $self->assembly_type($assembly_type)                                   if ( defined($assembly_type) );
    $self->assembly_latest($assembly_latest)                               if ( defined($assembly_latest) );
    $self->help($help)                                                     if ( defined($help) );
    $self->output_directory( abs_path( $self->output_directory ) )         if ( defined($output_directory) );

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

    my $obj = Bio::ReferenceManager::NCBI::AssemblyMetadata->new(
        url                            => $self->url,
        downloaded_filename            => $self->downloaded_filename,
        output_directory               => $self->output_directory,
        download_only_new              => $self->download_only_new,
        dont_redownload_assembly_stats => $self->dont_redownload_assembly_stats,
        index_filename                 => $self->index_filename,
        assembly_type                  => $self->assembly_type,
        assembly_latest                => $self->assembly_latest,
        logger                         => $self->logger,
    );
    $obj->download_genomes;

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: refman_ncbi_download [options]
By default it will download all new complete genomes from RefSeq

Options: 
  -u STR NCBI assembly stats table [ftp://ftp.ncbi.nlm.nih.gov/.../assembly_summary.txt]
  -i STR Top level refs index filename [/lustre/scratch118/.../refs.index]
  -e     Download all genomes, not just new ones [FALSE]
  -o STR output directory [downloaded_assemblies]
  -v     verbose output to STDOUT
  -h     this help message

Advanced options:
  --downloaded_filename            STR What we call the downloaded assembly stats file [assembly_summary.txt]
  --dont_redownload_assembly_stats STR Provide an assembly summary file locally [FALSE]
  --assembly_type                  STR string to filter assembly_summary by [Complete Genome]
         
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
