
onload:
	rfcomm -service 12

onchannel:
	rfcomm -service $1

onaccept:
	rfcomm -accept $1

