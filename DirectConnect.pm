# FedEx::DirectConnect
#
# Copyright (c) 2002 Jay Powers
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself

package Business::FedEx::DirectConnect; #must be in Business/FedEx

use Business::FedEx::Constants qw($FE_ER $FE_RE $FE_SE $FE_TT $FE_RQ); # get all the FedEx return codes
use LWP::UserAgent;

$VERSION = '0.03'; # $Id: DirectConnect.pm,v 1.1.1.1 2002/09/10 13:14:10 jay.powers Exp 

use strict;

use vars qw($VERSION);

sub new {
	my $name = shift;	
	my $class = ref($name) || $name;
	my $self  = { 
				 uri=>'https://gatewaybeta.fedex.com/GatewayDC'
				,acc => ''
				,meter => ''
				,referer => ''
				,host=> 'gatewaybeta.fedex.com'
				,Debug=>0
				,@_ };
	bless ($self, $class);
}
# Send a call to FedEx
sub transaction {
	my $self = shift;
	if (@_) {
		$self->{sbuf} = shift;
	}
	if ($self->{UTI} eq '') { # Find the UTI
		my $tmp = $self->{sbuf};
		$tmp =~ s/0,"([0-9]*).*"/$1/;
		for my $utis (keys %$FE_TT) {
			 for (@{%$FE_TT->{$utis}}) {
				$self->{UTI} = $utis if ($_ eq $tmp);
			 }
		}
	}
	if (!$self->{sbuf}) {		
			$self->errstr("Error: You must provide data to send to FedEx.");
			return 0;
	}
	print "Sending ". $self->{sbuf} . "\n" if ($self->{Debug});
	my $bufferLength = length($self->{sbuf});
	use LWP::UserAgent;
	my $ua = LWP::UserAgent->new;
	my $len = length($self->{sbuf});
	
	# Create a request
	my $req = HTTP::Request->new(POST => $self->{uri});
	$req->header('Host' => $self->{host}
	,'Referer' => $self->{referer}
	,'Accept' => "image/gif,image/jpeg,image/pjpeg,text/plain,text/html,*/*"
	,'Content-Type' => "image/gif"
	,'Content-Length' => $bufferLength);
	$req->content($self->{sbuf});
	print $req->as_string() if ($self->{Debug});
	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);	
	# Check the outcome of the response
	if ($res->is_success) {
		$self->{rbuf} = $res->content;
	} else {
		$self->errstr("Request Error: " . $res->status_line);
		return 0;
	}
	$self->{rbuf} =~ s/\s+$//g; # get rid of the extra spaces
	$self->_split_data();
	# Check for Errors from FedEx
	if ($self->{rHash}->{transaction_error_code}) {
		$self->errstr("FedEx Transaction Error: " . $self->{rHash}->{transaction_error_message});
		return 0;
	}
	return 1;
}

sub set_data {
	my $self = shift;
	$self->{UTI} = shift;
	my %args = @_;
	if (!$self->{UTI}) {		
		$self->errstr("Error: You must provide a valid UTI.");
		return 0;
	}
	$self->{sbuf} = '';
	$self->{sbuf} .= '0,"' . $FE_TT->{$self->{UTI}}[0] . '"' if ($FE_TT->{$self->{UTI}}[0]);
	$self->{sbuf} .= '3025,"' . $FE_TT->{$self->{UTI}}[1].'"' if ($FE_TT->{$self->{UTI}}[1]);
	$self->{sbuf} .= '10,"' . $self->{acc} . '"' if ($self->{acc});
	$self->{sbuf} .= '498,"' .$self->{meter}. '"' if ($self->{meter});	
	foreach (keys %args) {
		#print $FE_SE->{lc($_)}. "\n";
		if (/^[0-9]+$/) { #let users use the number fields
			$self->{sbuf} .= join(',',$_,'"'.$args{$_}.'"');
		} else {
			$self->{sbuf} .= join(',',$FE_SE->{lc($_)},'"'.$args{$_}.'"');
		}
	}
	$self->{sbuf} .= '99,""';
	return $self->{sbuf};
}

