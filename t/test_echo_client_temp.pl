#! /usr/bin/perl

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Net::BEEP::Lite;
use Net::BEEP::Lite::Session;

use warnings;

# connect to the server (this will die if it can't).
my $session = Net::BEEP::Lite::beep_connect(Host => "localhost",
					    Port => $ARGV[0]);

# start a channel for the echo profile (this will die if it can't).
my $channel_num = $session->start_channel
  (URI        => 'http://xml.resource.org/profiles/NULL/ECHO',
   ServerName => "host.example.com");

my $channel_num_2 = $session->start_channel
  (URI => 'http://xml.resource.org/profiles/NULL/ECHO');


my $resp = $session->send_and_recv_message(ContentType  => 'text/plain',
					   Content      => "Echo this!",
					   Channel      => $channel_num);

print "Received the following response payload:\n", $resp->payload(), "\n";


# attempt to send a bad frame:

my $message = new Net::BEEP::Lite::Message(Type        => 'MSG',
                                           Channel     => $channel_num,
                                           ContentType => "text/plan",
                                           Content     => "This should fail");
$message->msgno($session->channel($channel_num)->next_msgno());
my $frame = $message->next_frame($session->channel($channel_num)->seqno(),
                                 4096);
my $frame_string = $frame->to_string();

print "This is the correct frame:\n$frame_string\n";

$frame_string =~ s/ 43/ 49/;

print "This is the incorrect frame (length is too long):\n$frame_string\n";

$session->{sock}->print($frame_string);
$session->{sock}->flush();

#sleep(10);

#$resp = $session->close_channel($channel_num_2);

#$resp = $session->close_channel($channel_num);

#print "Socket seems to have closed early\n" if not $session->_is_connected();

#$resp = $session->close_channel(0);

