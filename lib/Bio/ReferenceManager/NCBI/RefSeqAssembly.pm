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

sub remove_non_word_chars
{
     my ($self, $original) = @_;
     # get rid of non word characters
     $original =~ s!\W!_!gi;

     # We dont want lots of underscores so collapse to 1
     $original =~ s!_[_]+!_!g;
     return $original;
}

sub normalised_species_name {
    my ($self) = @_;

    my $strain = $self->strain || '';
    $strain =~ s!strain=!!gi;
    $strain = $self->remove_non_word_chars($strain);
    
    my $species = $self->remove_non_word_chars($self->species());
    my $accession = $self->remove_non_word_chars($self->accession);

    my $species_name = $accession;
    # If strain name is already in species, no need to repeat it
    if($species =~ m/$strain/)
    {
        $species_name = join( '_', ( $species, $accession ) );
    }
    else
    {
        $species_name = join( '_', ( $species, $strain, $accession ) );
    }

    # get rid of double underscore
    $species_name = $self->remove_non_word_chars($species_name);


    return $species_name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
