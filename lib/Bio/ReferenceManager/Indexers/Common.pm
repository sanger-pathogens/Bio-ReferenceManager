package Bio::ReferenceManager::Indexers::Common;

# ABSTRACT: Common indexers

=head1 SYNOPSIS

 Common indexers
 
=cut

use Moose;
use File::Basename;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'fasta_file'      => ( is => 'rw', isa => 'Str',      required => 1 );
has 'software_name'   => ( is => 'rw', isa => 'Str',      required => 1 );
has 'executable'      => ( is => 'rw', isa => 'Str',      required => 1 );
has 'software_suffix' => ( is => 'rw', isa => 'ArrayRef', default  => sub { [] } );

has 'overwrite_files' => ( is => 'rw', isa => 'Bool', default => 0 );

has 'version_parameter' => ( is => 'rw', isa => 'Str',        default => '' );
has 'version_regex'     => ( is => 'rw', isa => 'Maybe[Str]', default => '([\d]+\.[\d]+\.[\d]+)' );
has 'software_version'  => ( is => 'rw', isa => 'Maybe[Str]', lazy    => 1, builder => '_build_software_version' );

# needs to be overwritten
sub index_command {
    my ($self) = @_;
    return undef;
}

sub base_directory {
    my ($self) = @_;
    my ( $filename, $dirs, $suffix ) = fileparse( $self->fasta_file );
    return $dirs;
}

sub _get_version_command {
    my ($self) = @_;
    return join( ' ', ( $self->executable, $self->version_parameter, '2>&1' ) );
}

sub _build_software_version {
    my ($self) = @_;
    $self->logger->info( "Version command for " . $self->software_name . ": " . $self->_get_version_command );
    my $cmd            = $self->_get_version_command();
    my $command_output = `$cmd`;

    return '' if ( !defined( $self->version_regex ) );
    my $regex = $self->version_regex;

    if ( $command_output =~ /$regex/ ) {
        return $1;
    }
    else {
        $self->logger->warn( "Couldnt determine version for " . $self->software_name );
        return '';
    }
}

sub application_version_prefix {
    my ($self) = @_;
    return join( '_', ( $self->software_name, $self->software_version ) );
}

sub expected_files {
    my ($self) = @_;
    my @files;
    for my $suffix ( @{ $self->software_suffix } ) {
        push( @files, $self->fasta_file . $suffix );
    }
    return \@files;
}

sub files_to_be_created {
    my ($self) = @_;

    if ( $self->overwrite_files ) {
        return $self->expected_files;
    }
    else {
        return $self->list_files_not_created;
    }
}

sub list_files_not_created {
    my ($self) = @_;
    my @files_not_created;

    for my $file ( @{ $self->expected_files } ) {
        if ( -e $file && -s $file > 2 ) {

            # everything is okay
        }
        else {
            $self->logger->warn( "File has not been created correctly for " . $self->software_name . ": " . $file );
            push( @files_not_created, $file );
        }
    }
    return \@files_not_created;
}

#create index files
#default in the same directory as reference
#*flag to overwrite, otherwise keep whats there
#*note file types for each file
#*syntax for creating index files
#*input fasta file
#*Check files are not empty
#
#create a versioned directory and place files there (application_version)
#collate all commands proposed to be run to allow for parallelisation
#
no Moose;
1;
