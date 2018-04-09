#! /usr/bin/perl -w

use IO::Socket;
use Data::Dumper;
#require "/Users/Cpt_Snag/perl/lab4/func_ship.pl";
require "./func_ship.pl";
$socket = new IO::Socket::INET (
                                  PeerAddr  => '127.0.0.1',
                                  PeerPort  =>  5000,
                                  Proto => 'tcp',
                               )                
or die "Couldn't connect to Server\n";
my %convertHash = ('1a' => 0, '1b' => 1, '1c' => 2, '1d' => 3, '1e' => 4,
              '2a' => 5, '2b' => 6, '2c' => 7, '2d' => 8, '2e' => 9,
              '3a' => 10, '3b' => 11, '3c' => 12, '3d' => 13, '3e' => 14,
              '4a' => 15, '4b' => 16, '4c' => 17, '4d' => 18, '4e' => 19,
              '5a' => 20, '5b' => 21, '5c' => 22, '5d' => 23, '5e' => 24
          );

my $instruction = "\n=======
Syntax [m src dst] to move from src->dst
Syntax [l] to Display the Board
Syntax [s src dst] to shoot from src->dst
Your command: ";
### DON'T CHANGE ###
my $send_data = "";
my $recv_data = "";
my %shipHash = ();
### END DON'T CHANGE ###

print "s to start";
$send_data = <STDIN>;
chomp($send_data);
$socket->send($send_data);
print "\n";
$eol = "=" x 60;
print $eol;


while (1)
{   
    $socket->recv($recv_data,1024);
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
          if (!move($src, $dst, '2', \%shipHash)) 
          {
            print "$instruction";

            $send_data = <STDIN>;
            chomp($send_data);
          }
          else
          {
            last; #if move success
          }
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
          if (!shoot($src, $dst, '2', \%shipHash)) 
          {
            print "$instruction";

            $send_data = <STDIN>;
            chomp($send_data);
          }
          else
          {
            last; #if shoot success
          }
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
    }

    if (isLost('1', \%shipHash))
    {
      print "You Win";
      $socket->send("You Lose");
      close $socket;
    }
    displayBoard(%shipHash);
    print "\nWaiting to respond.......";

    $send_data = hashshipToString(\%shipHash);
    $socket->send($send_data);

    $eol = "\n" . "=" x 60 . "\n\n\n";
    print $eol;
}