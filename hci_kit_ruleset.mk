
onHciSetup:
	echo Hci is Up
	hcikit -reset
	hcikit -inquiry
	set -var aclNotConnected -val 1
	set -var incomingACL -val 0

onNewDevice:
	echo New device [$(newDeviceID)] $(newDevice)
	if $(aclNotConnected) echo connecting
	if $(aclNotConnected) acl -devid $(newDeviceID)
	if $(aclNotConnected) set -var aclNotConnected -val 0

onACLConnectRequest:
	echo New incomming connection from $(devID)
	acl -receive -devid $(devID)
	set -var incomingACL -val 1

onACLConnectionEstablished:
	echo New ACL Connection $(connectionID) established 

onL2capConnectRequest:
	echo l2cap connect requested $(l2capConversationID), $(l2capConnectionType)
	l2cap -accept -acl $(connectionID) -l2cap $(l2capConversationID) -l2capcmdid $(l2capCommandId) -l2capcontoken $(l2capConnectionToken)
	echo We allowed connection ..

onL2capInfoRequest:
	echo info requested $(connectionID), $(l2capConversationID) $(l2capInfoType)
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2captp $(l2capInfoType) -l2capcmdid $(l2capCommandId)
	echo L2cap info sent
	set -var lcapConHere -val 0
	eq -x $(l2capInfoType) -y 3 -z lcapConHere
	if $(incomingACL) set -var lcapConHere -val 0
	if $(lcapConHere) echo We should connect here
	if $(lcapConHere) l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -connect 3

onL2capConnectionSuccess:
	echo L2CAP Connection successful
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2capcontoken $(l2capConnectionToken) -confreq

onL2capConfigureRequest:
	echo L2CAP Confugration request $(l2capConnectionToken) $(l2capCommandId)
	l2cap -acl $(connectionID) -l2cap $(l2capConversationID) -l2capcontoken $(l2capConnectionToken) -l2capcmdid $(l2capCommandId) -confresp

onL2capConfigureResponse:
	echo L2CAP Configuration successful
	sdp -acl $(connectionID) -l2cap $(l2capConversationID)
	rfcomm -sabm $(connectionID) -l2cap $(l2capConversationID)

