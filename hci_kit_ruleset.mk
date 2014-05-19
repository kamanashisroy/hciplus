
connecting = 0

onhciSetup:
	echo Hci is Up
	hcikit -reset
	hcikit -inquiry

onNewDevice:
	echo New device [$(newDeviceID)] $(newDevice)
	set -var x -val 0
	eq -x x -y connecting -z isConnecting
	echo $(isConnecting)
	if not $(isConnecting) echo connecting
	if not $(isConnecting) hci -acl 0
	if not $(isConnecting) set -var connecting -acl 1

onACLConnectionEstablished:
	echo New ACL Connection $(connectionID) established 

onL2CAPInfoRequest:
	echo info requested $(connectionID), $(l2capConversationID) $(l2capInfoType)
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2captype $(l2capInfoType)
	echo L2cap info sent
	eq -x $(l2capInfoType) -y 3 -z l2capConnectNow
	if $(l2capConnectNow) l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -connect
