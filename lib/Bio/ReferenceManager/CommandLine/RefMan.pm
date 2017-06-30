package Bio::ReferenceManager::CommandLine::RefMan;

# ABSTRACT: index references

=head1 SYNOPSIS

index references

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Cwd qw(abs_path);
use File::Path qw(make_path);
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose'     => ( is => 'rw', isa => 'Bool',     default  => 0 );

sub BUILD {
    my ($self) = @_;
}

sub run {
    my ($self) = @_;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: refman [options]
Add references to the pipelines

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
