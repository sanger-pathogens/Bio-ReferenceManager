package Bio::ReferenceManager::VRTrack::DatabaseManager;

# ABSTRACT: manage the database connections

=head1 SYNOPSIS

manage the database connections

=cut

use Moose;
use DBI;
use Path::Class;
use Bio::ReferenceManager::VRTrack::Schema;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'driver'        => ( is => 'ro', isa => 'Str',        default  => 'mysql' );
has 'sqlite_dbname' => ( is => 'ro', isa => 'Maybe[Str]', required => 0 );

has 'host'     => ( is => 'ro', isa => 'Str',        lazy => 1, builder => '_build_host' );
has 'port'     => ( is => 'ro', isa => 'Int',        lazy => 1, builder => '_build_port' );
has 'user'     => ( is => 'ro', isa => 'Str',        lazy => 1, builder => '_build_user' );
has 'password' => ( is => 'ro', isa => 'Maybe[Str]', lazy => 1, builder => '_build_password' );

has 'data_sources' => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    builder => '_build_data_sources',
);

sub _build_host {
    my ($self) = @_;
    return $ENV{VRTRACK_HOST} || 'localhost';
}

sub _build_port {
    my ($self) = @_;
    return $ENV{VRTRACK_PORT} || 3306;
}

sub _build_user {
    my ($self) = @_;
    return $ENV{VRTRACK_RW_USER} || 'root';
}

sub _build_password {
    my ($self) = @_;
    return $ENV{VRTRACK_PASSWORD} || undef;
}

sub _build_data_sources {
    my ($self) = @_;
    
    my $connection_params = { user => $self->user,  password => $self->password, host => $self->host, port => $self->port };

    # ask the DBI for a list of sources
    my @sources = grep s/^dbi:.*?:pathogen/pathogen/i, DBI->data_sources( $self->driver, $connection_params );

    # if we're using SQLite, "data_sources" won't return anything, so add
    # the name of the database itself

    my $dbname = file( $self->sqlite_dbname )->basename;
    $dbname =~ s/\..*$//;

    push @sources, $dbname if $self->sqlite_dbname;

    return \@sources;
}


sub get_dsn {
    my ( $self, $database_name ) = @_;

    my $dsn;

    if ( $self->driver eq 'mysql' ) {
        $dsn = "DBI:mysql:host=".$self->host.";port=".$self->port.";database=" . $database_name;
    }
    elsif ( $self->driver eq 'SQLite' ) {
        $dsn = "dbi:SQLite:dbname=".$self->sqlite_dbname;
    }

    return $dsn;
}

sub connect_to_database
{
    my ( $self,$database_name) = @_;
    my $schema;
    if (  $self->driver eq 'mysql' ) {
      $schema = Bio::ReferenceManager::VRTrack::Schema->connect($self->get_dsn($database_name), $self->user, $self->password);
    }
    elsif (  $self->driver eq 'SQLite' ) {
      $schema = Bio::ReferenceManager::VRTrack::Schema->connect($self->get_dsn($database_name));
    }
    return $schema;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

