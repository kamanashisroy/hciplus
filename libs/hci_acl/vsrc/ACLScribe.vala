using aroop;
using hciplus;

public class hciplus.ACLScribe : hciplus.ACLSpokesMan {
	ArrayList<ACLConnection?> acls;
	protected enum ACLEvent {
		CONNECT_COMPLETE = 0x03,
		CONNECT_REQUEST = 0x04,
		DISCONNECT_COMPLETE = 0x05,
	}
	public ACLScribe(etxt*devName) {
		base(devName);
		acls = ArrayList<ACLConnection?>();
		subscribeForEventOnCommand(ACLCommand.CREATE_CONNECTION , onACLConnection);
		subscribeForEvent(ACLEvent.CONNECT_COMPLETE , onACLConnectionComplete);
		subscribeForEvent(ACLEvent.DISCONNECT_COMPLETE , onACLDisconnectionComplete);
		subscribeForIncomingPacket(ACLPacket.ACL_DATA , onACLData);
		subscribeForEvent(ACLEvent.CONNECT_REQUEST , onACLConnectRequest);
	}

	~ACLScribe() {
		acls.destroy();
	}

	int onACLConnection(etxt*buf) {
		uint8 status = getCommandStatus(buf);
		if(status != 0) {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "ACL connection failed");
		}
		return 0;
	}

	int readDevice(etxt*buf) {
		etxt resp = etxt.same_same(buf);
		resp.shift(HCIPacket.EVENT_PACKET_HEADER_LEN_WITHOUT_PLEN+1); // header length + plen
		aroop_uword8 rawaddr[6];
		rawaddr[0] = resp.char_at(0);
		rawaddr[1] = resp.char_at(1);
		rawaddr[2] = resp.char_at(2);
		rawaddr[3] = resp.char_at(3);
		rawaddr[4] = resp.char_at(4);
		rawaddr[5] = resp.char_at(5);
		etxt dlg = etxt.stack(128);
               	dlg.printf("Reading device %x,%x,%x,%x,%x,%x\n", rawaddr[0], rawaddr[1], rawaddr[2], rawaddr[3], rawaddr[4], rawaddr[5]);
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
		return getBluetoothDeviceByRawAddr(rawaddr);
	}

	int onACLConnectRequest(etxt*buf) {
		int devid = readDevice(buf);
		if(devid == -1) return 0;
		etxt varName = etxt.from_static("devID");
		HCISetVariableInt(&varName, devid);
		etxt dlg = etxt.stack(128);
               	dlg.printf("onACLConnectRequest");
               	HCIExecRule(&dlg);
		return 0;
	}

	int onACLDisconnectionComplete(etxt*buf) {
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "ACL disconnection from other end");
		onCommandComplete(null);
		return 0;
	}

	int onACLConnectionComplete(etxt*buf) {
		uint8 status = getCommandStatus(buf);
		if(status == 0) {
			ACLConnection con = new ACLConnection.fromConnectionCompleteEvent(buf);
			acls.set(con.handle, con);

			etxt varName = etxt.from_static("connectionID");
			HCISetVariableInt(&varName, con.handle);
			etxt dlg = etxt.stack(128);
                	dlg.printf("onACLConnectionEstablished");
                	HCIExecRule(&dlg);
		} else {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "ACL connection failed");
		}
		return 0;
	}

	protected virtual int onL2CAPData(ACLConnection con, etxt*resp) {
		uint16 dlen = 0;
		dlen = resp.char_at(5);
		dlen |= (resp.char_at(6) << 8);
		return 0;
	}

	int onACLData(etxt*resp) {
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "Incoming ACL data");
		uint16 handle = 0;
		handle = resp.char_at(1);
		handle |= ((resp.char_at(2) & 0x0F) << 8);
		// TODO parse pb and bc flag
		uint16 dlen = 0;
		dlen = resp.char_at(3);
		dlen |= (resp.char_at(4) << 8);
		if(dlen <= 2) {
			// discard empty packet
			return 0;
		}
		ACLConnection?con = acls.get(handle);
		if(con == null) {
			// acl connection could not be found
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "ACL connection not found");
			return 0;
		}
		onL2CAPData(con, resp);
		return 0;
	}
}
