package Bio::ReferenceManager::Indexers::Refseq;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'refseq' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
