package Helper;

use strict;
use warnings;
use Carp;
use Test::MockObject;

# use ResultsSystem;

use parent qw/Exporter/;

our @EXPORT_OK = qw/get_config get_logger/;

=head1 NAME

Helper

=head1 SYNOPSIS

Test helpers.

  use Helper qw/get_config get_logger/;

=cut

=head1 DESCRIPTION

=head1 INHERITS FROM

Nothing, this is not an object.

=head1 EXTERNAL (PUBLIC) METHODS

N/A

=head1 INTERNAL (PRIVATE) METHODS

N/A

=head1 EXPORTED FUNCTIONS

=cut

=head2 get_config

Reads the configuration file contained in $ARGV[0] or, if $ARGV[0] is false,
the environment variable NFCCA_CONFIG.

Die if neither is present.

=cut

sub get_config {

  my $file = get_system();

  return get_factory()->get_configuration;
}

=head2 get_logger

=cut

sub get_logger {

  my $logger = Test::MockObject->new();
  $logger->mock( 'debug', sub { return 1; } );
  $logger->mock( 'error', sub { return 1; } );
  return $logger;
}

1;
