package Bio::ReferenceManager::RefsIndex;

# ABSTRACT: A class for working with the refs Index file

=head1 SYNOPSIS

A class for working with the refs Index file. 

=cut

use Moose;
use File::Basename;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'index_filename'     => ( is => 'ro', isa => 'Str', default  => 'refs.index' );
has 'reference_filename' => ( is => 'ro', isa => 'Str', required => 1 );

#It reads the file each time to check for duplicates, then appends.
#There is a slight chance of duplicates but that wont do much harm.

sub reference_names_to_files {
    my ($self) = @_;
    my %reference_names_to_files;
    open( my $index_file, $self->index_filename )
      or $self->logger->error( "Couldnt open reference index file for reading" . $self->index_filename );
    while (<$index_file>) {
        chomp;
        my $line = $_;
        my @reference_details = split( /\t/, $line );
        $reference_names_to_files{ $reference_details[0] } = $reference_details[1];
    }
    return \%reference_names_to_files;
}

sub reference_prefix {
    my ($self) = @_;
    my ( $filename, $dirs, $suffix ) = fileparse( $self->reference_filename, qr/\.[^.]*/ );
    return $filename;
}

sub add_reference_to_index {
    my ($self)        = @_;
    my $refs_to_files = $self->reference_names_to_files;
    my $refs_prefix   = $self->reference_prefix;
    if ( $refs_to_files->{$refs_prefix} ) {
        $self->logger->info( "Not adding reference to index as its already there: " . $refs_prefix );
    }
    else {
        open( my $index_file, '>>', $self->index_filename )
          or $self->logger->error( "Couldnt open reference index file for writing: " . $self->index_filename );
        print {$index_file} $refs_prefix . "\t" . $self->reference_filename . "\n";
        close($index_file);
    }
    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
