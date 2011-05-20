use strict;
use warnings;
use Encode;
use FindAddressJPUtil;


my $csv_file = './KEN_ALL.CSV';
my $output_file = './KEN_ALL_UTF.dat';

FindAddressJPUtil::conversion($csv_file, $output_file);

