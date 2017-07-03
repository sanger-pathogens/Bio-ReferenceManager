package Bio::ReferenceManager::VRTrack::Assemblies;

# ABSTRACT: Add a list of reference to a database if they do not exist already

=head1 SYNOPSIS

Add a list of reference to a database if they do not exist already

=cut

use Moose;
use Bio::ReferenceManager::VRTrack::Schema;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'dbh'        => ( is => 'rw', isa => 'Bio::ReferenceManager::VRTrack::Schema',     required => 1 );
has 'references' => ( is => 'rw', isa => 'ArrayRef[Bio::ReferenceManager::Reference]', required => 1 );

# Dont save
sub reference_names {
    my ($self) = @_;
    my %refs_hash;
    for my $ref ( @{ $self->references } ) {
        $refs_hash{ $ref->basename } = $ref;
    }
    return \%refs_hash;
}

sub search_reference_names {
    my ($self) = @_;
    my @ref_names = keys $self->reference_names();
    my $assemblies = $self->dbh->resultset('Assembly')->search( { name => \@ref_names } );
    return $assemblies;
}

sub references_needing_to_be_added {
    my ($self) = @_;

    my @references_missing_from_db;
    my %ref_names = %{ $self->reference_names };

    # Go through each assembly and delete them from the reference name list.
    my $search_reference_names_results = $self->search_reference_names;
    while ( my $assembly = $search_reference_names_results->next ) {
        if ( defined( $ref_names{ $assembly->name } ) ) {
            delete( $ref_names{ $assembly->name } );
        }
    }

    #should now be left with a list of references to be added

    my @references_to_be_added = values %ref_names;
    return \@references_to_be_added;
}

sub insert_references_into_assembly_table {
    my ($self) = @_;

    my $number_inserted = 0;
    for my $reference ( @{ $self->references_needing_to_be_added } ) {
        $self->dbh->resultset('Assembly')->create( { name => $reference->basename, reference_size => $reference->sequence_length } );
        $number_inserted++;
    }
    return $number_inserted;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

