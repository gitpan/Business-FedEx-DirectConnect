# FedEx::DirectConnect
#$Id: DirectConnect.pm,v 1.13 2003/06/18 17:09:20 jay.powers Exp $
# Copyright (c) 2003 Jay Powers
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself

package Business::FedEx::DirectConnect; #must be in Business/FedEx

use Business::FedEx::Constants qw($FE_RE $FE_SE $FE_TT $FE_RQ); # get all the FedEx return codes
use LWP::UserAgent;

$VERSION = '0.16';

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

sub set_data {
	my $self = shift;
	$self->{UTI} = shift;
	my %args = @_;
	if (!$self->{UTI}) {		
		$self->errstr("Error: You must provide a valid UTI.");
		return undef;
	}
	$self->{sbuf} = '';
	$self->{sbuf} .= '0,"' . $FE_TT->{$self->{UTI}}[0] . '"' if ($FE_TT->{$self->{UTI}}[0]);
	$self->{sbuf} .= '3025,"' . $FE_TT->{$self->{UTI}}[1].'"' if ($FE_TT->{$self->{UTI}}[1]);
	$self->{sbuf} .= '10,"' . $self->{acc} . '"' if ($self->{acc});
	$self->{sbuf} .= '498,"' .$self->{meter}. '"' if ($self->{meter});	
	foreach (keys %args) {
		if (/^[0-9]+\-?\d?$/) { #let users use the hyphenated number fields
			$self->{sbuf} .= join(',',$_,'"'.$args{$_}.'"') if exists $FE_RE->{$_};
		} else {
			$self->{sbuf} .= join(',',$FE_SE->{lc($_)},'"'.$args{$_}.'"') if exists $FE_SE->{lc($_)};
		}
	}
	$self->{sbuf} .= '99,""';
	return $self->{sbuf};
}

# Send a call to FedEx
sub transaction {
	my $self = shift;
	if (@_) {
		$self->{sbuf} = shift;
	}
	if (!exists $self->{UTI}) { # Find the UTI
		my $tmp = $self->{sbuf};
		$tmp =~ s/0,"([0-9]+).+"/$1/;
		for my $utis (keys %{$FE_TT}) {
			 for (@{$FE_TT->{$utis}}) {
				$self->{UTI} = $utis if ($_ eq $tmp);
			 }
		}
	}
	if (!$self->{sbuf}) {
		$self->errstr("Error: You must provide data to send to FedEx.");
		return undef;
	}
	if (!$self->{acc}) {
		$self->errstr("Error: You must provide a valid FedEx account number.");
		return undef;
	}
	if (!$self->{meter}) {
		$self->errstr("Error: You must provide a valid FedEx meter number.");
		return undef;
	}

	if ($self->_send())	{ # send POST to FedEx
		$self->{rbuf} =~ s/\s+$//g if ($self->{rbuf} =~ /\s+$/); # get rid of the extra spaces
		$self->_split_data();
		# Check for Errors from FedEx
		if (exists $self->{rHash}->{2}) {
			$self->errstr("FedEx Transaction Error: " . $self->{rHash}->{3});
			return undef;
		}
                return 1;
	} else {
	        return undef;
	}
}


# Send POST request to FedEx API
sub _send {	
    my $self = shift;
	my $ua = LWP::UserAgent->new(timeout => 10);
	my $len = length($self->{sbuf});
	print "Sending ". $self->{sbuf} . "\n" if ($self->{Debug});
	my $bufferLength = length($self->{sbuf});
	my $req = HTTP::Request->new(POST => $self->{uri}); # Create a request
	$req->header('Host' => $self->{host}
	,'Referer' => $self->{referer}
	,'User-Agent' => 'Business-FedEx-DirectConnect-'.$VERSION
	,'Accept' => "image/gif,image/jpeg,image/pjpeg,text/plain,text/html,*/*"
	,'Content-Type' => "image/gif"
	,'Content-Length' => $bufferLength);
	$self->{sbuf} .= '99,""' unless ($self->{sbuf} =~ /99,\"\"$/);
	$req->content($self->{sbuf});
	print $req->as_string() if ($self->{Debug});
	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);
	# Check the outcome of the response
	if ($res->is_success) {
		$self->{rbuf} = $res->content;
		return 1;
	} else {
		$self->errstr("Request Error: " . $res->status_line);
		return undef;
	}
}

