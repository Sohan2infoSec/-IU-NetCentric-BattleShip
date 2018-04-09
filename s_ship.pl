#! /usr/bin/perl -w

use IO::Socket;
use Data::Dumper;
#require "/Users/Cpt_Snag/perl/lab4/func_ship.pl";
require "./func_ship.pl";
$| = 1;

$socket = new IO::Socket::INET (
                                  LocalHost => '127.0.0.1',
                                  LocalPort => '5000',
                                  Proto => 'tcp',
                                  Listen => 5,
                                  Reuse => 1
                               );
                                
die "Coudn't open socket" unless $socket;

print "\nTCPServer Waiting for client on port 5000";

my $client_socket = "";
my $instruction = "\n=======
Syntax [m src dst] to move from src->dst
Syntax [l] to Display the Board
Syntax [s src dst] to shoot from src->dst
Your command: ";
while ($client_socket = $socket->accept())
{
  ### Client Info ###
  $peer_address = $client_socket->peerhost();
  $peer_port = $client_socket->peerport();
  #print "\n Client $client_socket ";
  print "\nI got a connection from ( $peer_address , $peer_port ) ";
  ### End Client Info ###
  ### DON'T CHANGE ###
  my $send_data = "";
  my $recv_data = "";
  my %shipHash = ();
  ### DON'T CHANGE ###
  
  while (1)
  {
    $client_socket->recv($recv_data,1024);
    #print "\nReceive number: $recv_data";
    if ( $recv_data eq "s" )
    {
      %shipHash = initShipHash();
    }
    elsif (substr($send_data, 0, 1) eq "m" || substr($send_data, 0, 1) eq "s" || substr($send_data, 0, 1) eq "l")
    {
      %shipHash = stringToHashship($recv_data);
      displayBoard(%shipHash);
      print "$instruction";
      $send_data = <STDIN>;
      chomp($send_data);
      while (1)
      {
        if (substr($send_data, 0, 1) eq "m")
        {
            my @recv_arr = split(/ /, $send_data);
            my $src = $recv_arr[1];
            my $dst = $recv_arr[2];
            if (scalar @recv_arr == 3)
            {
              if (!move($src, $dst, '1', \%shipHash)) 
              {
                print "$instruction";
                $send_data = <STDIN>;
                chomp($send_data);
              }
              else
              {
                last; #if move success
              }
              #my %tmpHash = %send_data;
              #%shipHash = move($src, $dst, '2', %shipHash);
            }
        }
        elsif (substr($send_data, 0, 1) eq "s")
        {
            my @recv_arr = split(/ /, $send_data);
            my $src = $recv_arr[1];
            my $dst = $recv_arr[2];
            if (scalar @recv_arr == 3)
            {
              if (!shoot($src, $dst, '1', \%shipHash)) 
              {
                displayBoard(%shipHash);
                print "$instruction";

                $send_data = <STDIN>;
                chomp($send_data);
              }
              else
              {
                last; #if move success
              }
              #my %tmpHash = %send_data;
              #%shipHash = move($src, $dst, '2', %shipHash);
            }
        }
        elsif ($send_data eq "l")
        {
          $eol = "\n" . "=" x 60;
          print $eol;

          displayBoard(%shipHash);

          print "$instruction";
          $send_data = <STDIN>;
          chomp($send_data);
        }
        else
        {
          print "$instruction";
          $send_data = <STDIN>;
          chomp($send_data);
        }
      } #While - repromt
    } #If - recv_data
    elsif ($recv_data eq "You Lose")
    {
      print "$recv_data";
    }
    displayBoard(%shipHash);
    $send_data = hashshipToString(\%shipHash);
    $client_socket->send($send_data);

    $eol = "\n" . "=" x 60 . "\n\n\n";
    print $eol;
    ### SEND DATA ###
    


   
    ### END SEND DATA ###
  }
}