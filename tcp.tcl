set ns [new Simulator]			; # instance of Simulator object

# define colors for NAM to identify among the traffics

$ns color 64 red
$ns color 63 blue


set nf [open tcp_623_nam.nam w]	; # create nam file for writing
$ns namtrace-all $nf			; # instruct ns object to write all nam simulation data to nam file

set tf [open tcp_623_out.tr w]	; # create trace file for writing
$ns trace-all $tf			; # instruct ns object to write all nam simulation data to nam file

# finish procedure to close trace file and start nam
proc finish {} {
	global ns nf tf			; # define global variables
	$ns flush-trace			; # tell ns object to flush the trace buffer
	close $nf			; # close nam-trace file
	close $tf			; # close trace file
	exec nam tcp_623_nam.nam &	; # execute nam file
	#exec awk -f loss.awk tcp_623_out.tr > awkloss2.xg
	exec perl parseDropped-1.pl tcp_623_out.tr 1 0 1 > packetdrop.xg
	exec awk -f Thpt.awk tcp_623_out.tr > tcpks.xg 
	exec awk -f Avg_Jit.awk  tcp_623_out.tr > delayjitter.xg
	#exec perl parseThpt-1.pl tcp_623_out.tr 1 0 1 > tcpThpt.xg 
	exec xgraph -geometry 800x400 -p -bg white -t THROUGHPUT -x time(s) -y throughput(Mbits/s) tcpks.xg &
	exec xgraph -geometry 800x400 -p -bg white -t PACKETDROP -x time(s) -y packetdrop(Mbits/s) packetdrop.xg &
	exec xgraph -geometry 800x400 -p -bg white -t DELAYJITTER -x time(s) -y delayjitter(Mbits/s) delayjitter.xg &
	#exec xgraph -geometry 800x400 -p -bg white -t THROUGHPUT -x time(s) -y throughput(Mbits/s) tcpThpt.xg &
	#exec xgraph -geometry 800x400 -p -bg white -t PACKETDROP -x time(s) -y packetdrop(Mbits/s) awkloss2.xg &
	
	exit 0				; # exit 
}

# Create 2 nodes
set n0 [$ns node]
set n1 [$ns node]
set c1 [$ns node]
set c0 [$ns node]
set s1 [$ns node]
set s0 [$ns node]
#set n6 [$ns node]

# Create duplex link bandwidth 5Mb, delay 5ms queueing method is FIFO
$ns duplex-link $n0 $n1 512kb 20ms DropTail
$ns queue-limit $n0 $n1 15
$ns duplex-link $s0 $n1 100Mb 10ms DropTail
#$ns queue-limit $n2 $n1 5
$ns duplex-link $s1 $n1 100Mb 10ms DropTail
#$ns queue-limit $n3 $n1 5


$ns duplex-link $c1 $n0 100Mb 10ms DropTail
#$ns queue-limit $n5 $n0 5
$ns duplex-link $c0 $n0 100Mb 10ms DropTail
#$ns queue-limit $n6 $n0 5

#node positioning
$ns duplex-link-op $n1 $n0 orient right
$ns duplex-link-op $s0 $n1 orient right-up
$ns duplex-link-op $s1 $n1 orient right-down
$ns duplex-link-op $c0 $n0 orient left-up
$ns duplex-link-op $c1 $n0 orient left-down


# Set up a TCP and a UDP connection from source  to destination 

# TCP Source

set tcp1 [new Agent/TCP]			; # define tcp source agent
$ns attach-agent $c0 $tcp1
						; # attach agent to source

set ftp1 [new Application/FTP]		; # set traffic over TCP connection
$ftp1 attach-agent $tcp1			; # attach traffic to source agent


set tcp0 [new Agent/TCP]			; # define tcp source agent
$ns attach-agent $c1 $tcp0
					; # attach agent to source

set ftp0 [new Application/FTP]		; # set traffic over TCP connection
$ftp0 attach-agent $tcp0		; # attach traffic to source agent


# TCP Destination

set sink1 [new Agent/TCPSink]		; # define tcp sink agent
$ns attach-agent $s1 $sink1		; # attach agent to destination
$ns connect $tcp0 $sink1		; # connect tcp source to tcp destination
$tcp0 set fid_ 63			; # for identification in trace file


set sink2 [new Agent/TCPSink]		; # define tcp sink agent
$ns attach-agent $s0 $sink2		; # attach agent to destination
$ns connect $tcp1 $sink2		; # connect tcp source to tcp destination
$tcp1 set fid_ 64			; # for identification in trace file


# Schedule start and stop events for tcp and udp traffic
$ns at 0.1 "$ftp0 start"
$ns at 0.1 "$ftp1 start"
$ns at 9.7 "$ftp0 stop"
$ns at 9.8 "$ftp1 stop"
$ns at 10.0 "finish"			; # execute finish procedure 20.0 sec after simulation starts 

# Print to stdout
#puts "CBR packet size = [$cbr set packetSize_]"
#puts "TCP packet size = [$tcp0 set packetSize_]"
#puts "TCP packet size = [$tcp0 set packetSize_]"
$ns run					; # start the simulation 
