# FedEx::Constants
#
# Copyright (c) 2002 Jay Powers
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself
package Business::FedEx::Constants;

use strict;
require Exporter;
use vars qw(@ISA @EXPORT $VERSION);

@ISA = ('Exporter');
@EXPORT = qw($FE_ER $FE_RE $FE_SE $FE_TT $FE_RQ);
$VERSION = '0.02'; # $Id: Constants.pm,v 1.1.1.1 2002/08/29 17:12:10 jay.powers Exp 

# Here are all the UTI codes from FedEx
#1002 = 007 / 107 FDXG End-of-day close
#1005 = 023 / 123 FDXE FedEx Express Delete-A-Package
#2016 = 021 / 121 FDXE FedEx Express Ship-A-Package
#2017 = 022 / 122 FDXE Global Rate-A-Package
#2018 = 019 / 119 FDXE Service Availability
#3000 = 021 / 121 FDXG FedEx Ground Ship-A-Package
#3001 = 023 / 123 FDXG FedEx Ground Delete-A-Package
#3003 = 211 / 311 ALL Subscription
#3004 = 022 / 122 FDXG Global Rate-A-Package
#5000 = 402 / 502 ALL Track By Number, Destination, Ship Date, and Reference
#5001 = 405/505 ALL Signature Proof of Delivery
our $FE_TT = {
1002 => ['007','FDXG'],
1005 => ['023','FDXE'],
2016 => ['021','FDXE'],
2017 => ['022','FDXE'],
2018 => ['019','FDXE'],
3000 => ['021','FDXE'],
3001 => ['023','FDXG'],
3003 => ['211',''],
5000 => ['402',''],
5001 => ['405','']
};

our $FE_RQ = {
2018 => [0,10,498,3025,47,9,17,50,24],
2017 => [0,10,498,3025,8,9,117,16,17,50,75,1274,1401,1333],
2016 => [0,10,498,3025,5,7,8,9,32,117,183,13,18,50,24,68,23,1273,1401,1333],
1005 => [0,10,498,3025,29],
1002 => [0,10,498,3025,1007,1366],
3003 => [0,10,4003,4008,4011,4012,4013,4014,4015],
5000 => [0,10,498,3025,24,29],
5001 => [0,10,498,3025,24,29]
};

