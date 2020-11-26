# ====================== loss.awk ======================================

# Usage:  # # # # # # # # # # # # # # #
# awk -f loss.awk tracefile > outfile #
# # # # # # # # # # # # # # # # # # # #
# Edit as needed for NAM or trace.
## # # # # # # # # # # # # # # # # # # # # # # # #
 
BEGIN { highest_packet_id = 0;	delay = avg_delay = 0; pktsSent = 0; pktsLost = 0; }
{
	action	= $1;
	time	= $2;
	prot	= $5;
	seq_no	= $11;
	pkt_id	= $12;

	if ( pkt_id > highest_packet_id ) highest_packet_id = pkt_id;
	# Store packet sequence number and packet drop time
	if (prot = "ack" && action == "r") {
		sqd[seq_no] = seq_no;
		pd[pkt_id] = pkt_id;
		drt[pkt_id] = time;
		ad[seq_no] = action;
		prd[seq_no] = prot;
		pktsSent++;
		# printf("%d %f %d %s \n",pd[seq_no],drt[pkt_id],sqd[seq_no],prd[seq_no])
	}

	# # # # # # # # # # # #
	# Compute packet loss #
	# # # # # # # # # # # # 
	if (prot = "ack" && action == "r") {
		printf("%f %0.2f \n", drt[pkt_id], pktsSent)
	}
}
