#!/usr/bin/perl -w
#$Id: track.pl,v 1.2 2003/01/08 20:11:56 jay.powers Exp $
use Business::FedEx::DirectConnect;

my $t = Business::FedEx::DirectConnect->new(uri=>'https://gatewaybeta.fedex.com/GatewayDC'
	,acc => '' #FedEx Account Number
	,meter => '' #FedEx Meter Number (This is given after you subscribe to FedEx)
	,referer => 'Vermonster LLC' # Name or Company
	,host=> 'gatewaybeta.fedex.com' #Host
	);

$t->set_data(5000,29 =>'158603877972') or die $t->errstr;

$t->transaction() or die $t->errstr;

print $t->lookup('signed_for');