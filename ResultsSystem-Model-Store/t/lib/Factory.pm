
=head1 NAME

ResultsSystem::Factory

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

package ResultsSystem::Factory;

use strict;
use warnings;
use Params::Validate qw/:all/;

use ResultsSystem::Logger;
use ResultsSystem::Starter;
use ResultsSystem::Router;
use ResultsSystem::Locker;
use ResultsSystem::AutoCleaner;

use ResultsSystem::Configuration;

use ResultsSystem::Controller::Frame;
use ResultsSystem::Controller::Menu;
use ResultsSystem::Controller::Blank;
use ResultsSystem::Controller::MenuJs;
use ResultsSystem::Controller::WeekFixtures;
use ResultsSystem::Controller::SaveResults;
use ResultsSystem::Controller::TablesIndex;
use ResultsSystem::Controller::ResultsIndex;
use ResultsSystem::Controller::LeagueTable;
use ResultsSystem::Controller::Pwd;
use ResultsSystem::Controller::WeekResults;

use ResultsSystem::Model::Frame;
use ResultsSystem::Model::Menu;
use ResultsSystem::Model::FixtureList;
use ResultsSystem::Model::MenuJs;
use ResultsSystem::Model::WeekResults::Reader;
use ResultsSystem::Model::WeekResults::Writer;
use ResultsSystem::Model::WeekFixtures::Adapter;
use ResultsSystem::Model::WeekFixtures::Selector;
use ResultsSystem::Model::SaveResults;
use ResultsSystem::Model::Pwd;
use ResultsSystem::Model::LeagueTable;
use ResultsSystem::Model::ResultsIndex;
use ResultsSystem::Model::TablesIndex;
use ResultsSystem::Model::Store;
use ResultsSystem::Model::Store::Divisions;

use ResultsSystem::View::Frame;
use ResultsSystem::View::Menu;
use ResultsSystem::View::Blank;
use ResultsSystem::View::MenuJs;
use ResultsSystem::View::Week::FixturesForm;
use ResultsSystem::View::Week::Results;
use ResultsSystem::View::Pwd;
use ResultsSystem::View::Message;
use ResultsSystem::View::MessageJs;
use ResultsSystem::View::LeagueTable;
use ResultsSystem::View::ResultsIndex;
use ResultsSystem::View::TablesIndex;

=head2 new

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  $self->set_system( $args->{system} ) if $args->{system};
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

=head3 get_starter

=cut

sub get_starter {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Starter->new( { -configuration => $self->get_configuration(), %$args } );
}

=head3 get_router

=cut

sub get_router {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Router->new( { -factory => $self, %$args } );
}

=head3 get_locker

=cut

sub get_locker {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Locker->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::Locker' } ),
      -configuration => $self->get_configuration()
    }
  );
}

=head3 get_auto_cleaner

=cut

sub get_auto_cleaner {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::AutoCleaner->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::AutoCleaner' } ),
      -configuration => $self->get_configuration()
    }
  )->set_logfile_stem(".*")
    ->set_log_dir( $self->get_configuration->get_path( -log_dir => 'Y' ) );
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

=head3 get_full_filename

=cut

sub get_full_filename {
  my $self   = shift;
  my $system = $self->get_system;
  return $system ? "../custom/$system/$system.ini" : undef;
}

=head2 Controllers

=cut

=head3 get_frame_controller

=cut

sub get_frame_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Frame->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Controller::Frame' } ),
      -frame_model => $self->get_frame_model,
      -frame_view  => $self->get_frame_view
    }
  );
}

=head3 get_menu_controller

=cut

sub get_menu_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Menu->new(
    { -logger     => $self->get_file_logger( { -category => 'ResultsSystem::Controller::Menu' } ),
      -menu_model => $self->get_menu_model,
      -menu_view  => $self->get_menu_view
    }
  );
}

=head3 get_blank_controller

=cut

