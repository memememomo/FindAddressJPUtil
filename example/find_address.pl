use strict;
use warnings;
use utf8;
use Encode;
use FindAddressJPUtil;


my $dat_file = 'KEN_ALL_UTF.dat';

my $zipcode = '600-8815';
my $list = FindAddressJPUtil::find_address($zipcode, $dat_file, (find_loop => 4));

if ($list) {
    for my $addr (@$list) {
	print encode_utf8($addr->{zipcode1}."-".$addr->{zipcode2})."\n";
	print encode_utf8($addr->{pref}.$addr->{addr1})."\n";
    }
}

my $address = '京都府京都市下京区';
$list = FindAddressJPUtil::find_address($address, $dat_file);
if ($list) {
    for my $addr (@$list) {
	print encode_utf8($addr->{zipcode1}."-".$addr->{zipcode2})."\n";
	print encode_utf8($addr->{pref}.$addr->{addr1})."\n";
    }
}
