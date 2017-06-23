package Bio::ReferenceManager::Reference;

# ABSTRACT: Represents a reference and metadata

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;

has 'final_filename'    => ( is => 'rw', isa => 'Maybe[Str]');
has 'original_filename' => ( is => 'rw', isa => 'Maybe[Str]');
has 'sequence_length'   => ( is => 'rw', isa => 'Maybe[Int]');
has 'md5'               => ( is => 'rw', isa => 'Maybe[Str]');

no Moose;
__PACKAGE__->meta->make_immutable;

1;
