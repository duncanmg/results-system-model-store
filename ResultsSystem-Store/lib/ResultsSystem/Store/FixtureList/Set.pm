
=head1 NAME

ResultsSystem::Store::FixtureList

=cut

=head1 SYNOPSIS

  $f = FixtureList->new( -logger => $logger, -configuration => $configuration, 
    -full_filename => "/a/b/division1.csv" );
  
  $f->read_file;

or

  $f = FixtureList->new( -logger => $logger, -configuration => $configuration );
  
  $f->set_full_filename( "/a/b/division1.csv" );
  $f->read_file;

=cut

=head1 DESCRIPTION

This module reads a fixtures csv file and loads it into an internal data structure.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Store|http://www.results_system_nfcca.com:8088/ResultsSystem/Store>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Store::FixtureList::Set;

use strict;
use warnings;
use Carp;

use Regexp::Common;
use List::MoreUtils qw/any/;

use File::Slurp qw/slurp/;
use Data::Dumper;
use Path::Tiny;
use Clone qw/clone/;

use ResultsSystem::Store;
use parent qw/ResultsSystem::Store/;

=head2 new

$f = FixtureList->new( -logger => $logger, -configuration => $configuration, 
  -full_filename => "/a/b/division1.csv" );

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  my $err = 0;

  $self->set_arguments( [qw/division_list division_dir logger configuration factory /], $args );

  return $self if $err == 0;
  return;
}

=head2 get_directory_list

=cut

#***************************************
sub get_directory_list {

  #***************************************
  my $self = shift;
  return $self->{DIRECTORY_LIST} || "";
}

=head2 set_directory_list

=cut

#***************************************
sub set_directory_list {

  #***************************************
  my $self = shift;
  $self->{DIRECTORY_LIST} = shift;
  return $self;
}

=head2 get_division_dir

=cut

#***************************************
sub get_division_dir {

  #***************************************
  my $self = shift;
  return $self->{DIVISION_DIR} || "";
}

=head2 set_division_dir

=cut

#***************************************
sub set_division_dir {

  #***************************************
  my $self = shift;
  $self->{DIVISION_DIR} = shift;
  return $self;
}

=head2 get_factory

=cut

#***************************************
sub get_factory {

  #***************************************
  my $self = shift;
  return $self->{FACTORY} || "";
}

=head2 set_factory

=cut

#***************************************
sub set_factory {

  #***************************************
  my $self = shift;
  $self->{FACTORY} = shift;
  return $self;
}

=head2 create_set

=cut

#***************************************
sub create_set {

  #***************************************
  my $self = shift;

  my @divs = @{$self->get_division_list};
  foreach my $d(@divs){
  }

  return $self;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;
