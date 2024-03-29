use strict;
use warnings;

use FindBin qw($Bin);
use FindBin::libs;

use Test::More;
use Test::Exception;
use Test::Deep;
use Data::Dumper;

use Helper qw/get_logger/;

use_ok('ResultsSystem::Store::Divisions');

my $d;
ok( $d = ResultsSystem::Store::Divisions->new( { -logger => get_logger() } ),
  "Got an object" );
isa_ok( $d, 'ResultsSystem::Store::Divisions' );

throws_ok( sub { $d->read_file }, qr/FILENAME_NOT_SET/, "Read file" );

ok( $d->set_full_filename('i_do_not_exist'), "Set to bad file" );

throws_ok( sub { $d->read_file }, qr/FILE_DOES_NOT_EXIST,i_do_not_exist/, "Read file" );

ok( $d->set_full_filename( $Bin . '/../../data/divisions.xml' ), "Set to good file" );

lives_ok( sub { $d->read_file }, "Read file" );

my @names;
ok( @names = $d->get_menu_names, "get_menu_names" );

my $counter = 0;

foreach my $n (@names) {
  ok( exists( $n->{menu_position} ), "Key menu_position exists" )
    || diag( Dumper $n);
  ok( exists( $n->{csv_file} ), "Key csv_file exists" ) || diag( Dumper $n);
  ok( exists( $n->{menu_name} ), "Key menu_name exists. " . $n->{menu_name} ) || diag( Dumper $n);
  $counter++;
}
ok( $counter, "Got at least one menu name. " . $counter );

cmp_deeply(
  $names[0],
  $d->get_name( -menu_name => $names[0]->{menu_name} ),
  "get_name return the correct hash ref"
);

# ************************************************************************

throws_ok(
  sub { $d->_load_file( \"Mary had a little lamb" ); },
  qr/XML_ERROR,Error reading XML/,
  "String not XML"
);

throws_ok( sub { $d->_load_file( \"<test>Mary had a little lamb" ); },
  qr/XML_ERROR/, "Malformed XML" );

throws_ok( sub { $d->_load_file( \"<test>Mary had a little lamb</test>" ); },
  qr/XML_ERROR/, "No start or end <xml> tags" );

# print Dumper $d->_load_file( \"<xml><test>Mary had a little lamb</test></xml>" );

done_testing;
