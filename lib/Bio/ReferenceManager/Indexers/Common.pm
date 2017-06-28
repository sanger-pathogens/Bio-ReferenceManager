package Bio::ReferenceManager::Indexers::Common;

# ABSTRACT: Common indexers

=head1 SYNOPSIS

 Common indexers
 
=cut

use Moose;
use File::Basename;
use Cwd qw(abs_path getcwd);
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'fasta_file'      => ( is => 'rw', isa => 'Str',      required => 1 );
has 'software_name'   => ( is => 'rw', isa => 'Str',      required => 1 );
has 'executable'      => ( is => 'rw', isa => 'Str',      required => 1 );
has 'output_base_dir' => ( is => 'rw', isa => 'Str',      default  => sub { getcwd();});
has 'software_suffix' => ( is => 'rw', isa => 'ArrayRef', default  => sub { [] } );

has 'overwrite_files' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'java_exec'       => ( is => 'rw', isa => 'Str', default  => 'java' );

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

sub base_filename
{
    my ($self) = @_;
    my ( $filename, $dirs, $suffix ) = fileparse( $self->fasta_file );
    return $filename.$suffix;
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
    my ($self,$directory) = @_;
    my @files;
    for my $suffix (sort @{ $self->software_suffix } ) {
        push( @files,$directory.'/'. $self->base_filename . $suffix );
    }
    return \@files;
}

sub files_to_be_created {
    my ($self, $directory) = @_;

    if ( $self->overwrite_files ) {
        return $self->expected_files($directory);
    }
    else {
        return $self->list_files_not_created($directory);
    }
}

sub list_files_not_created {
    my ($self,$directory) = @_;
    my @files_not_created;

    for my $file ( @{ $self->expected_files($directory) } ) {
        
        if ( -e $file && -s $file > 2 ) {
            # everything is okay
        }
        else {
            $self->logger->warn( "File has not been created correctly for " . $self->software_name . ": " . $file );
            push( @files_not_created, $file );
        }
    }
    my @sorted_files = sort @files_not_created;
    return \@sorted_files;
}

sub versioned_directory_name
{
    my ($self) = @_; 
    return join('/',($self->output_base_dir, $self->application_version_prefix));
}

sub run_indexing
{
   my ($self, $directory) = @_; 

   if(@{$self->files_to_be_created($directory)} > 0)
   {
     # Index in a separate subdirectory.
     my $original_directory =  getcwd();
     chdir( abs_path($directory) );
       
     # Make a symlink from the fasta file to the current directory if it doesnt exist
     if(! -e $self->base_filename && ! -l $self->base_filename && $self->fasta_file ne $self->base_filename)
     {
         symlink( $self->fasta_file, $self->base_filename);
     }
     
     system($self->index_command.' >/dev/null 2>&1');
     # Change back to the original working directory
     chdir( $original_directory );
   }
   else
   {
       $self->logger->warn( "No index files to create for " . $self->software_name );
   }
   return $self;
}

no Moose;
1;
