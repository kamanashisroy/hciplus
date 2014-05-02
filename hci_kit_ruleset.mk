
connecting = 0

onhciSetup:
	echo Hci is Up
	hcikit -reset
	hcikit -inquiry

onNewDevice:
	echo New device [$(newDeviceID)] $(newDevice)
	if $(connecting) echo Connecting

onACLConnectionEstablished:
	echo New ACL Connection established

onL2CAPInfoRequest:
	echo info requested
