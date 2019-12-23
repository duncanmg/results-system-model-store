
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
use ResultsSystem::Core::Logger;
use ResultsSystem::Store::Configuration;
use ResultsSystem::Store::WeekResults::Reader;
use ResultsSystem::Store::WeekResults::Writer;

use ResultsSystem::Store::Base;
use parent qw/ResultsSystem::Store::Base/;

=head2 new

  my $facory = ResultsSystem::Store::Factory->new(
    -configuration => $c,
    -logger => $l
  );

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  bless $self, $class;

  $DB::single = 1;
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  $self->set_logger( $args->{-logger} )               if $args->{-logger};

  return $self;
}

=head2 Logger

=cut

=head3 get_logger

=cut

sub get_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Core::Logger->new(%$args);
}

=head3 get_configuration

Returns a ResultsSystem::Store::Configuration object. The same object is returned
each time for the duration of the request. (Not strictly a singleton.)

=cut

sub get_configuration {
  my ( $self, $args ) = @_;
  my $s = sub {

    return ResultsSystem::Store::Configuration->new(
      -logger =>
        $self->get_screen_logger( { -category => 'ResultsSystem::Store::Configuration' } ),
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
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Store::FixtureList' } ),
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
    { -logger                => $self->get_file_logger( { -category => 'ResultsSystem::Store' } ),
      -configuration         => $self->get_configuration,
      -fixture_list_model    => $self->get_fixture_list_model,
      -store_divisions_model => $self->get_store_divisions_model,
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
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Store::Divisions' } ),
      -full_filename => $self->get_configuration->get_divisions_full_filename,
    }
  );
  if ( $self->get_configuration->get_divisions_full_filename ) {
    $d->read_file;
  }
  return $d;
}

=head3 get_screen_logger

=cut

sub get_screen_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  $args->{-category} ||= 'Default';
  return $self->get_logger($args)->screen_logger( $args->{-category} );
}

=head3 get_file_logger

=cut

sub get_file_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  if ( !( $args->{-log_dir} && $args->{-logfile_stem} ) ) {
    my $c = $self->get_configuration;
    $args->{-log_dir}      = $c->get_path( -log_dir => 1 );
    $args->{-logfile_stem} = $c->get_log_stem;
  }
  $args->{-category} ||= 'Default';
  return $self->get_logger($args)->logger( $args->{-category} );
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _create_once

Accepts a key and a function which returns and object.

It executes the function and stores the object in the cache before returning it.

On subsequent calls it returns the cached object instead of creating a new one.

my $obj = $self->_create_once( 'configuration', $s );

=cut

sub _create_once {
  my ( $self, $key, $sub ) = validate_pos( @_, 1, 1, 1 );
  if ( !$self->{$key} ) {
    $self->{$key} = $sub->();
  }
  return $self->{$key};
}

=head3 get_week_data_reader_model_factory

Returns a function which returns a new ResultsSystem::Store::WeekResults::Reader object
on each call.

Does not set full_filename or read a file.

=cut

sub get_week_data_reader_model_factory {
  my ( $self, $args ) = @_;
  return sub {
    return ResultsSystem::Store::WeekResults::Reader->new(
      { -logger =>
          $self->get_file_logger( { -category => 'ResultsSystem::Store::WeekResults::Reader' } ),
        -configuration => $self->get_configuration,
      }
    );
  };
}

=head3 get_week_data_writer_model

Returns a ResultsSystem::Store::WeekResults::Writer object.

If $self->get_configuration->get_results_full_filename is set then this value is
passed to set_full_filename.

=cut

sub get_week_data_writer_model {
  my ( $self, $args ) = @_;
  my $w = ResultsSystem::Store::WeekResults::Writer->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Store::WeekResults::Writer' } ),
      -configuration => $self->get_configuration,
    }
  );
  if ( $self->get_configuration->get_results_full_filename ) {
    $w->set_full_filename( $self->get_configuration->get_results_full_filename );
  }

  return $w;
}

1;
