package Bio::ReferenceManager::NCBI::RefSeqAssembly;

# ABSTRACT: represents the metadata for a refseq assembly

=head1 SYNOPSIS

represents the metadata for a refseq assembly

=cut

use Moose;

has 'species'       => ( is => 'rw', isa => 'Str',        required => 1 );
has 'strain'        => ( is => 'rw', isa => 'Maybe[Str]', default  => '' );
has 'accession'     => ( is => 'rw', isa => 'Str',        required => 1 );
has 'ftp_directory' => ( is => 'rw', isa => 'Str',        required => 1 );
has 'suffix'        => ( is => 'rw', isa => 'Str',        default  => '_genomic.fna.gz' );

sub download_url {
    my ($self) = @_;
    my @ftp_path = split( '/', $self->ftp_directory );
    return $self->ftp_directory . '/' . $self->downloaded_filename;
}

sub downloaded_filename {
    my ($self) = @_;
    my @ftp_path = split( '/', $self->ftp_directory );
    return $ftp_path[9] . $self->suffix;
}

sub normalised_species_name {
    my ($self) = @_;

    my $strain = $self->strain || '';
    my $species_name = join( '_', ( $self->species, $strain, $self->accession ) );

    # get rid of non word characters
    $species_name =~ s!\W!_!gi;

    # We dont want lots of underscores so collapse to 1
    $species_name =~ s!_[_]+!_!g;

    return $species_name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