sub get_blank_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Blank->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Controller::Blank' } ),
      -blank_view => $self->get_blank_view
    }
  );
}

=head3 get_menu_js_controller

=cut

sub get_menu_js_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::MenuJs->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Controller::MenuJs' } ),
      -menu_js_view    => $self->get_menu_js_view,
      -menu_js_model   => $self->get_menu_js_model,
      -message_js_view => $self->get_message_js_view
    }
  );
}

=head3 get_week_fixtures_controller

=cut

sub get_week_fixtures_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::WeekFixtures->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Controller::WeekFixtures' } ),
      -week_fixtures_view           => $self->get_week_fixtures_view,
      -week_fixtures_selector_model => $self->get_week_fixtures_selector_model,
      -configuration                => $self->get_configuration,
      -store_divisions_model        => $self->get_store_divisions_model,
    }
  );
}

=head3 get_save_results_controller

=cut

sub get_save_results_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::SaveResults->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Controller::SaveResults' } ),
      -message_view       => $self->get_message_view,
      -save_results_model => $self->get_save_results_model,
      -locker             => $self->get_locker,
    }
  );
}

=head3 get_results_index_controller

=cut

sub get_results_index_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::ResultsIndex->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Controller::ResultsIndex' } ),
      -configuration       => $self->get_configuration,
      -results_index_model => $self->get_results_index_model,
      -results_index_view  => $self->get_results_index_view
    }
  );
}

=head3 get_tables_index_controller

=cut

sub get_tables_index_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::TablesIndex->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Controller::TablesIndex' } ),
      -configuration      => $self->get_configuration,
      -tables_index_model => $self->get_tables_index_model,
      -tables_index_view  => $self->get_tables_index_view,
    }
  );
}

=head3 get_league_table_controller

Writes the league table for the given division. Not called directly.
Requires authentication.

=cut

sub get_league_table_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::LeagueTable->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Controller::LeagueTable' } ),
      -configuration      => $self->get_configuration,
      -league_table_model => $self->get_league_table_model,
      -league_table_view  => $self->get_league_table_view,
    }
  );
}

=head3 get_pwd_controller

Returns a ResultsSystem::Controller::Pwd object.

=cut

sub get_pwd_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Pwd->new(
    { -logger    => $self->get_file_logger( { -category => 'ResultsSystem::Controller::Pwd' } ),
      -pwd_model => $self->get_pwd_model,
      -message_view => $self->get_message_view,
    }
  );
}

=head3 get_week_results_controller

Returns a ResultsSystem::Controller::WeekResults object.

=cut

sub get_week_results_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::WeekResults->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Controller::WeekResults' } ),
      -week_results_reader_model => $self->get_week_data_reader_model,
      -week_results_view         => $self->get_week_results_view,
      -configuration             => $self->get_configuration,
      -store_divisions_model     => $self->get_store_divisions_model,
    }
  );
}

=head2 Models

=cut

=head3 get_frame_model

=cut

sub get_frame_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Frame->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::Model::Frame' } ),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_menu_model

=cut

sub get_menu_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Menu->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::Model::Menu' } ),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_fixture_list_model

Returns a ResultsSystem::Model::FixtureList object. 

If the csv file for the request has been set in the configuration, 
then it will load the file before returning.

=cut

sub get_fixture_list_model {
  my ( $self, $args ) = @_;
  my $fl = ResultsSystem::Model::FixtureList->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Model::FixtureList' } ),
      -configuration => $self->get_configuration
    }
  );
  if ( $self->get_configuration->get_csv_full_filename ) {
    $fl->set_full_filename( $self->get_configuration->get_csv_full_filename );
    $fl->read_file;
  }
  return $fl;
}

=head3 get_menu_js_model

=cut

sub get_menu_js_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::MenuJs->new(
    { -logger      => $self->get_file_logger( { -category => 'ResultsSystem::Model::MenuJs' } ),
      -store_model => $self->get_store_model,
    }
  );
}

=head3 get_week_data_reader_model

