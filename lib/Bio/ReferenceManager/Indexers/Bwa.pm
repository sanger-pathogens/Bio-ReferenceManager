package Bio::ReferenceManager::Indexers::Bwa;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'bwa' );
has 'version_regex'       => ( is => 'rw', isa => 'Version: ([\d]+\.[\d]+\.[\d]+[-\w]*)' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;