use Business::FedEx::Directconnect;

my $t = Business::FedEx::Directconnect->new(uri=>'https://gatewaybeta.fedex.com/GatewayDc'
				,acc => '' #FedEx account Number
				,meter => '' #FedEx Meter Number (this is given after you subscribe to FedEx)
				,referer => 'Vermonster LLC' # Name or company
				,host=> 'gatewaybeta.fedex.com' #Host
				);

# 2016 is the UTI for FedEx.  If you don't know what this is
# you need to read the FedEx Documentation.
# http://www.fedex.com/globaldeveloper/shipapi/
# The hash values are case insensitive.
$t->set_data(2016,
'sender_company' => 'Vermonster LLC',
'sender_address_line_1' => '312 stuart st',
'sender_city' => 'Boston',
'sender_state' => 'Ma',
'sender_postal_code' => '02134',
'recipient_contact_Name' => 'Jay Powers',
'recipient_address_line_1' => '44 Main street',
'recipient_city' => 'Boston',
'recipient_state' => 'Ma',
'recipient_postal_code' => '02116',
'recipient_phone_Number' => '6173335555',
'weight_units' => 'lBs',
'sender_country_code' => 'US',
'recipient_country' => 'US',
'sender_phone_Number' => '6175556985',
'future_day_shipment' => 'Y',
'packaging_type' => '01',
'service_type' => '03',
'total_package_weight' => '1.0',
'label_type' => '1',
'label_printer_type' => '1',
'label_media_type' => '5',
'ship_date' => '20020828',
'customs_declared_value_currency_type' => 'USD',
'package_total' => 1
) or die $t->errstr;

$t->transaction() or die $t->errstr;

$t->label("mylabel.png");
