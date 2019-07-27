#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'ResultsSystem::Model::Store' ) || print "Bail out!\n";
}

diag( "Testing ResultsSystem::Model::Store $ResultsSystem::Model::Store::VERSION, Perl $], $^X" );
