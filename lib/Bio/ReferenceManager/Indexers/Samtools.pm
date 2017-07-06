package Bio::ReferenceManager::Indexers::Samtools;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'      => ( is => 'rw', isa => 'Str',      default => 'samtools' );
has 'software_name'   => ( is => 'rw', isa => 'Str',      default => 'samtools' );
has 'version_regex'   => ( is => 'rw', isa => 'Str',      default => 'Version: ([\d]+\.[\d]+\.[\d]+[-\w]*)' );
has 'software_suffix' => ( is => 'rw', isa => 'ArrayRef', default => sub { ['.fai'] } );

sub index_command {
    my ($self,$reference_file) = @_;
    return join( ' ', ( $self->executable, 'faidx', $reference_file ) );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
