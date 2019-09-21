use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Differences;
use Data::Dumper;

use FindBin qw($Bin);
use FindBin::libs;

use Helper qw/get_logger/;

use Test::MockObject;

use_ok('ResultsSystem::Model::Store');

my $store;
ok( $store = ResultsSystem::Model::Store->new( {} ), "Got a simple object" );
isa_ok( $store, 'ResultsSystem::Model::Store' );

#===========================

my $mock_store_divisions_model = Test::MockObject->new();
$mock_store_divisions_model->mock( 'get_menu_names',
  sub { return ( { csv_file => 'one' }, { csv_file => 'two' } ) } );

my $mock_fixture_list_model = Test::MockObject->new();
$mock_fixture_list_model->mock( 'set_full_filename', sub { return $_[0] } );
$mock_fixture_list_model->mock( 'read_file',         sub { return $_[0] } );
$mock_fixture_list_model->mock( 'get_all_fixtures',  sub { return $_[0] } );

my $mock_configuration = Test::MockObject->new();
$mock_configuration->mock( 'get_path',
  sub { my $h = $_[1]; return 'path' if $h eq '-divisions_file_dir' } );

ok(
  $store = ResultsSystem::Model::Store->new(
    { -store_divisions_model => $mock_store_divisions_model,
      -fixture_list_model    => $mock_fixture_list_model,
      -configuration         => $mock_configuration
    }
  ),
  "Got a more useful object"
);
isa_ok( $store, 'ResultsSystem::Model::Store' );

my $all_fixture_lists = {};
lives_ok( sub { $all_fixture_lists = $store->get_all_fixture_lists; },
  "get_all_fixture_lists lives" );

ok( scalar( keys %$all_fixture_lists ) > 1, "Got more than 1 division" );

#is( scalar( grep { ref( $all_fixture_lists->{$_} ) ne 'ARRAY' } keys %$all_fixture_lists ),
#  0, 'Got a hash ref of list refs' )
#  || diag( Dumper $all_fixture_lists);
#
#is( ref( $store->get_all_week_results_for_division('U9.csv') ),
#  'ARRAY', 'get_all_week_results_for_division returns array ref' );
#
#eq_or_diff(
#  $store->_get_all_week_files('U9N.csv'),
#  [ $csv_files_with_season . '/U9N_1-May.dat',
#    $csv_files_with_season . '/U9N_15-May.dat',
#    $csv_files_with_season . '/U9N_8-May.dat',
#  ],
#  "_get_all_week_files"
#);
#
#is(
#  '28-Jun',
#  $store->_extract_date_from_result_filename('County1_28-Jun.dat'),
#  '_extract_date_from_result_filename with County1_28-Jun.dat'
#);
#
#is(
#  '28-Jun',
#  $store->_extract_date_from_result_filename('/with/path/County1_28-Jun.dat'),
#  '_extract_date_from_result_filename with County1_28-Jun.dat'
#);
#
#is(
#  '2-Jun',
#  $store->_extract_date_from_result_filename('/with/path/County1_2-Jun.dat'),
#  '_extract_date_from_result_filename with County1_2-Jun.dat'
#);
#
#throws_ok(
#  sub { $store->_extract_date_from_result_filename('/with/path/County1_28-Jun.csv') },
#  qr/did\snot\spass\sregex\scheck/x,
#  "_extract_date_from_result_filename won't accept csv file"
#);
#
#throws_ok( sub { $store->_extract_date_from_result_filename('/with/path/County1_28-June.dat') },
#  qr/BAD_RESULTS_FILENAME/x,
#  "_extract_date_from_result_filename. Month must have three letters." );
#
#throws_ok( sub { $store->_extract_date_from_result_filename('/with/path/County1_X-June.dat') },
#  qr/BAD_RESULTS_FILENAME/x, "_extract_date_from_result_filename. Day of month must be digits." );
#
#eq_or_diff(
#  $store->get_dates_and_result_filenames_for_division('U9N.csv'),
#  [ { file      => $csv_files_with_season . '/U9N_1-May.dat',
#      matchdate => '1-May'
#    },
#    { file      => $csv_files_with_season . '/U9N_15-May.dat',
#      matchdate => '15-May'
#    },
#    { file      => $csv_files_with_season . '/U9N_8-May.dat',
#      matchdate => '8-May'
#    },
#  ],
#  "get_dates_and_result_filenames_for_division"
#);

done_testing;
