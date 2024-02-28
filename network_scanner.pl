#!/usr/bin/perl

use strict;
use warnings;
use Net::Ping;
use IO::Socket::INET;

print "Enter the IP address or hostname to scan: ";
my $host = <STDIN>;
chomp $host;

my $p = Net::Ping->new("icmp");
if ($p->ping($host)) {
  print "$host is alive.\n";
  print "Starting port scan for common ports...\n";
  port_scan($host);
} else {
  print "$host is down.\n";
}
$p->close();

sub port_scan {
  my ($host) = @_;
  my @common_ports = (80, 443, 21, 22, 25, 110, 143);
  
  foreach my $port (@common_ports) {
    my $socket = IO::Socket::INET->new(
      PeerAddr => $host,
      PeerPort => $port,
      Proto => 'tcp',
      Timeout => 1
    );
    if ($socket) {
      print "Port $port is open.\n";
      close $socket;
    }
  }
}

