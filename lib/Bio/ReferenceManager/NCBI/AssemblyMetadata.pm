package Bio::ReferenceManager::NCBI::AssemblyMetadata;

# ABSTRACT: Download and parse the NCBI Refseq assembly metadata table

=head1 SYNOPSIS

 Find some missing data

=cut

use Moose;
use File::Temp;
use Cwd;
use Bio::ReferenceManager::NCBI::RefSeqAssembly;
use Bio::ReferenceManager::RefsIndex;

has 'url' => ( is => 'rw', isa => 'Str', default => 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt' );
has 'downloaded_filename'            => ( is => 'rw', isa => 'Str',  default => 'assembly_summary.txt' );
has 'output_directory'               => ( is => 'rw', isa => 'Str',  default => 'downloaded_assemblies' );
has 'download_only_new'              => ( is => 'rw', isa => 'Bool', default => 1 );
has 'dont_redownload_assembly_stats' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'index_filename'                 => ( is => 'ro', isa => 'Str',  default => 'refs.index' );

has '_working_directory' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );

has 'assembly_summary_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_assembly_summary_filename' );

sub download_genomes {
    my ($self) = @_;
    if ( $self->download_only_new ) {
        $self->download_only_new_complete_genomes;
    }
    else {
        $self->download_all_complete_genomes;
    }
    return $self;
}

sub download_all_complete_genomes {
    my ($self) = @_;
    unless ( $self->dont_redownload_assembly_stats && ( -e $self->assembly_summary_filename ) ) {
        $self->download_assembly_summary;
    }
    my $refseq_assemblies = $self->extract_complete_genomes;

    for my $assembly ( @{$refseq_assemblies} ) {
        $self->download_assembly($assembly);
    }
    return $self;
}

sub download_only_new_complete_genomes {
    my ($self) = @_;

    for my $assembly ( @{ $self->new_genomes } ) {
        $self->download_assembly($assembly);
    }
    return $self;
}

sub new_genomes {
    my ($self) = @_;
    my @genomes_not_in_refs_index;

    my $refs_index = Bio::ReferenceManager::RefsIndex->new( index_filename => $self->index_filename );
    my $reference_names_to_files = $refs_index->reference_names_to_files;

    unless ( $self->dont_redownload_assembly_stats && ( -e $self->assembly_summary_filename ) ) {
        $self->download_assembly_summary;
    }

    my $refseq_assemblies = $self->extract_complete_genomes;

    for my $assembly ( @{$refseq_assemblies} ) {
        if ( !defined( $reference_names_to_files->{ $assembly->normalised_species_name } ) ) {
            push( @genomes_not_in_refs_index, $assembly );
        }
    }
    return \@genomes_not_in_refs_index;

}

sub _build__working_directory_name {
    my ($self) = @_;
    return $self->_working_directory->dirname();
}

sub _build_assembly_summary_filename {
    my ($self) = @_;
    return $self->_working_directory_name . "/" . $self->downloaded_filename();
}

sub download_assembly_summary {
    my ($self) = @_;
    system( "wget -O " . $self->assembly_summary_filename . " " . $self->url() . " > /dev/null 2>&1" );
    return $self;
}

sub extract_complete_genomes {
    my ($self) = @_;
    my @refseqassemblies;
    open( my $fh_in, $self->assembly_summary_filename ) or die 'Couldnt open ' . $self->assembly_summary_filename;

    while (<$fh_in>) {
        chomp();
        my $line = $_;
        my @elements = split( /\t/, $line );
        next if(@elements < 19);
        if ( $elements[11] eq "Complete Genome" && $elements[10] eq "latest" ) {
            my $a = Bio::ReferenceManager::NCBI::RefSeqAssembly->new(
                species       => $elements[7],
                strain        => $elements[8],
                accession     => $elements[0],
                ftp_directory => $elements[19]
            );
            push( @refseqassemblies, $a );
        }
    }
    return \@refseqassemblies;
}

sub download_assembly {
    my ( $self, $refseq_assembly ) = @_;

    my $downloaded_filename = $self->_working_directory_name . '/' . $refseq_assembly->downloaded_filename;
    my $output_filename     = $self->output_directory . '/' . $refseq_assembly->normalised_species_name . '.fa';

    system( "wget -O " . $downloaded_filename . " " . $refseq_assembly->download_url . " > /dev/null 2>&1" );
    system( "gunzip " . $downloaded_filename );
    system("mv $downloaded_filename $output_filename");
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
