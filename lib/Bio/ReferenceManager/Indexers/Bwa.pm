package Bio::ReferenceManager::Indexers::Bwa;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'bwa' );
has 'software_name'       => ( is => 'rw', isa => 'Str', default => 'bwa' );
has 'version_regex'       => ( is => 'rw', isa => 'Str', default => 'Version: ([\d]+\.[\d]+\.[\d]+[-\w]*)' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;