Return a ResultsSystem::Model::WeekResults::Reader object.

If the full filename has been set then it will call read_file before returning the object.

=cut

sub get_week_data_reader_model {
  my ( $self, $args ) = @_;
  my $r = ResultsSystem::Model::WeekResults::Reader->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Model::WeekResults::Reader' } ),
      -configuration => $self->get_configuration,
    }
  );
  if ( $self->get_configuration->get_results_full_filename ) {
    $r->set_full_filename( $self->get_configuration->get_results_full_filename );
    $r->read_file;
  }

  return $r;
}

=head3 get_week_data_reader_model_factory

Returns a function which returns a new ResultsSystem::Model::WeekResults::Reader object
on each call.

Does not set full_filename or read a file.

=cut

sub get_week_data_reader_model_factory {
  my ( $self, $args ) = @_;
  return sub {
    return ResultsSystem::Model::WeekResults::Reader->new(
      { -logger =>
          $self->get_file_logger( { -category => 'ResultsSystem::Model::WeekResults::Reader' } ),
        -configuration => $self->get_configuration,
      }
    );
  };
}

=head3 get_week_data_writer_model

Returns a ResultsSystem::Model::WeekResults::Writer object.

If $self->get_configuration->get_results_full_filename is set then this value is
passed to set_full_filename.

=cut

sub get_week_data_writer_model {
  my ( $self, $args ) = @_;
  my $w = ResultsSystem::Model::WeekResults::Writer->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Model::WeekResults::Writer' } ),
      -configuration => $self->get_configuration,
    }
  );
  if ( $self->get_configuration->get_results_full_filename ) {
    $w->set_full_filename( $self->get_configuration->get_results_full_filename );
  }

  return $w;
}

=head3 get_week_fixtures_adapter_model

=cut

sub get_week_fixtures_adapter_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::WeekFixtures::Adapter->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Model::WeekFixtures::Adapter' } ),
      -configuration => $self->get_configuration,
      -week_results  => $self->get_week_data_reader_model,
    }
  );
}

=head3 get_week_fixtures_selector_model

=cut

sub get_week_fixtures_selector_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::WeekFixtures::Selector->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Model::WeekFixtures::Selector' } ),
      -configuration    => $self->get_configuration,
      -week_results     => $self->get_week_data_reader_model,
      -fixtures_adapter => $self->get_week_fixtures_adapter_model,
      -fixtures         => $self->get_fixture_list_model,
    }
  );
}

=head3 get_pwd_model

=cut

sub get_pwd_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Pwd->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::Model::Pwd' } ),
      -configuration => $self->get_configuration,
    }
  );
}

=head3 get_save_results_model

=cut

sub get_save_results_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::SaveResults->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Model::SaveResults' } ),
      -configuration    => $self->get_configuration,
      -week_data_writer => $self->get_week_data_writer_model(),
    }
  );
}

=head3 get_league_table_model

Returns a ResultsSystem::Model::LeagueTable object.

If get_calculation( -order_by => 1 ) is set in the configuration, then the
value is passed to the "set_order" method.

=cut

sub get_league_table_model {
  my ( $self, $args ) = @_;
  my $lt = ResultsSystem::Model::LeagueTable->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Model::LeagueTable' } ),
      -fixture_list_model => $self->get_fixture_list_model(),
      -store_model        => $self->get_store_model(),
    }
  );
  if ( $self->get_configuration->get_calculation( -order_by => 1 ) ) {
    $lt->set_order( $self->get_configuration->get_calculation( -order_by => 1 ) );
  }
  return $lt;
}

=head3 get_results_index_model

=cut

sub get_results_index_model {
  my ( $self, $args ) = @_;

  my $ri = ResultsSystem::Model::ResultsIndex->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Model::ResultsIndex' } ),
      -store_model => $self->get_store_model(),
    }
  );

  my $conf = $self->get_configuration;
  $ri->set_results_dir( $conf->get_path( results_dir => 'Y' ) )
    if $conf->get_path( results_dir => 'Y' );
  $ri->set_results_dir_full( $conf->get_path( results_dir_full => 'Y' ) )
    if $conf->get_path( results_dir_full => 'Y' );

  return $ri;
}

