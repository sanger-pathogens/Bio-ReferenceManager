package Bio::ReferenceManager::Indexers::RefStats;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'ref-stats' );
has 'software_name'       => ( is => 'rw', isa => 'Str', default => 'ref-stats' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
