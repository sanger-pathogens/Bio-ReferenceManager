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
has 'software_name'       => ( is => 'rw', isa => 'Str', default =>  'picard');


no Moose;
__PACKAGE__->meta->make_immutable;

1;
