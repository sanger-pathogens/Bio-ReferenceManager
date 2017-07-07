package Bio::ReferenceManager::Reference;

# ABSTRACT: Represents a reference and metadata

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;

has 'final_filename'    => ( is => 'rw', isa => 'Maybe[Str]' );
has 'original_filename' => ( is => 'rw', isa => 'Maybe[Str]' );
has 'sequence_length'   => ( is => 'rw', isa => 'Maybe[Int]' );
has 'md5'               => ( is => 'rw', isa => 'Maybe[Str]' );
has 'basename'          => ( is => 'rw', isa => 'Maybe[Str]' );
has 'relative_directory'=> ( is => 'rw', isa => 'Maybe[Str]' );
has 'production_directory'=> ( is => 'rw', isa => 'Maybe[Str]' );

sub production_fasta
{
    my ($self) = @_;
    return join('/',($self->production_directory,$self->basename.'.fa')),
}

sub genus
{
    my ($self) = @_;
    my @name_parts = split('_', $self->basename);
    return $name_parts[0];
}

sub to_hash {
    my ($self) = @_;
    my %reference_metadata = (
        final_filename     => $self->final_filename,
        original_filename  => $self->original_filename,
        sequence_length    => $self->sequence_length,
        md5                => $self->md5,
        basename           => $self->basename,
        relative_directory => $self->relative_directory,
        production_directory => $self->production_directory
        );
    return \%reference_metadata;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
