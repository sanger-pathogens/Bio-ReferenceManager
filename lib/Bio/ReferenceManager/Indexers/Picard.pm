package Bio::ReferenceManager::Indexers::Picard;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'java net.sf.picard.sam.CreateSequenceDictionary' );
has 'version_regex'       => ( is => 'rw', isa => 'Str', default => '[\d]+\.[\d]+' );
has 'version_parameter'   => ( is => 'rw', isa => 'Str', default => '--version' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
