use Business::FedEx::DirectConnect;

my $t = Business::FedEx::DirectConnect->new(uri=>'https://gatewaybeta.fedex.com/GatewayDC'
	,acc => '248904968' #FedEx Account Number
	,meter => '1147026' #FedEx Meter Number (This is given after you subscribe to FedEx)
	,referer => 'Vermonster LLC' # Name or Company
	,host=> 'gatewaybeta.fedex.com' #Host
	);

$t->set_data(5000,29 =>'836603877972') or die $t->errstr;

$t->transaction() or die $t->errstr;

print $t->lookup('signed_for');