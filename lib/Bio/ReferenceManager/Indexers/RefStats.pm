package Bio::ReferenceManager::Indexers::RefStats;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'ref-stats' );
has 'software_name'       => ( is => 'rw', isa => 'Str', default => 'ref-stats' );
has 'software_suffix'     => ( is => 'rw', isa => 'ArrayRef', default => sub {['.refstats']} );

sub index_command
{
    my ($self) = @_;
    return join(' ',($self->executable, '-r', $self->fasta_file, '>', $self->fasta_file.'.refstats'));
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
