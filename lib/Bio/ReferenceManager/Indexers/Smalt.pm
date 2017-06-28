package Bio::ReferenceManager::Indexers::Smalt;

# ABSTRACT: create indexes for an application

=head1 SYNOPSIS

create indexes for an application

=cut

use Moose;
extends 'Bio::ReferenceManager::Indexers::Common';

has 'executable'          => ( is => 'rw', isa => 'Str', default => 'smalt' );
has 'software_name'       => ( is => 'rw', isa => 'Str', default => 'smalt' );
has 'version_regex'       => ( is => 'rw', isa => 'Str', default => 'Version: ([\d]+\.[\d]+\.[\d]+)' );
has 'version_parameter'   => ( is => 'rw', isa => 'Str', default => 'version' );
has 'software_suffix'     => ( is => 'rw', isa => 'ArrayRef', default => sub {['.default.sma', '.default.smi']} );

sub index_command
{
    my ($self) = @_;
    return join(' ',($self->executable, 'index', $self->fasta_file.'.default' , $self->fasta_file ));
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;