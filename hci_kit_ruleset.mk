
onhciSetup:
	echo Hci is Up
	hcikit -reset
	hcikit -inquiry
	set -var aclNotConnected -val 1

onNewDevice:
	echo New device [$(newDeviceID)] $(newDevice)
	if $(aclNotConnected) echo connecting
	if $(aclNotConnected) acl -devid $(newDeviceID)
	if $(aclNotConnected) set -var aclNotConnected -val 0

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
	echo L2CAP Confugration request received, $(l2capConnectionToken)
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2capconnectiontoken $(l2capConnectionToken) -configure

onL2CAPConfigureResponse:
	echo L2CAP Configuration successful
	sdp -acl $(connectionID) -l2cap $(l2capConversationID)
