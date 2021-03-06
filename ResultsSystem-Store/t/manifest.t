#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use FindBin qw/$Bin/;

unless ( $ENV{RELEASE_TESTING} ) {
  plan( skip_all => "Author tests not required for installation" );
}

my $min_tcm = 0.9;
eval "use Test::CheckManifest $min_tcm";
plan skip_all => "Test::CheckManifest $min_tcm required" if $@;

ok_manifest( { exclude => ["$Bin/log/", '/home/duncan/git/results-system-store/ResultsSystem-Store/cover_db'] } );
