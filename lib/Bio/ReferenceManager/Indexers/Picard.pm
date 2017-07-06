package Bio::ReferenceManager::Indexers::Picard;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'        => ( is => 'rw', isa => 'Str',      default => ' net.sf.picard.sam.CreateSequenceDictionary' );
has 'version_regex'     => ( is => 'rw', isa => 'Str',      default => '([\d]+\.[\d]+)' );
has 'version_parameter' => ( is => 'rw', isa => 'Str',      default => '--version' );
has 'software_name'     => ( is => 'rw', isa => 'Str',      default => 'picard' );
has 'software_suffix'   => ( is => 'rw', isa => 'ArrayRef', default => sub { ['.dict'] } );

sub index_command {
    my ($self,$reference_file) = @_;
    return join( ' ', ( $self->java_exec, $self->executable, 'R=' . $reference_file, 'O=' . $reference_file . '.dict' ) );
}

sub _get_version_command {
    my ($self) = @_;
    return join( ' ', ( $self->java_exec, $self->executable, $self->version_parameter, '2>&1' ) );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
