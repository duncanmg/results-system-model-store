
=head1 NAME

ResultsSystem::Store::Factory

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Store::Factory;

use strict;
use warnings;
use Params::Validate qw/:all/;

use ResultsSystem::Store::FixtureList;
use ResultsSystem::Store;
use ResultsSystem::Store::Divisions;

=head2 new

  my $facory = ResultsSystem::Store::Factory->new(
    -configuration => $c,
    -logger => $l
  );

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};

  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  $self->set_logger( $args->{-logger} )               if $args->{-logger};

  return bless $self, $class;
}

=head2 Logger

=cut

=head3 get_logger

=cut

sub get_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Logger->new(%$args);
}

=head3 get_configuration

Returns a ResultsSystem::Configuration object. The same object is returned
each time for the duration of the request. (Not strictly a singleton.)

=cut

sub get_configuration {
  my ( $self, $args ) = @_;
  my $s = sub {

    return ResultsSystem::Configuration->new(
      -logger => $self->get_screen_logger( { -category => 'ResultsSystem::Configuration' } ),
      -full_filename => $args->{-full_filename}
    );
  };
  return $self->_create_once( 'configuration', $s );
}

=head3 set_system

=cut

sub set_system {
  my $self = shift;
  $self->{SYSTEM} = shift;
  return $self->{SYSTEM};
}

=head3 get_system

=cut

sub get_system {
  my $self = shift;
  return $self->{SYSTEM};
}

=head2 Models

=cut

=head3 get_fixture_list_model

Returns a ResultsSystem::Store::FixtureList object. 

If the csv file for the request has been set in the configuration, 
then it will load the file before returning.

=cut

sub get_fixture_list_model {
  my ( $self, $args ) = @_;
  my $fl = ResultsSystem::Store::FixtureList->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Store::FixtureList' } ),
      -configuration => $self->get_configuration
    }
  );
  if ( $self->get_configuration->get_csv_full_filename ) {
    $fl->set_full_filename( $self->get_configuration->get_csv_full_filename );
    $fl->read_file;
  }
  return $fl;
}

=head3 get_store_model

Returns a ResultsSystem::Store object.

=cut

sub get_store_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Store->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::Store' } ),
      -configuration => $self->get_configuration,
      -fixture_list_model             => $self->get_fixture_list_model,
      -store_divisions_model          => $self->get_store_divisions_model,
      -week_data_reader_model_factory => $self->get_week_data_reader_model_factory
    }
  );
}

=head3 get_store_divisions_model

Returns a ResultsSystem::Store::Divisions object.

If get_configuration->get_divisions_full_filenam is set then it will return read_file()
before returning.

=cut

sub get_store_divisions_model {
  my ( $self, $args ) = @_;
  my $d = ResultsSystem::Store::Divisions->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Store::Divisions' } ),
      -full_filename => $self->get_configuration->get_divisions_full_filename,
    }
  );
  if ( $self->get_configuration->get_divisions_full_filename ) {
    $d->read_file;
  }
  return $d;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;
