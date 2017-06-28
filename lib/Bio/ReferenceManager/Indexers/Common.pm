package Bio::ReferenceManager::Indexers::Common;
# ABSTRACT: Common indexers

=head1 SYNOPSIS

 Common indexers
 
=cut

use Moose;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'software_name'     => ( is => 'rw', isa => 'Str', required => 1 );
has 'executable'        => ( is => 'rw', isa => 'Str', required => 1 );
has 'version_parameter' => ( is => 'rw', isa => 'Str', default  => '' );
has 'version_regex'     => ( is => 'rw', isa => 'Maybe[Str]', default => '[\d]+\.[\d]+\.[\d]+' );
has 'software_version'  => ( is => 'rw', isa => 'Maybe[Str]', lazy =>1, builder => '_build_software_version' );

sub _get_version_command
{
    my ($self) = @_;
    return join(' ', ($self->executable, $self->version_parameter, '2>&1'));
}

sub _build_software_version
{
    my ($self) = @_;
    $self->logger->info("Version command for ".$self->software_name.": ".$self->_get_version_command);
    my $cmd = $self->_get_version_command();
    my $command_output = `$cmd`;
    
    return '' if(!defined($self->version_regex));
    my $regex = $self->version_regex;
    
    if($command_output =~ /$regex/)
    {
        return $1;
    }
    else
    {
        $self->logger->warn("Couldnt determine version for ".$self->software_name);
        return '';
    }
}

sub application_version_prefix
{
    my ($self) = @_; 
    return join('_', ($self->software_name, $self->software_version));
}

no Moose;
1;
