use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Differences;

use Helper qw/ get_config get_logger/;

use_ok('ResultsSystem::Store::FixtureList::Set');

my $set;
ok( $set = ResultsSystem::Store::FixtureList::Set->new({}), "Got an object" );
isa_ok( $set, 'ResultsSystem::Store::FixtureList::Set' );

is( $set->get_division_dir( $set->set_division_dir('test1') ), 'test1', 'get set division_dir' );

is( $set->get_factory( $set->set_factory('test2') ), 'test2', 'get set factory' );

eq_or_diff( $set->get_directory_list( $set->set_directory_list( ['test3'] ) ),
  ['test3'], 'get set directory_list' );

# eq_or_diff( $set->create_set() , ['test3'], 'create_set' );

done_testing;
