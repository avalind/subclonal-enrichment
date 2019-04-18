{
	if(NF<7) {
		s += 0
	} else {
		s += $7
	}
}

END {
	if(NR==0) {
		print "0"
	} else {
		print s
	}
}
