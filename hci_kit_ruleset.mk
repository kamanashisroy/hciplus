
connecting = 0

onhciSetup:
	echo Hci is Up
	hcikit -reset
	hcikit -inquiry

onNewDevice:
	echo New device [$(newDeviceID)] $(newDevice)
	if $(connecting) echo Connecting

onACLConnectionEstablished:
	echo New ACL Connection $(connectionID) established 

onL2CAPInfoRequest:
	echo info requested $(connectionID), $(l2capConversationID) $(l2capInfoType)
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2captype $(l2capInfoType)
	echo L2cap info sent
