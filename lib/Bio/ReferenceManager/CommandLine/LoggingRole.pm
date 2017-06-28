package Bio::ReferenceManager::CommandLine::LoggingRole;
# ABSTRACT: logging role

=head1 SYNOPSIS

logging role
 
=cut

use Moose::Role;
use Log::Log4perl qw(:easy);

has 'logger'       => ( is => 'ro', lazy => 1, builder => '_build_logger');

sub _build_logger
{
    my ($self) = @_;
    Log::Log4perl->easy_init($ERROR);
    my $logger = get_logger();
    return $logger;
}

1;
