use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Business::FedEx::DirectConnect',
    'VERSION_FROM'	=> 'DirectConnect.pm', # finds $VERSION
    'PREREQ_PM'		=> {LWP::UserAgent => 0}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'FedEx Ship Manager Direct Connect',
       ABSTRACT_FROM => 'DirectConnect.pm', # retrieve abstract from module
       AUTHOR     => 'Jay Powers <jay@vermonster.com>') : ()),
);