# here are some functions to deal with data from FedEx
sub _split_data {
	my $self = shift;
	my $count=0;
	my @field_data;
	($self->{rstring}, $self->{rbinary}) = split("188,\"", $self->{rbuf});
	$self->{rstring} =~ s/\s{2,}/ /g; # get rid of any extra spaces
	# Thank PTULLY for this.
	my @fedex_response = split(//, $self->{rstring});
	foreach(@fedex_response){
	   $field_data[$count] = $field_data[$count].$_;
	   if($field_data[$count] =~ /\d+,\".*\"$/){
			$count++;
	 }
	}
	print "Return String " . $self->{rstring} . "\n" if ($self->{Debug});
	foreach (@field_data) 
	{
		/([0-9]+),\"(.*)\"/; 
		#print $1 ." = " . $2 . "\n";
		$self->{rHash}->{$1} = $2 if ($1);
	}
}

# array of all the required fields
sub required {
	my $self = shift;
	my $uti = shift;
	my @req;
	foreach (@{%$FE_RQ->{$uti}}) {
		push @req, $FE_RE->{$_};
	}
	return @req;
}
# print or create a label
sub label {
	my $self = shift;
	$self->{rbinary} =~ s/"99.*$// if ($self->{rbinary}); #"
	$self->{rbinary} =~ s/\%([0-9][0-9])/chr(hex("0x$1"))/eg if ($self->{rbinary});	
	if (@_) {
		my $file = shift;
		open(FILE, ">$file") or  die "Could not open $file:\n$!";
		binmode(FILE);
		print FILE $self->{rbinary};
		close(FILE);
		return 1;
	} else {
		return $self->{rbinary};
	}
}
#look up a value
sub lookup {
	my $self = shift;
	my $code = shift;
	if ($code =~ m/^[0-9]+$/) {
		print "Looking for " . $code if ($self->{Debug});
		return $self->{rHash}->{$code};
	} else {
		print "Looking for " . lc($code) if ($self->{Debug});
		return $self->{rHash}->{$FE_SE->{lc($code)}};
	}
}
# All the data from FedEx
sub rbuf {
	my $self = shift;
	$self->{rbuf} = shift if @_;
	return $self->{rbuf};
}
# Build a hash from the return data from FedEx
sub hash_ret {
	my $self = shift;
	return $self->{rHash};
}

sub errstr { 
	my $self = shift;
	$self->{errstr} = shift if @_;
	return $self->{errstr};
}
1;
__END__

=head1 NAME

Business::Fedex::DirectConnect - FedEx Ship Manager Direct Connect

=head1 SYNOPSIS

  use Business::FedEx::DirectConnect;
  
  my $t = Business::FedEx::DirectConnect->new(uri=>'https://gatewaybeta.fedex.com/GatewayDC'
  				,acc => '' #FedEx Account Number
  				,meter => '' #FedEx Meter Number (This is given after you subscribe to FedEx)
  				,referer => 'Vermonster' # Name or Company
  				,host=> 'gatewaybeta.fedex.com' #Host
  				);
  
  # 2016 is the UTI for FedEx.  If you don't know what this is
  # you need to read the FedEx Documentation.
  # http://www.fedex.com/globaldeveloper/shipapi/
  # The hash values are case insensitive.
  $t->set_data(2016,
  'customer_transaction_identifier' => 'unique1234'
  'Sender_Company' => 'Vermonster LLC',
  'Sender_Address_Line_1' => '312 Stuart St',
  'Sender_City' => 'Boston',
  'Sender_State' => 'MA',
  'Sender_Postal_Code' => '02134',
  'Recipient_Contact_Name' => 'Jay Powers',
  'Recipient_Address_Line_1' => '44 Main Street',
  'Recipient_City' => 'Boston',
  'Recipient_State' => 'MA',
  'Recipient_Postal_Code' => '02116',
  'Recipient_Phone_Number' => '6173335555',
  'Weight_Units' => 'LBS',
  'Sender_Country_Code' => 'US',
  'Recipient_Country' => 'US',
  'Sender_Phone_Number' => '6175556985',
  'Future_Day_Shipment' => 'Y',
  'Packaging_Type' => '01',
  'Service_Type' => '03',
  'Total_Package_Weight' => '1.0',
  'Label_Type' => '1',
  'Label_Printer_Type' => '1',
  'Label_Media_Type' => '5',
  'Ship_Date' => '20020828',
  'Customs_Declared_Value_Currency_Type' => 'USD',
  'Package_Total' => 1
  ) or die $t->errstr;
  
  $t->transaction() or die $t->errstr;
  
  print $t->lookup('tracking_number');

  $t->label("myLabel.png");


=head1 DESCRIPTION

This module is an alternative to using the FedEx Ship Manager API.  
Business::FedEx::DirectConnect will provide the necessary communication using LWP and 
Crypt::SSLeay.
The main advantage is you will no longer need to install the JRE dependant API 
provided by FedEx.  Instead, data is POST(ed) directly to the FedEx transaction servers.
Additionally, Business::FedEx::DirectConnect allows full "non-Win32" functionality. In the 
previous version, non-windows users had to proxy to a windows box.

=head1 REQUIREMENTS

In order to submit a transaction to FedEx's Gateway server you must have a valid
FedEx Account Number an other unique identifier and a FedEx Meter Number.  To gain access
and receive a Meter Number you must send a Subcribe request to FedEx containing you FedEx
account number and contact information. 
This module uses LWP to POST this information so it is a requirement to have LWP installed.  
Also, you will need a SSL encrytion.  I recomend installing Crypt::SSLeay 
Please refer to the FedEx documentation at http://www.fedex.com/globaldeveloper/shipapi/
Here you will find more information about using the FedEx API.  You will need to know
what UTI to use to send a request.

Here is a sample Subscription Transaction

	$t->set_data(3003,
	1 => 'unique12345',
	4003 => 'John Doe',
	4008 => '123 Main St',
	4011 => 'Boston',
	4012 => 'MA',
	4013 => '02116',
	4014 => 'US',
	4015 => '6175551111',
	) or die $t->errstr;


This call will return a FedEx Meter number so you can use the test server.

=head1 FedEx UTI

Sited from FedEx Documentation.  See http://www.fedex.com/globaldeveloper/shipapi/
for more information.

"The Universal Transaction Identifier (UTI) is a unique integral code that 
has been assigned to a given transaction type. For example, the UTI of the tagged 
Transaction Type "021" (FedEx Express global Ship a Package Request) is 2016.
UTIs are unique not just within the tagged transaction set, but across all transaction 
sets that have been or will be approved for transmission via the API.
The UTI accompanying a transaction indicates where it should be routed within the FedEx 
systems. The FedEx server recognizes the UTI passed and will direct the request
to the correct business server."

Valid UTIs are listed below:

uti  = request / reply Carrier Description 

	1002 = 007 / 107 FDXG End-of-day close
	1005 = 023 / 123 FDXE FedEx Express Delete-A-Package
	2016 = 021 / 121 FDXE FedEx Express Ship-A-Package
	2017 = 022 / 122 FDXE Global Rate-A-Package
	2018 = 019 / 119 FDXE Service Availability
	3000 = 021 / 121 FDXE FedEx Ground Ship-A-Package
	3001 = 023 / 123 FDXG FedEx Ground Delete-A-Package
	3003 = 211 / 311 ALL Subscription
	3004 = 022 / 122 FDXG Global Rate-A-Package
	5000 = 402 / 502 ALL Track By Number, Destination, Ship Date, and Reference
	5001 = 405 / 505 ALL Signature Proof of Delivery


=head1 COMMON METHODS

The methods described in this section are available for all C<FedEx::DirectConnect> objects.

=over 4

=item $t->set_data(UTI, $hash)

This method will accept a valid FedEx UTI number and a hash of values.  The first
arg must be a valid UTI. Using these values set_data will construct and return a 
valid FedEx request string.
Assuming you pass in a valid FedEx UTI this method will find the correct
Transaction Number for you.  You need not pass this in.  Also no need to pass in your
FedEx Account Number or Meter Number.  You should pass these when creating a new 
Business::FedEx::DirectConnect object.
This method will allow you to use either the number field provided in the FedEx 
documentation or the hash (case insensitive) $FE_RE found in FedEx::Constants.

Here is a tracking example where 29 is "tracking number" field FedEx has
provided.

	$t->set_data(5000, 'tracking_number'=>'836603877972') or die $t->errstr;

is the same as

	$t->set_data(5000, 29 =>'836603877972') or die $t->errstr;

=item $t->required(UTI)

Method to return the required fields for a given FedEx UTI.

=item $t->transaction()

Send transaction to FedEx.  Returns the full reply from FedEx

=item $t->label('someLabel.png')

This method will decode the binary image data from FedEx.  If nothing
is passed in the binary data string will be returned.

=item $t->lookup('tracking_number')

This method will return the value for an item returned from FedEx.  Refer to
the C<FedEx::Constants> $FE_RE hash to see all possible values. 

=item $t->rbuf()

Returns the undecoded string portion of the FedEx reply.

=item $t->hash_ret()

Returns a hash of the FedEx reply values

	my $stuff= $t->hash_ret;

	foreach (keys %$stuff) {
		print $_. ' => ' . $stuff->{$_} . "\n";
	}

=back

=head1 AUTHOR

Jay Powers, <F<jay@vermonster.com>>

L<http://www.vermonster.com/perl>

Copyright (c) 2002 Jay Powers

All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself

If you have any questions, comments or suggestions please feel free 
to contact me.

=head1 SEE ALSO

C<Business::FedEx::Constants>

=cut
