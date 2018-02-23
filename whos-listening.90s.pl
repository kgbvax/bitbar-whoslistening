#!/usr/bin/perl 
# <bitbar.title>Who's listening?</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Ingomar Otter</bitbar.author>
# <bitbar.author.github>kgbvax</bitbar.author.github>
# <bitbar.desc>Show processes accepting (remote) network connections</bitbar.desc>
# <bitbar.image>.....</bitbar.image>
# <bitbar.abouturl>https://github.com/kgbvax/bitbar-whoslistening</bitbar.abouturl>

use strict;
use warnings;
use File::Path qw(make_path);
use Storable;

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
#for future use:
#/usr/libexec/ApplicationFirewall/socketfilterfw --getblockall
#Block all DISABLED!

my ($newOk, $newOkTime);
# if called with args, add to "ok'd" processes
if ($#ARGV == 1) {
  if ($ARGV[0] eq "markok24") {
	$newOk = $ARGV[1];  $newOkTime = time() + 86400;
  } elsif ($ARGV[0] eq "markok1") {
    $newOk = $ARGV[1];  $newOkTime = time() + 3600;
 }
}

# This script allows the user to mark some services as being "OK", 
# this is persistet in 
# ~/Library/Preferences/net.kgbvax.whoislistening/thisisfine
my $config_location="$ENV{HOME}/Library/Preferences/net.kgbvax.whoislistening";
make_path($config_location); #ignore errors, will fatally fail if need be
my $config_fname="$config_location/thisisfine.dat";


my %knowngood;
# "Known good system servies" are not reported.
# @author is actually no big fan of hiding services however I feel this makes it more usable for most people.

my $knowngood_ref = retrieve($config_fname) if -e $config_fname;
if ($knowngood_ref) { %knowngood =%$knowngood_ref; };

if (! %knowngood) {
  $knowngood{'rapportd'}=1596225487;
  store \%knowngood, $config_fname;
}

if (defined $newOk) { # a new services has been whitelisted
  $knowngood{$newOk}=$newOkTime;
  store \%knowngood, $config_fname;
}

my %hints = (
	"Dropbox" => ":point_right: Disable 'LAN Synchronisation' in Dropbox' network settings",
        "ARDAgent" => ":point_right: Disable remote administration in System->Preferences->Sharing"
);

#list open sockets
open(my $fh, '-|', 'lsof  +c0 -i -n  -P -sTCP:LISTEN ') or die $!;
#Outputs:
#COMMAND                           PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
#loginwindow                        97   io    8u  IPv4 0xe6dba78d3c11ca6d      0t0  UDP *:*

my $skipfirst=<$fh>;
my @report=();
while (my $line = <$fh>) {
	my @elems = split /\s+/, $line;    
	my ($command, $pid, $user, $fd, $type, $device, $size,$node,$name) = @elems;
	next if (!$name =~/LISTEN/); #ignore non-LISTEN
        next if ($name =~/127\.0\.0\.1/); #localhost is fine
        next if ($name =~/\[::1\]/); #localhost is fine
        next if ($node =~/UDP/); #UDP ignored (for now)
	next if (exists $knowngood{$command} &&
                 $knowngood{$command} > time()); # ignore OK'ed services 
        next if ( grep { $_ eq $command} @report ); # avoid duplicates 
	push @report, $command, $name;
}
close $fh;

#fetch firewall state
open ($fh,"-|",'/usr/libexec/ApplicationFirewall/socketfilterfw  --getglobalstate') or die $!;
my $line =  <$fh>; 
close $fh;

#state 1=enabled, state 2=enabled, block all connections
my $fwstate= ($line =~ /State = (1|2)/) ? 1 : 0; 


##emit result
if (@report || !$fwstate) {
  if (!$fwstate) {
      print ":fearful: Firwall is disabled | color=red\n"; 
  } else {
      print ":fire:\n";
  }
  print "---\n";
  
  while(@report) {
	my $iname = pop @report;
        my $icmd = pop @report; 
	print ":fire: $icmd $iname | color=red\n";
        print "--$hints{$icmd}\n" if (exists $hints{$icmd});
        print "--Mark OK for 24h | bash='$0' param1=markok24  param2='$icmd' terminal=false refresh=false\n";
   } 
} else { #nothing to complain about
  print ":ear:\n---\n";
}

print "Refresh | refresh=true\n";
