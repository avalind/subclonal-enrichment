{
	if(NF<7) {
		s += 0
	} else {
		s += $7
	}
	printf("Added %s to %s\n", $7, s) >> "logfile.txt"
}

END {
	if(NR==0) {
		print "0"
	} else {
		print s
	}
}
