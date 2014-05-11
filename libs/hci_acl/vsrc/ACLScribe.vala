using aroop;
using hciplus;

public class hciplus.ACLScribe : hciplus.ACLSpokesMan {
	ArrayList<ACLConnection?> acls;
	protected enum ACLEvent {
		CONNECT_COMPLETE = 0x03,
	}
	public ACLScribe(etxt*devName) {
		base(devName);
		acls = ArrayList<ACLConnection?>();
		subscribeForEventOnCommand(ACLCommand.CREATE_CONNECTION , onACLConnection);
		subscribeForEvent(ACLEvent.CONNECT_COMPLETE , onACLConnectionComplete);
		subscribeForIncomingPacket(0x02 /* ACL Data */ , onACLData);
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

	int onACLConnectionComplete(etxt*buf) {
		uint8 status = getCommandStatus(buf);
		if(status == 0) {
			ACLConnection con = new ACLConnection.fromConnectionCompleteEvent(buf);
			acls.set(con.handle, con);

			etxt varName = etxt.from_static("connectionID");
	                etxt varVal = etxt.stack(20);
			varVal.printf("%d", con.handle);
			HCISetVariable(&varName, &varVal);
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
