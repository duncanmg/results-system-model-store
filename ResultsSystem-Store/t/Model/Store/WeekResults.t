use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Differences;

use List::MoreUtils qw/any/;

use FindBin qw($Bin);
use FindBin::libs;

use Helper qw/get_config get_logger/;

use_ok('ResultsSystem::Store::WeekResults');

my $config = get_config;

my $wd;
ok(
  $wd = ResultsSystem::Store::WeekResults->new(
    { -config => $config, -logger => get_logger($config) }
  ),
  "Created a WeekResults object."
);

is( $wd->get_full_filename( $wd->set_full_filename('fred') ), 'fred', "get/set full_filename" );

eq_or_diff(
  $wd->get_default_result,
  my $list = [
    { name => "team",          value => "" },
    { name => "played",        value => 'N' },
    { name => "result",        value => 'W' },
    { name => "runs",          value => 0 },
    { name => "wickets",       value => 0 },
    { name => "performances",  value => "" },
    { name => "resultpts",     value => 0 },
    { name => "battingpts",    value => 0 },
    { name => "bowlingpts",    value => 0 },
    { name => "penaltypts",    value => 0 },
    { name => "totalpts",      value => 0 },
    { name => "pitchmks",      value => 0 },
    { name => "groundmks",     value => 0 },
    { name => "facilitiesmks", value => 0 },
  ],
  "get_default_result"
);

is( $wd->file_not_found(1), 1, "file_not_found 1" );
is( $wd->file_not_found(0), 0, "file_not_found 0" );
is( $wd->file_not_found(7), 0, "file_not_found 7. (Retains last value)" );

eq_or_diff(
  [ $wd->get_labels ],
  [ "team",      "played",     "result",     "runs",       "wickets",  "performances",
    "resultpts", "battingpts", "bowlingpts", "penaltypts", "totalpts", "pitchmks",
    "groundmks", "facilitiesmks",
  ],
  "get_default_result"
);

done_testing;
