package Bio::ReferenceManager::Indexers::Picard;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'        => ( is => 'rw', isa => 'Str',      default => 'java net.sf.picard.sam.CreateSequenceDictionary' );
has 'version_regex'     => ( is => 'rw', isa => 'Str',      default => '([\d]+\.[\d]+)' );
has 'version_parameter' => ( is => 'rw', isa => 'Str',      default => '--version' );
has 'software_name'     => ( is => 'rw', isa => 'Str',      default => 'picard' );
has 'software_suffix'   => ( is => 'rw', isa => 'ArrayRef', default => sub { ['.dict'] } );

sub index_command {
    my ($self) = @_;
    return join( ' ', ( $self->executable, 'R=' . $self->fasta_file, 'O=' . $self->fasta_file . '.dict' ) );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
