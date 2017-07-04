package Bio::ReferenceManager::NCBI::AssemblyMetadata;

# ABSTRACT: Download and parse the NCBI Refseq assembly metadata table

=head1 SYNOPSIS

 Find some missing data

=cut

use Moose;
use File::Temp;
use Cwd;
use Bio::ReferenceManager::NCBI::RefSeqAssembly;

has 'url' => ( is => 'rw', isa => 'Str', default => 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt' );
has 'downloaded_filename' => ( is => 'rw', isa => 'Str', default => 'assembly_summary.txt' );
has 'output_directory'    => ( is => 'rw', isa => 'Str', default => 'downloaded_assemblies' );

has '_working_directory' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );

has 'assembly_summary_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_assembly_summary_filename' );

sub download_all_complete_genomes {
    my ($self) = @_;
    $self->download_assembly_summary;
    my $refseq_assemblies = $self->extract_complete_genomes;

    for my $assembly ( @{$refseq_assemblies} ) {
        $self->download_assembly($assembly);
    }
    return $self;
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
        if ( $elements[11] eq "Complete Genome" && $elements[10] eq "latest" ) {
            my $a = Bio::ReferenceManager::NCBI::RefSeqAssembly->new(
                species       => $elements[7],
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
    system( "mv $downloaded_filename $output_filename");
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
