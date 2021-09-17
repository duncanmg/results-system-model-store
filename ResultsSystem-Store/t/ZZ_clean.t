use strict;
use warnings;
use Test::More;

use_ok('Helper');

my $log_dir = Helper::get_config()->get_path(-log_dir=>'Y');
if (-d $log_dir){
	system("rm $log_dir/*.log");
}

done_testing;
