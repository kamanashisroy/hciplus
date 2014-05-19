
connecting = 0

onhciSetup:
	echo Hci is Up
	hcikit -reset
	hcikit -inquiry

onNewDevice:
	echo New device [$(newDeviceID)] $(newDevice)
	eq -x 1 -y 0$(connecting) -z isConnecting
	echo $(isConnecting)
	if not $(isConnecting) echo connecting
	if not $(isConnecting) hci -acl 0
	if not $(isConnecting) set -var connecting -val 1

onACLConnectionEstablished:
	echo New ACL Connection $(connectionID) established 

onL2CAPInfoRequest:
	echo info requested $(connectionID), $(l2capConversationID) $(l2capInfoType)
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2captype $(l2capInfoType) -l2capcommandid $(l2capCommandId)
	echo L2cap info sent
	set -var lcapConHere -val 0
	eq -x $(l2capInfoType) -y 3 -z lcapConHere
	if $(lcapConHere) echo We should connect here
	if $(lcapConHere) l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -connect

onL2CAPConnectionSuccess:
	echo L2CAP Connection successful

onL2CAPConfigureRequest:
	echo L2CAP Confugration request received
