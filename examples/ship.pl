#!/usr/bin/perl -w
#$Id: ship.pl,v 1.5 2003/06/18 17:09:39 jay.powers Exp $
use strict;
use Business::FedEx::DirectConnect;

my $t = Business::FedEx::DirectConnect->new(uri=>'https://gatewaybeta.fedex.com/GatewayDC'
                                ,acc => '' #FedEx Account Number
                                ,meter => '' #FedEx Meter Number (This is given after you subscribe to FedEx)
                                ,referer => 'Vermonster' # Name or Company
                                ,host=> 'gatewaybeta.fedex.com' #Host
                                ,Debug => 1
                                );

# 2016 is the UTI for FedEx.  If you don't know what this is
# you need to read the FedEx Documentation.
# http://www.fedex.com/globaldeveloper/shipapi/
# The hash values are case insensitive.
$t->set_data(2016,
'sender_company' => 'Vermonster LLC',
'sender_address_line_1' => '312 stuart st',
'sender_city' => 'Boston',
'sender_state' => 'MA',
'sender_postal_code' => '02134',
'recipient_contact_name' => 'Jay Powers',
'recipient_address_line_1' => '44 Main street',
'recipient_city' => 'Boston',
'recipient_state' => 'MA',
'recipient_postal_code' => '02116',
'recipient_phone_number' => '6173335555',
'weight_units' => 'LBS',
'sender_country_code' => 'US',
'recipient_country' => 'US',
'sender_phone_Number' => '6175556985',
'packaging_type' => '01',
'service_type' => '03',
'total_package_weight' => '1.0',
'label_type' => '1',
'label_printer_type' => '1',
'label_media_type' => '1',
'drop_off_type' => '1'
) or die $t->errstr;

$t->transaction() or die $t->errstr;

print $t->lookup('tracking_number');

$t->label("myLabel.png");