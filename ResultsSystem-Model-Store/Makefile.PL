use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Find;

my %WriteMakefileArgs = (
    NAME             => 'ResultsSystem::Model::Store',
    AUTHOR           => q{Duncan Garland <duncan.garland@ntlworld.com>},
    VERSION_FROM     => 'lib/ResultsSystem/Model/Store.pm',
    ABSTRACT_FROM    => 'lib/ResultsSystem/Model/Store.pm',
    LICENSE          => 'artistic_2',
    MIN_PERL_VERSION => '5.010',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    TEST_REQUIRES => {
        'Test::More' => '1.302133',
        'Test::Deep' => '0.115',
        'Test::Differences' => '0.63',
        'Test::Exception' => '0.43',
    },
    PREREQ_PM => {
	'Carp'				=> '1.3301',
	'Data::Dumper'			=> '2.154',
	'List::MoreUtils'		=> '0.405',
	'Params::Validate'		=> '1.18',
	'parent'			=> '0.228',
	'Regexp::Common'		=> '2013031301',
	'Sort::Maker'			=> '0.06',
	'strict'			=> '1.04',
	'warnings'			=> '1.06',
	'XML::Simple'			=> '2.20',
	'ResultsSystem::Exception'	=> '0.01',
	'ResultsSystem::Model'		=> '0.01',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'ResultsSystem-Model-Store-*' },
    test => {
	    TESTS => find_test_dirs(), 
	    # RECURSIVE_TEST_FILES=>1
    },

);

# Compatibility with old versions of ExtUtils::MakeMaker
unless (eval { ExtUtils::MakeMaker->VERSION('6.64'); 1 }) {
    my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

unless (eval { ExtUtils::MakeMaker->VERSION('6.55_03'); 1 }) {
    my $build_requires = delete $WriteMakefileArgs{BUILD_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$build_requires} = values %$build_requires;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION('6.52'); 1 };
delete $WriteMakefileArgs{MIN_PERL_VERSION}
    unless eval { ExtUtils::MakeMaker->VERSION('6.48'); 1 };
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);

sub find_test_dirs {
  my $dirs = {};
  my $wanted = sub {
      $dirs->{$File::Find::dir.'/*.t'} = 1;
  };
  find($wanted, 't', 'xt');
  my $out = join( ' ', keys %$dirs);
  return $out;
}

