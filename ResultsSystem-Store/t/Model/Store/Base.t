use strict;
use warnings;

use Test::More;

use_ok('ResultsSystem::Store::Base');

my $b;
ok( $b = ResultsSystem::Store::Base->new, "Got an object" );
isa_ok( $b, 'ResultsSystem::Store::Base' );

is( $b->logger( $b->set_logger("Dummy") ), "Dummy", "logger" );

is( $b->get_configuration( $b->set_configuration("Dummy") ), "Dummy", "configuration" );

ok( $b->set_arguments( [qw/configuration idonotexist/], { -configuration => 'test' } ),
  "set_arguments" );
is( $b->get_configuration, 'test', 'get_configuration' );

done_testing;

