#!/usr/local/bin/perl

##############################################################################
## Fields in a trace file
## 0	   1	  2      3      4      5      6       7     8      9      10    11
#|------------------------------------------------------------------------------------
#| Event/ | Time | From | To   | Pkt  | Pkt  | Flags |Flow | Src  | Dest | Seq | Pkt |
#| action |      | node | node | type | size |       | id  | addr | addr | num | id  |
#|------------------------------------------------------------------------------------
#| $1      $2     $3     $4     $5     $6     $7      $8    $9     $10    $11   $12
#|
## Fields in queue trace file
## 0	   1	  2      3      4      5          6            7       8         9            10
#|---------------------------------------------------------------------------------------------------
#| Time | In   | Out  | Byte | Pkt  | Pkt      | Pkt        | Pkt   | Byte     | Byte       | Byte  |
#|      | node | node | size | size | arrivals | departures | drops | arrivals | departures | drops |
#|---------------------------------------------------------------------------------------------------
#| $1      $2     $3     $4     $5     $6         $7          $8      $9         $10          $11
##
##############################################################################

# type: perl parseDropped.pl <tracaefile> <granularity> <fromNode> <toNode>
# output: time <fromNode(bit/s)> <toNode(bit/s)> <droppedfromNode(bits/s)> <droppedtoNode(bits/s)>

$infile			= $ARGV[0];
$granularity		= $ARGV[1];
$fromNode1		= $ARGV[2];	#1 (ExtNode - ExtR: E1)
$toNode1		= $ARGV[3];	#0 (lastNode - CoreR: C)
# $fromNode2		= $ARGV[4];	#2
# $toNode2		= $ARGV[5];	#0
# $interval		= $ARGV[5];
my ($input,$pos,$tcpDropped,$udpDropped,@x,$tcpByte,$udpByte);
# $pos = $interval;
$tcpSum = 0; $udpSum = 0; $clock = 0;
open (DATA, "<$infile") || die "Can't open $infile !!";
while(<DATA>) {
	@x = split (' ');	# split columns of a line and save into array
	if ($x[1] - $clock <= $granularity) {
		if ($x[0] eq 'd'){	# check if the event corresponds to a drop
			if (($x[2] eq $fromNode1) && ($x[3] eq $toNode1)){	# check if source=1 and destination=lastNode
				if ($x[4] eq 'tcp') {
					$tcpByte += $x[5]; #$tcpSum;	# sum dropped pkts (bytes)
					$tcpSum ++; #$tcpByte;	# sum dropped pkts (bytes)
				}
			}
			if (($x[2] eq $fromNode1) && ($x[3] eq $toNode1)){	# check if source=1 and destination=lastNode
				if ($x[4] eq 'cbr') {
					$udpByte += $x[5];
					$udpSum ++;
				}
			}
		} 
	} else {
		$tcpDropped = $tcpByte;
		$udpDropped = $udpByte;
		printf STDOUT ("%0.4f  %1d  %1d  \n", $x[1],$tcpDropped,$tcpSum);
		$clock = $clock + $granularity;
		#$tcpByte = 0; $udpByte = 0;
	}
}
	$tcpDropped = $tcpByte;
	$udpDropped = $udpByte;
	printf STDOUT ("%0.4f  %1d  %1d \n", $x[1],$tcpDropped,$tcpSum);
	$clock = $clock + $granularity;
	# $tcpByte = 0; $udpByte = 0;
	close DATA;

exit(0);