our $FE_ER = {
0 => 'API_OK',
-1 => 'API_SUCCESS',
-8 => 'API_NOT_INIT_ERROR',# FedExAPIClient.dll was not initialized.
-24 => 'API_INIT_ERROR',# Error trying to initialize FedExAPIClient.dll
-2201 => 'API_UNKNOWN_HOST_EXCEPTION',# Invalid IP Address. Insure the IP Address for ATOM is correct.
-2202 => 'API_UNABLE_TO_OPEN_SOCKET',# Invalid IP Address or port for the ATOM you are trying to connect with, or the ATOM you are trying to connect with is not running.
-2203 => 'API_SET_TIMEOUT_FAILED',# Setting the read timeout you requested failed. Check your timeout value.
-2204 => 'API_UNABLE_TO_OPEN_OUTPUTSTREAM',# Unable to obtain resources necessary for communicating with the server. Try closing some applications.
-2205 => 'API_UNABLE_TO_OPEN_INPUTSTREAM',# Unable to obtain resources necessary for communicating with the server. Try closing some applications.
-2206 => 'API_ERROR_READING_REPLY',# The connection to FedEx timed out before receiving all of the reply.
-2207 => 'API_ERROR_READING_HEADER',# The connection to FedEx closed before receiving any of the reply. This could also result from a timeout.
-2208 => 'API_ERROR_READING_INPUT',# Contact FedEx.
-2209 => 'API_ENCODING_EXCEPTION',# Contact FedEx.
-2210 => 'API_UNKNOWN_HOST_EXCEPTION_CLIENT',# Unable to determine the IP Address of this system
-2211 => 'API_HEADER_INTERPRETATION_ERROR',# Invalid data received in reply.
-2212 => 'API_ZERO_LENGTH_REPLY',# The reply contained no data.
-2213 => 'API_CLIENT_REPLY_BUFFER_TOO_SHORT',# The buffer for returning the reply is not large enough to contain the entire reply.
-2214 => 'API_ERROR_INVALID_STATUS',# The reply contained invalid data.
-2215 => 'API_ERROR_SENDING_REQUEST',# The communications channel may have been inadvertently closed.
-2217 => 'API_THREAD_INTERRUPTED_EXCEPTION',# The transaction thread was interrupted before it finished. X -
-2220 => 'API_REQUEST_CONTAINED_NO_DATA',# Unable to close socket handle.
-2221 => 'API_UNABLE_TO_CLOSE_SOCKET',# Unable to destroy socket handle.
-2222 => 'API_ATOM_ADMIN_PORT_TOO_HIGH',# An attempt was made to set Atom�s Admin port to a value greater than 65535.
-2223 => 'API_ATOM_ADMIN_PORT_TOO_LOW',# An attempt was made to set Atom�s Admin port to a value less than 0.
-2224 => 'API_UNABLE_TO_DESTROY_SOCKET',# Unable to destroy socket handle.
-2256 => 'API_NOT_INSTALLED',# API is not installed.
-3000 => 'GATEWAY_DOWN', #The FedEx Gateway is down. Try again later.
-3001 => 'GATEWAY_COMM_ERROR', #The FedEx Gateway tried to communicate with a server which is down or the transaction contained no data.
-3002 => 'GATEWAY_VALIDATION_ERROR', #The FedEx Gateway could not validate this transaction.
-3003 => 'GATEWAY_XCTN_NOT_RECOGNIZED', #The FedEx Gateway received an invalid transaction.
-3004 => 'GATEWAY_ACCESS_DENIED', #The FedEx Gateway denied access for this transaction.
-3005 => 'GATEWAY_USERID_NOT_FOUND', #The FedEx Gateway could not validate the user id for this transaction.
-3006 => 'GATEWAY_DATA_FORMAT_ERROR', #The transaction format is invalid.
-3007 => 'GATEWAY_UNKNOWN_ROUTE_ID' #The Universal Transaction Identifier (Route ID) was unknown to the FedEx Gateway.
};


