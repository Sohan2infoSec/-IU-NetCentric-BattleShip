use Data::Dumper;
use List::Util qw(shuffle);
use warnings;

sub stringToHashship # ($str) %hash
{
  my $str = $_[0];
  my %hash = split /[;:]/, $str;
  #sort {$a <=> $b} -->1->2->3  
  #sort {$a cmp $b} -->1a->1b->3  
  foreach my $key ( sort keys %hash ) #sort {$a <=> $b} -->1->2->3  
  {
    #print $hash{$key};
    $hash{$key} = [split(/-/, $hash{$key})];
  }
  return %hash;
}

sub hashshipToString # (\%hash) $str
{
  my $hashRef = shift;
  my $stringX = "";
  foreach my $key (sort keys %{$hashRef})
  {
    #sort {$a <=> $b} -->1->2->3  
    #sort {$a cmp $b} -->1a->1b->3     
    $stringX .= "$key:";
    $stringX .= join("-", @{ $hashRef->{$key} });
    $stringX .= ";";
  }
  return $stringX;
}

sub initShipHash  #(void) %hash
{ 
  ### Init Random String
  my @a = (1,1,1,1,1,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  my @t = shuffle @a;
  my $shipStr = join(" ", @t);
  ### End Init Random String

  ### Coordinate Hash
  my %convertHash = ('1a' => 0, '1b' => 1, '1c' => 2, '1d' => 3, '1e' => 4,
              '2a' => 5, '2b' => 6, '2c' => 7, '2d' => 8, '2e' => 9,
              '3a' => 10, '3b' => 11, '3c' => 12, '3d' => 13, '3e' => 14,
              '4a' => 15, '4b' => 16, '4c' => 17, '4d' => 18, '4e' => 19,
              '5a' => 20, '5b' => 21, '5c' => 22, '5d' => 23, '5e' => 24
          );
  %nhash = reverse %convertHash;
  my %newHash = ();
  foreach my $name (sort keys %nhash) {
      $newHash{$name} = $nhash{$name};
  }
  ### End Coordinate Hash

  my %shipHash = ();
  my @shipArr = split(/ /, $shipStr);

  for(my $i = 0; $i < scalar(@shipArr); $i++)
  {
    $shipHash{$newHash{$i}} = [$shipArr[$i], 100, 'a'];
    #print $shipHash{$nHash{$i}};
  }
  return %shipHash;
}

sub displayBoard #(%hash) void
{
  my %hash = @_;
  my $i = 0;
  my $j = 1;
  my @tmpList = ('a', 'b', 'c', 'd', 'e');
  print "\n    ",join("   ", @tmpList);

  my @hpList = (' a', ' b ', ' c ', ' d ', ' e ');
  print "\t\t\t ",join("    ", @hpList);
  foreach my $coordinate (sort keys %hash)
  {  
    #print "\n COr: $coordinate";
    if ($hash{$coordinate}[0] eq '0' || $hash{$coordinate}[1] == 0)
    {
      $tmpList[$i] = " ";
      $hpList[$i] = "   ";
    }
    else
    {
      $tmpList[$i] = $hash{$coordinate}[0];
      $hpList[$i] = $hash{$coordinate}[1];
    }
    $i++;
    if ($i == 5)
    {
      print "\n$j ~ "; $j++;
      print join(" | ", @tmpList);
      print " |";
      $i = 0;

      print "\t\t\t",join(" |  ", @hpList);
      print " |";
    }  
  }
}

sub move #( $src, $dst, $num, \%shipHash ) 0 | 1
{
  my( $src, $dst, $num, $shipHash ) = @_;
  if ($shipHash->{$src}[0] ne $num)
  {
    print "\n=>You cannot move the opponent's ship OR blank";
    return 0;
  }

  if (check_adjacent($src, $dst)) #If adjacent
  {
    if ($shipHash->{$src}[0] eq  $shipHash->{$dst}[0])
    {
      print "\n=>There is an allied ship on the Destination!";
      return 0;
    }
    elsif($shipHash->{$dst}[0] eq '0')
    {
      $shipHash->{$dst}[0] = $shipHash->{$src}[0];
      $shipHash->{$src}[0] = '0';
      print "\n=>Successfully move from $src --> $dst.";
      #return %shipHash;
    }
  }
  else
  {
    print "\n=>The 2 squares are not adjacent!";
    return 0;
  }
  return 1;
}

sub shoot #( $src, $dst, $num, \%shipHash ) 0 | 1
{
  my( $src, $dst, $num, $shipHash ) = @_;
  if ($shipHash->{$src}[0] ne $num)
  {
    print "\n=>You cannot control the opponent's ship OR blank.";
    return 0;
  }

  if (check_adjacent($src, $dst)) #If adjacent
  {
    if ($shipHash->{$src}[0] eq  $shipHash->{$dst}[0])
    {
      print "\n=>You cannot shoot your allied ship!";
      return 0;
    }
    elsif($shipHash->{$dst}[0] eq '0')
    {
      print "\n=>There is no ship to shoot.";
      return 0;
    }
    else
    {
      print "\n=>Shoot succesfully!";
      decreaseHP($dst, 50, $shipHash);
    }
  }
  else
  {
    print "\n=>The 2 squares are not adjacent!";
    return 0;
  }
  return 1;
}
sub decreaseHP
{
  my ($dst, $dame, $hash) = @_;
  my $currentHP = $hash->{$dst}[1] - $dame;
  if ($currentHP == 0)
  {
    print "\n=>The ship is shank.";
    $hash->{$dst}[1] = 0;
  }
  elsif ($currentHP > 0)
  {
    $hash->{$dst}[1] -= $dame;
    print "\n=>The ship at $dst now has $hash->{$dst}[1] hp.";
  }
}

sub check_adjacent #($str, $str) 1 | 0
{ 
  my( $src, $dst ) = @_;
  if ($src eq $dst)
  {
    return 0;
  }

  ### Check 2 letter coordination
  if ( (((ord(substr($src, 0, 1)) + 1 == ord(substr($dst, 0, 1))) || (ord(substr($src, 0, 1)) - 1 == ord(substr($dst, 0, 1))) )
          && (ord(substr($src, -1, 1)) == ord(substr($dst, -1, 1)))) 
      ||  (((ord(substr($src, -1, 1)) + 1 == ord(substr($dst, -1, 1))) || (ord(substr($src, -1, 1)) - 1 == ord(substr($dst, -1, 1))) )
           && (ord(substr($src, 0, 1)) == ord(substr($dst, 0, 1)))) )
  {
    return 1;
  }
  return 0;
}

sub isLost #($team, \%hash) 1 | 0
{
  my ($team, $hashRef) = @_;
  foreach my $key (keys %{$hashRef})
  {
    if ($hashRef->{$key}[0] eq $team)
    {
      return 0;
    }
  }
  return 1;
}
##BACKUP
# sub move #( $src, $dst, $num, %shipHash ) 0 | %hash
# {
#   my( $src, $dst, $num, %shipHash ) = @_;
#   #print "\n$src ==== $dst\n";
#   #print "\nValue at that src: $shipHash{$src}[0]";
#   #print "\nValue at that dst: $shipHash{$dst}[0]";
#   if ($shipHash{$src}[0] ne $num)
#   {
#     print "\nYou cannot move the opponent's ship OR blank";
#     return 0;
#   }

#   if (check_adjacent($src, $dst)) #If adjacent
#   {
#     if ($shipHash{$src}[0] eq  $shipHash{$dst}[0])
#     {
#       print "\nThere is an allied ship on the Destination!";
#       return 0;
#     }
#     elsif($shipHash{$dst}[0] eq '0')
#     {
#       $shipHash{$dst}[0] = $shipHash{$src}[0];
#       $shipHash{$src}[0] = '0';
#       print "\nSuccessfully move from $src --> $dst .";
#       #return %shipHash;
#     }
#   }
#   else
#   {
#     print "\nThe 2 squares are not adjacent!";
#     return 0;
#   }
#   return %shipHash;
# }

# sub shoot
# {
#   my( $src, $dst, $num, %shipHash ) = @_;
#   if ($shipHash{$src}[0] ne $num)
#   {
#     print "\nYou cannot control the opponent's ship OR blank.";
#     return 0;
#   }

#   if (check_adjacent($src, $dst)) #If adjacent
#   {
#     if ($shipHash{$src}[0] eq  $shipHash{$dst}[0])
#     {
#       print "\nYou cannot shoot your allied ship!";
#       return 0;
#     }
#     elsif($shipHash{$dst}[0] eq '0')
#     {
#       print "\nThere is no ship to shoot.";
#       return 0;
#       #return %shipHash;
#     }
#     else
#     {
#       print "\nShoot succesfully!";
#       # decreaseHP($dst, 50, \%hash);
#       my $dame = 50;
#       my $currentHP = $shipHash{$dst}[1] - $dame;
#       if ($currentHP == 0)
#       {
#         print "\nThe ship is shank.";
#         $shipHash{$dst}[1] = 0;
#       }
#       elsif ($currentHP > 0)
#       {
#         $shipHash{$dst}[1] -= $dame;
#         print "\nThe ship at $dst now has $shipHash{$dst}[1] hp.";
#       }
#     }
#   }
#   else
#   {
#     print "\nThe 2 squares are not adjacent!";
#     return 0;
#   }
#   return 1;
# }
1;