package Bio::ReferenceManager::Indexers::Common;
# ABSTRACT: Common indexers

=head1 SYNOPSIS

 Common indexers
 
=cut

use Moose;

has 'version_parameter'   => ( is => 'rw', isa => 'Maybe[Str]' );
has 'executable'          => ( is => 'rw', isa => 'Str' );
has 'version_regex'       => ( is => 'rw', isa => 'Maybe[Str]' );

no Moose;
1;