our $FE_RE = {
0 => 'transaction_code',
1 => 'customer_transaction_identifier',
2 => 'transaction_error_code',
3 => 'transaction_error_message',
4 => 'sender_company',
5 => 'sender_address_line_1',
6 => 'sender_address_line_2',
7 => 'sender_city',
8 => 'sender_state',
9 => 'sender_postal_code',
10 => 'sender_fedex_express_account_number',
11 => 'recipient_company',
12 => 'recipient_contact_name',
13 => 'recipient_address_line_1',
14 => 'recipient_address_line_2',
15 => 'recipient_city',
16 => 'recipient_state',
17 => 'recipient_postal_code',
18 => 'recipient_phone_number',
20 => 'payer_account_number',
23 => 'pay_type',
24 => 'ship_date',
25 => 'reference_information',
27 => 'cod_flag',
28 => 'cod_return_tracking_number',
29 => 'tracking_number',
30 => 'ursa_code',
32 => 'sender_contact_name',
33 => 'service_commitment',
38 => 'sender_department',
40 => 'alcohol_type',
41 => 'alcohol_packaging',
44 => 'hal_address',
46 => 'hal_city',
47 => 'hal_state',
48 => 'hal_postal_code',
49 => 'hal_phone_number',
50 => 'recipient_country',
51 => 'signature_release_ok_flag',
52 => 'alcohol_packages',
57 => 'dim_height',
58 => 'dim_width',
59 => 'dim_length',
65 => 'astra_barcode',
66 => 'broker_name',
67 => 'broker_phone_number',
68 => 'customs_declared_value_currency_type',
70 => 'duties_pay_type',
71 => 'duties_payer_account',
72 => 'terms_of_sale',
73 => 'parties_to_transaction',
74 => 'country_of_ultimate_destination',
75 => 'weight_units',
76 => 'commodity_number_of_pieces',
79 => 'description_of_contents',
80 => 'country_of_manufacturer',
81 => 'harmonized_code',
82 => 'unit_quantity',
83 => 'export_license_number',
84 => 'export_license_expiration_date',
113 => 'commercial_invoice_flag',
116 => 'package_total',
117 => 'sender_country_code',
118 => 'recipient_irs',
120 => 'ci_marks_and',
169 => 'importer_country',
170 => 'importer_name',
171 => 'importer_company',
172 => 'importer_address_line_1',
173 => 'importer_address_line_2',
174 => 'importer_city',
175 => 'importer_state',
176 => 'importer_postal_code',
177 => 'importer_account_number',
178 => 'importer_number_phone',
180 => 'importer_id',
183 => 'sender_phone_number',
186 => 'cod_add_freight_charges_flag',
188 => 'label_buffer_data_stream',
190 => 'document_pib_shipment_flag',
194 => 'delivery_day',
195 => 'destination',
198 => 'destination_location_id',
404 => 'commodity_license_exception',
409 => 'delivery_date',
411 => 'cod_return_label_buffer_data_stream',
413 => 'nafta_flag',
414 => 'commodity_unit_of_measure',
418 => 'ci_comments',
431 => 'dim_weight_used_flag',
439 => 'cod_return_contact_name',
440 => 'residential_delivery_flag',
496 => 'freight_service_commitment',
498 => 'meter_number',
526 => 'form_id',
527 => 'cod_return_form_id',
528 => 'commodity_eccn',
535 => 'cod_return',
536 => 'cod_return_service_commitment',
543 => 'cod_return_collect_plus_freight_amount',
557 => 'message_type_code',
558 => 'message_code',
559 => 'message_text',
600 => 'forwarding_agent_routed_export_transaction_indicator',
602 => 'exporter_ein_ssn_indicator',
603 => 'int-con_company_name',
604 => 'int-con_contact_name',
605 => 'int-con_address_line_1',
606 => 'int-con_address_line_2',
607 => 'int-con_city',
608 => 'int-con_state',
609 => 'int-con_zip',
610 => 'int-con_phone_number',
611 => 'int-con_country',
1005 => 'manifest_invoic_e_file_name',
1006 => 'domain_name',
1007 => 'close_manifest_date',
1008 => 'package_ready_time',
1009 => 'time_companyclose',
1032 => 'duties_payer_country_code',
1089 => 'rate_scale',
1090 => 'rate_currency_type',
1092 => 'rate_zone',
1096 => 'origin_location_id',
1099 => 'volume_units',
1101 => 'payer_credit_card_number',
1102 => 'payer_credit_card_type',
1103 => 'sender_fax',
1104 => 'payer_credit_card_expiration_date',
1115 => 'ship_time',
1116 => 'dim_units',
1117 => 'package_sequence',
1118 => 'release_authorization_number',
1119 => 'future_day_shipment',
1120 => 'inside_pickup_flag',
1121 => 'inside_delivery_flag',
1123 => 'master_tracking_number',
1124 => 'master_form_id',
1137 => 'ursa_uned_prefix',
1139 => 'sender_irs_ein_number',
1145 => 'recipient_department',
1166 => 'deliver_to_cd',
1167 => 'disp_exception_cd',
1168 => 'status_exception_cd',
1169 => 'trackstatus_cd',
1170 => 'pod_status_cd',
1174 => 'bso_flag',
1178 => 'ursa_suffix_code',
1179 => 'broker_fdx_account_number',
1180 => 'broker_company',
1181 => 'broker_line_1_address',
1182 => 'broker_line_2_address',
1183 => 'broker_city',
1184 => 'broker_state',
1185 => 'broker_postal_code',
1186 => 'broker_country_code',
1187 => 'broker_id_number',
1193 => 'ship_delete_message',
1195 => 'payer_country_code',
1200 => 'hold_at_location_hal_flag',
1201 => 'senders_email_address',
1202 => 'recipient�s_email_address',
1203 => 'optional_ship_alert_message',
1204 => 'ship_alert_email_address',
1206 => 'ship_alert_notification_flag',
1208 => 'no_indirect_delivery_flag_signature_required',
1210 => 'purpose_of_shipment',
1211 => 'pod_address',
1212 => 'pod_status',
1213 => 'proactive_notification_flag',
1237 => 'cod_return_phone',
1238 => 'cod_return_company',
1239 => 'cod_return_department',
1240 => 'cod_return_address_1',
1241 => 'cod_return_address_2',
1242 => 'cod_return_city',
1243 => 'cod_return_state',
1244 => 'cod_return_postal_code',
1253 => 'packaging_list_enclosed_flag',
1265 => 'hold_at_location_contact_name',
1266 => 'saturday_delivery_flag',
1267 => 'saturday_pickup_flag',
1268 => 'dry_ice_flag',
1271 => 'shipper�s_load_and_count_slac',
1272 => 'booking_number',
1273 => 'packaging_type',
1274 => 'service_type',
1286 => 'exporter_ppi-_contact_name',
1287 => 'exporter_ppi-company_name',
1288 => 'exporter_ppi-address_line_1',
1289 => 'exporter_ppi-address_line_2',
1290 => 'exporter_ppi-city',
1291 => 'exporter_ppi-state',
1292 => 'exporter_ppi-zip',
1293 => 'exporter_ppi-country',
1294 => 'exporter_ppi-phone_number',
1295 => 'exporter_ppi-ein_ssn',
1297 => 'customer_invoice_number',
1300 => 'purchase_order_number',
1331 => 'dangerous',
1332 => 'alcohol_flag',
1333 => 'drop_off_type',
1337 => 'package_content_information',
1341 => 'sender_pager_number',
1342 => 'recipient_pager_number',
1343 => 'broker_email_address',
1344 => 'broker_fax_number',
1349 => 'aes_filing_status',
1350 => 'xtn_suffix_number',
1352 => 'sender_ein_ssn_identificator',
1358 => 'aes_ftsr_exemption_number',
1366 => 'close_manifest_time',
1367 => 'close_manifest_data_buffer',
1368 => 'label_type',
1369 => 'label_printer_type',
1370 => 'label_media_type',
1371 => 'manifest_only_request_flag',
1372 => 'manifest_total',
1376 => 'rate_weight_unit_of_measure',
1377 => 'dim_weight_unit_of_measure',
1391 => 'client_revision_indicator',
1392 => 'inbound_visibility_block_shipment_data_indicator',
1394 => 'shipment_content_records_total',
1395 => 'part_number',
1396 => 'sku_item_upc',
1397 => 'receive_quantity',
1398 => 'description',
1401 => 'total_package_weight',
1402 => 'billed_weight',
1403 => 'dim_weight',
1404 => 'total_volume',
1405 => 'alcohol_volume',
1406 => 'dry_ice_weight',
1407 => 'commodity_weight',
1408 => 'commodity_unit_value',
1409 => 'cod_amount',
1410 => 'commodity_customs_value',
1411 => 'total_customs_value',
1412 => 'freight_charge',
1413 => 'insurance_charge',
1414 => 'taxes_miscellaneous_charge',
1415 => 'declared_value_carriage_value',
1416 => 'base_rate_amount',
1417 => 'total_surcharge_amount',
1418 => 'total_discount_amount',
1419 => 'net_charge_amount',
1420 => 'total_rebate_amount',
1450 => 'more_data_indicator',
1451 => 'sequence_number',
1452 => 'last_tracking_number',
1453 => 'track_reference_type',
1454 => 'track_reference',
1456 => 'spod_type_request',
1458 => 'spod_fax_recipient_name',
1459 => 'spod_fax_recipient_number',
1460 => 'spod_fax_sender_name',
1461 => 'spod_fax_sender_phone_number',
1462 => 'language_indicator',
1463 => 'spod_fax_recipient_company_name_mail',
1464 => 'spod_fax_recipient_address_line_1_mail',
1465 => 'spod_fax_recipient_address_line_2_mail',
1466 => 'spod_fax_recipient_city_mail',
1467 => 'spod_fax_recipient_state_mail',
1468 => 'spod_fax_recipient_zip_postal_code_mail',
1469 => 'spod_fax_recipient_country_mail',
1470 => 'spod_fax_confirmation',
1471 => 'spod_letter',
1472 => 'spod_ground_recipient_name',
1473 => 'spod_ground_recipient_company_name',
1474 => 'spod_ground_recipient_address_line_1',
1475 => 'spod_ground_recipient_address_line_2',
1476 => 'spod_ground_recipient_city',
1477 => 'spod_ground_recipient_state_province',
1478 => 'spod_ground_recipient_zip_postal_code',
1479 => 'spod_ground_recipient_country',
1480 => 'more_information',
1701 => 'track_status',
1702 => 'proof_of_delivery_flag',
1704 => 'service_type_description',
1705 => 'deliver_to',
1706 => 'signed_for',
1707 => 'delivery_time',
1709 => 'disp_exception',
1710 => 'cartage_agent',
1711 => 'status_exception',
1713 => 'cod_flag',
1715 => 'number_of_track_activities',
1718 => 'packaging_alpha_type_description',
1720 => 'delivery_date',
1721 => 'tracking_activity_line_1',
1722 => 'tracking_activity_line_2',
1723 => 'tracking_activity_line_3',
1724 => 'tracking_activity_line_4',
1725 => 'tracking_activity_line_5',
1726 => 'tracking_activity_line_6',
1727 => 'tracking_activity_line_7',
1728 => 'tracking_activity_line_8',
1729 => 'tracking_activity_line_9',
1730 => 'tracking_activity_line_10',
1731 => 'tracking_activity_line_11',
1732 => 'tracking_activity_line_12',
1733 => 'tracking_activity_line_13',
1734 => 'tracking_activity_line_14',
1735 => 'tracking_activity_line_15',
2254 => 'recipient_fax_number',
3000 => 'cod_type_collection',
3001 => 'fedex_ground_purchase_order',
3002 => 'fedex_ground_invoice',
3003 => 'fedex_ground_customer_reference',
3008 => 'autopod_flag',
3009 => 'aod_flag',
3010 => 'oversize_flag',
3011 => 'other_oversize_flag',
3018 => 'nonstandard_container_flag',
3019 => 'fedex_signature_home_delivery_flag',
3020 => 'fedex_home_delivery_type',
3023 => 'fedex_home_delivery_date',
3024 => 'fedex_home_delivery_phone_number',
3025 => 'carrier_code',
3045 => 'cod_return_reference_indicator',
4003 => 'subscriber_contact_name',
4004 => 'subscriber_password_reminder',
4007 => 'subscriber_company_name',
4008 => 'subscriber_address_line_1',
4009 => 'subscriber_address_line_2',
4011 => 'subscriber_city_name',
4012 => 'subscriber_state_code',
4013 => 'subscriber_postal_code',
4014 => 'subscriber_country_code',
4015 => 'subscriber_phone_number',
4017 => 'subscriber_pager_number',
4018 => 'subscriber_email_address',
4021 => 'subscription_service_name',
4022 => 'subscriber_fax_number'
};
## Better to reverse this hash when sending data to FedEx
our $FE_SE;
foreach (keys %$FE_RE) {
	$FE_SE->{$FE_RE->{$_}} = $_;
}
1;
__END__

=head1 NAME

Business::Fedex::Constants - FedEx Lookup Codes 

=head1 DESCRIPTION

This module holds all the return codes need by FedEx.

=head1 EXPORT

$FE_ER $FE_RE $FE_SE $FE_TT $FE_RQ

=head1 AUTHORS

Jay Powers, jay@vermonster.com

L<http://www.vermonster.com/perl>

Copyright (c) 2002 Jay Powers

All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself

If you have any questions, comments or suggestions please feel free 
to contact me.

=head1 SEE ALSO

perl(1).

=cut