# here are some functions to deal with data from FedEx
sub _split_data {
	my $self = shift;
	my $count=0;
	my @field_data;
	($self->{rstring}, $self->{rbinary}) = split("188,\"", $self->{rbuf});
	print "Return String " . $self->{rstring} . "\n" if ($self->{Debug});
	my $st_key = 0;	# start the first key at 0
	foreach (split(/,"/, $self->{rstring})) {
		/(.*)"([0-9]+\-?\d?)/s; # allows for FedEx values with dashes. Added by JTER
		next unless defined $1;
		next if ($st_key == 99);
		$self->{rHash}->{$st_key} = $1;
		$st_key = $2; #use this as next key
	}
}


# array of all the required fields
sub required {
	my $self = shift;
	my $uti = shift;
	my @req;
	foreach (@{$FE_RQ->{$uti}}) {
		push @req, $FE_RE->{$_};
	}
	return @req;
}
# print or create a label
sub label {
	my $self = shift;
	$self->{rbinary} =~ s/"99.*$// if ($self->{rbinary}); #" Comment for color
	$self->{rbinary} =~ s/\%([0-9][0-9])/chr(hex("0x$1"))/eg if ($self->{rbinary});	
	if (@_) {
		my $file = shift;
		open(FILE, ">$file") or die "Could not open $file:\n$!";
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
	if ($code =~ m/^[0-9]+\-?\d?$/) {
		print "Looking for " . $code . "\n" if ($self->{Debug});
		return $self->{rHash}->{$code};
	} else {
		print "Looking for " . lc($code) . "\n" if ($self->{Debug});
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

Business::FedEx::DirectConnect - FedEx Ship Manager Direct Connect

=head1 SYNOPSIS

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
        'recipient_state' => 'Ma',
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


=head1 DESCRIPTION

This module provides the necessary means to send transactions to FedEx's
Ship Manager Direct API.  Precautions have been taken to enforce FedEx's API guidelines
to allow for all transaction types.
This module is an alternative to using the FedEx Ship Manager API ATOM product.
Business::FedEx::DirectConnect will provide the same communication using LWP and
Crypt::SSLeay.
The main advantage is you will no longer need to install the JRE dependant API
provided by FedEx.  Instead, data is POST(ed) directly to the FedEx transaction servers.

When using this module please keep in mind FedEx will occasionally change some of the 
transaction codes for their API.  This should not break existing code, but it is a good idea 
to check out changes when possible.  I document all the changes in a "Changes" log.

=head1 REQUIREMENTS

To submit a transaction to FedEx's Gateway server you must have a valid
FedEx Account Number and a FedEx Meter Number.  To gain access
and receive a Meter Number you must send a Subscribe () request to FedEx containing your FedEx
account number and contact information.  There is an example of this request below.
FedEx has two API servers a live one (https://gateway.fedex.com/GatewayDC) and a 
beta for testing (https://gatewaybeta.fedex.com/GatewayDC).
You will need to subscribe to each server you intend to use.  FedEx will also require you
to send a batch of defined data to their live server in order to become certified for live 
label creation.  
This module uses LWP to POST request information so it is a requirement to have LWP installed.  
Also, you will need SSL encryption to access https URIs.  I recommend installing Crypt::SSLeay 
Please refer to the FedEx documentation at http://www.fedex.com/globaldeveloper/shipapi/
Here you will find more information about using the FedEx API.  You will need to know
what UTI is needed to send your request.

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


This call will return a FedEx Meter number so you can use the FedEx API.  The meter number
will be referenced in field 498.  $t->lookup(498);

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
	2024 = 025 / 125 ALL Rate Available Services
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
Assuming you pass a valid FedEx UTI this method will find the correct
Transaction Number for you.  You need not pass this in.  Also no need to pass in your
FedEx Account Number or Meter Number.  You should pass these when creating a new 
Business::FedEx::DirectConnect object.
This method will allow you to use either the number field provided in the FedEx 
documentation or the hash (case insensitive) $FE_RE found in Business::FedEx::Constants.

Here is a tracking example where 29 is the "tracking number" field FedEx has
provided.

	$t->set_data(5000, 'tracking_number'=>'836603877972') or die $t->errstr;

is the same as

	$t->set_data(5000, 29 =>'836603877972') or die $t->errstr;

=item $t->required(UTI)

Method to return the required fields for a given FedEx UTI.

=item $t->transaction()

Send transaction to FedEx. Optionally you can pass the full request string if you choose not to use
the set_data method.  Returns the full reply from FedEx.

=item $t->label('someLabel.png')

This method will decode the binary image data from FedEx and save it to a file.  
If nothing is passed the binary data string will be returned.

=item $t->lookup('tracking_number')

This method will return the value for an item returned from FedEx.  Refer to
the C<Business::FedEx::Constants> $FE_RE hash to see all possible values. 

=item $t->rbuf()

Returns the decoded string portion of the FedEx reply.

=item $t->hash_ret()

Returns a hash of the FedEx reply values

	my $stuff= $t->hash_ret;

	foreach (keys %{$stuff}) {
		print $_. ' => ' . $stuff->{$_} . "\n";
	}

=back

=head1 IDEAS/TODO

Build methods for each type of transaction so you don't need to
know UTIs and other FedEx codes.
FedEx Express Ship-A-Package UTI 2016 would be called via
$object->FDXE_ship();

Build for multiple request.  FedEx currently can only accept
one transaction per request. I might try something with LWP::Parallel::UserAgent.

=head1 AUTHOR

Jay Powers, <F<jpowers@cpan.org>>

L<http://www.vermonster.com/perl>

Copyright (c) 2003 Jay Powers

All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself

If you have any questions, comments or suggestions please feel free 
to contact me.

=head1 SEE ALSO

C<Business::FedEx::Constants>

=cut
