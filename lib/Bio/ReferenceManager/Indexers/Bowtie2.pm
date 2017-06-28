package Bio::ReferenceManager::Indexers::Bowtie2;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'bowtie2-build' );
has 'software_name'       => ( is => 'rw', isa => 'Str', default => 'bowtie2' );
has 'version_regex'       => ( is => 'rw', isa => 'Str', default => 'bowtie2-build version ([\d]+\.[\d]+\.[\d]+)' );
has 'version_parameter'   => ( is => 'rw', isa => 'Str', default => '--version' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;

