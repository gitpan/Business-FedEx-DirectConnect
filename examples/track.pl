#!/usr/bin/perl -w
#$Id: track.pl,v 1.6 2003/06/18 17:09:39 jay.powers Exp $
use Business::FedEx::DirectConnect;
use strict;
my $t = new Business::FedEx::DirectConnect(uri=> 'https://gatewaybeta.fedex.com/GatewayDC'
				,acc => '' #FedEx account Number
				,meter => '' #FedEx Meter Number (this is given after you subscribe to FedEx)
				,referer => 'Vermonster LLC' # Name or company
				,host=> 'gatewaybeta.fedex.com' #Host
				,Debug=>1
				);

$t->set_data(5000, 29 =>'790913902411') or die $t->errstr;

$t->transaction or die $t->errstr;


my $stuff= $t->hash_ret;

foreach (keys %{$stuff}) {
	print $_. ' => ' . $stuff->{$_} . "\n";
}

print $t->lookup('signed_for');