=head3 get_tables_index_model

=cut

sub get_tables_index_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::TablesIndex->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::Model::TablesIndex' } ),
      -configuration => $self->get_configuration,
      -store_model   => $self->get_store_model(),
    }
  );
}

=head3 get_store_model

Returns a ResultsSystem::Model::Store object.

=cut

sub get_store_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Store->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::Model::Store' } ),
      -configuration => $self->get_configuration,
      -fixture_list_model             => $self->get_fixture_list_model,
      -store_divisions_model          => $self->get_store_divisions_model,
      -week_data_reader_model_factory => $self->get_week_data_reader_model_factory
    }
  );
}

=head3 get_store_divisions_model

Returns a ResultsSystem::Model::Store::Divisions object.

If get_configuration->get_divisions_full_filenam is set then it will return read_file()
before returning.

=cut

sub get_store_divisions_model {
  my ( $self, $args ) = @_;
  my $d = ResultsSystem::Model::Store::Divisions->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::Model::Store::Divisions' } ),
      -full_filename => $self->get_configuration->get_divisions_full_filename,
    }
  );
  if ( $self->get_configuration->get_divisions_full_filename ) {
    $d->read_file;
  }
  return $d;
}

=head2 Views

=cut

=head3 get_frame_view

=cut

sub get_frame_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Frame->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::View::Frame' } ),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_menu_view

=cut

sub get_menu_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Menu->new(
    { -logger        => $self->get_file_logger( { -category => 'ResultsSystem::View::Menu' } ),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_blank_view

=cut

sub get_blank_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Blank->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::Blank' } ) } );
}

=head3 get_menu_js_view

=cut

sub get_menu_js_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::MenuJs->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::MenuJs' } ) } );
}

=head3 get_week_fixtures_view

=cut

sub get_week_fixtures_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Week::FixturesForm->new(
    { -logger =>
        $self->get_file_logger( { -category => 'ResultsSystem::View::Week::FixturesForm' } ),
      -pwd_view      => $self->get_pwd_view,
      -configuration => $self->get_configuration,
    }
  );
}

=head3 get_pwd_view

=cut

sub get_pwd_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Pwd->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::Pwd' } ) } );
}

=head3 get_message_view

=cut

sub get_message_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Message->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::Message' } ) } );
}

=head3 get_message_js_view

=cut

sub get_message_js_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::MessageJs->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::MessageJs' } ) } );
}

=head3 get_league_table_view

=cut

sub get_league_table_view {
  my ( $self, $args ) = @_;
  my $lt = ResultsSystem::View::LeagueTable->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::LeagueTable' } ),
      -configuration => $self->get_configuration
    }
  );
  if ( $self->get_configuration->get_csv_file ) {
    $lt->set_table_html_full_filename( $self->get_configuration->get_table_html_full_filename );
  }
  return $lt;
}

=head3 get_week_results_view

=cut

sub get_week_results_view {
  my ( $self, $args ) = @_;
  my $obj = ResultsSystem::View::Week::Results->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::Week::Results' } ),
      -configuration => $self->get_configuration
    }
  );
  if ( $self->get_configuration->get_results_html_full_filename ) {
    $obj->set_results_html_full_filename(
      $self->get_configuration->get_results_html_full_filename );
  }
  return $obj;
}

=head3 get_results_index_view

=cut

sub get_results_index_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::ResultsIndex->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::ResultsIndex' }, ),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_tables_index_view

=cut

sub get_tables_index_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::TablesIndex->new(
    { -logger => $self->get_file_logger( { -category => 'ResultsSystem::View::TablesIndex' }, ),
      -configuration => $self->get_configuration
    }
  );
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

1;
