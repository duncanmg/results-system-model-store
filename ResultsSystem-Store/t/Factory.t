use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Differences;
use Data::Dumper;
use Ref::Util qw/is_blessed_ref/;
use FindBin qw($Bin);
use FindBin::libs;

use Helper qw/get_logger get_config/;

use Test::MockObject;

use_ok('ResultsSystem::Store::Factory');

ok( get_config(), "get_config" );
ok( get_logger(), "get_logger" );

my $factory;
ok(
  $factory = ResultsSystem::Store::Factory->new(
    { -configuration => get_config(), -logger => get_logger() }
  ),
  "Got a simple object"
);
isa_ok( $factory, 'ResultsSystem::Store::Factory' );

#===========================

my @methods = qw/
  get_logger
  get_configuration
  get_fixture_list_model
  get_store_model
  get_store_divisions_model
  get_file_logger
  get_screen_logger
  get_week_data_writer_model
  /;

ok( $factory->set_system(100), "set_system" );
is( $factory->get_system, 100, "get_system" );
is( ref( $factory->get_week_data_reader_model_factory ),
  "CODE", "get_week_data_reader_model_factory" );

foreach my $m (@methods) {
  my $o;
  lives_ok( sub { $o = $factory->$m(); }, "$m lives" );
  ok( is_blessed_ref($o), "$m returned an object" );
}

done_testing;
