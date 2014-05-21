using aroop;
using hciplus;

public delegate int hciplus.L2CAPEventOccured(ACLConnection con, etxt*buf);
public class hciplus.L2CAPScribe : hciplus.L2CAPSpokesMan {
	L2CAPEventOccured l2capSubscribers[16];
	enum L2CAPConfig {
		MAX_SUBSCRIBERS = 16,
	}
	public L2CAPScribe(etxt*devName) {
		base(devName);
		l2capSubscribeForEvent(L2CAPCommand.INFORMATION_REQUEST, onL2CAPInfoRequest);
		l2capSubscribeForEvent(L2CAPCommand.CONNECTION_RESPONSE, onL2CAPConnectionResponse);
		l2capSubscribeForEvent(L2CAPCommand.CONFIGURE_REQUEST, onL2CAPConfigureRequest);
		l2capSubscribeForEvent(L2CAPCommand.CONFIGURE_RESPONSE, onL2CAPConfigureResponse);
	}

	public int l2capSubscribeForEvent(int type, L2CAPEventOccured oc) {
		core.assert(type < L2CAPConfig.MAX_SUBSCRIBERS);
		l2capSubscribers[type] = oc;
		return 0;
	}

	protected override int onL2CAPData(ACLConnection con, etxt*resp) {
		uint16 dlen = 0;
		dlen = resp.char_at(5);
		dlen |= (resp.char_at(6) << 8);
		uint16 cid = 0;
		cid = resp.char_at(7);
		cid |= (resp.char_at(8) << 8);
		L2CAPConversation?talk = l2capConvs.get(cid);
		if(talk == null) {
			talk = new L2CAPConversation(cid);
			l2capConvs.set(cid, talk);
		}
		uint8 cmd = resp.char_at(9);
		if(l2capSubscribers[cmd] != null) {
			l2capSubscribers[cmd](con, resp);
		}
		return 0;
	}

	protected int onL2CAPInfoRequest(ACLConnection con, etxt*resp) {
		uint16 dlen = 0;
		dlen = resp.char_at(5);
		dlen |= (resp.char_at(6) << 8);
		uint16 cid = 0;
		cid = resp.char_at(7);
		cid |= (resp.char_at(8) << 8);
		uint8 cmd = resp.char_at(9);
		uint8 cmd_id = resp.char_at(10);
		if(cmd_id >= cmdId) {
			cmdId += cmd_id;
		}
		uint16 cmd_len = 0;
		cmd_len = resp.char_at(11);
		cmd_len |= (resp.char_at(12) << 8);
		uint16 info_type = 0;
		info_type = resp.char_at(13);
		info_type |= (resp.char_at(14) << 8);
		if(cmd == 0x0a/*info request*/) {
			etxt varName = etxt.from_static("l2capConversationID");
	                etxt varVal = etxt.stack(20);
			varVal.printf("%d", cid);
			HCISetVariable(&varName, &varVal);
			varName.destroy();
			varName = etxt.from_static("l2capCommandId");
			varVal.printf("%d", cmd_id);
			HCISetVariable(&varName, &varVal);
			etxt varName2 = etxt.from_static("l2capInfoType");
	                etxt varVal2 = etxt.stack(20);
			varVal2.printf("%d", info_type);
			HCISetVariable(&varName2, &varVal2);
			etxt dlg = etxt.stack(128);
                	dlg.printf("onL2CAPInfoRequest");
                	HCIExecRule(&dlg);
		}
		return 0;
	}
	protected int onL2CAPConnectionResponse(ACLConnection con, etxt*resp) {
		uint8 cmd = resp.char_at(9); // cmd = 3
		uint8 cmd_id = resp.char_at(10);
		if(cmd_id >= cmdId) {
			cmdId += cmd_id;
		}
		uint16 cmd_len = 0;
		cmd_len = resp.char_at(11);
		cmd_len |= (resp.char_at(12) << 8);
		uint16 his_token = 0;
		his_token = resp.char_at(13);
		his_token |= (resp.char_at(14) << 8);
		uint16 my_token = 0;
		my_token = resp.char_at(15);
		my_token |= (resp.char_at(16) << 8);
		L2CAPConnection?lcon = l2capForge.get(my_token);
		if(lcon == null) {
			etxt dlg = etxt.stack(128);
			dlg.printf("L2CAP connection(%d) not found", my_token);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, &dlg);
			return 0;
		}
		lcon.hisToken = his_token;
		uint16 result = 0;
		result = resp.char_at(16);
		result |= (resp.char_at(17) << 8);
		if(result == 0) {
			etxt varName = etxt.from_static("l2capConnectionToken");
	        	etxt varVal = etxt.stack(20);
			varVal.printf("%d", my_token);
			HCISetVariable(&varName, &varVal);
			// connection successful 
			etxt dlg = etxt.stack(128);
                	dlg.printf("onL2CAPConnectionSuccess");
                	HCIExecRule(&dlg);
		}
		return 0;
	}

	protected int onL2CAPConfigureRequest(ACLConnection con, etxt*resp) {
		uint16 cid = 0;
		cid = resp.char_at(7);
		cid |= (resp.char_at(8) << 8);
		uint8 cmd = resp.char_at(9); // cmd = 3
		uint8 cmd_id = resp.char_at(10);
		if(cmd_id >= cmdId) {
			cmdId += cmd_id;
		}
		uint16 cmd_len = 0;
		cmd_len = resp.char_at(11);
		cmd_len |= (resp.char_at(12) << 8);
		uint16 token = 0;
		token = resp.char_at(13);
		token |= (resp.char_at(14) << 8);
		L2CAPConnection?lcon = l2capForge.get(token);
		if(lcon == null) {
			etxt dlg = etxt.stack(128);
			dlg.printf("L2CAP connection(%d) not found", token);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, &dlg);
			return 0;
		}
		int attrSize = cmd_len-2;
		int attrStart = 15;
		int i = 0;
		// get the MTU
		for(i = 0;i<attrSize;) {
			int attr = resp.char_at(attrStart+i);
			if(attr == 0x01) { // mtu 
				lcon.mtu = resp.char_at(attrStart+i+2);
				lcon.mtu |= resp.char_at(attrStart+i+3) << 8;
				lcon.mtuIsSet = true;
				etxt dlg = etxt.stack(32);
				dlg.printf("MTU:%u",lcon.mtu);
				shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 2, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
			}
			int attrlen = resp.char_at(attrStart+i+1);
			i+=attrlen+2;
		}
		etxt varName = etxt.from_static("l2capConnectionToken");
	        etxt varVal = etxt.stack(20);
		varVal.printf("%d", token);
		HCISetVariable(&varName, &varVal);
		varName = etxt.from_static("l2capCommandId");
		varVal.printf("%d", cmd_id);
		HCISetVariable(&varName, &varVal);
		etxt dlg = etxt.stack(128);
                dlg.printf("onL2CAPConfigureRequest");
                HCIExecRule(&dlg);
		return 0;
	}

	protected int onL2CAPConfigureResponse(ACLConnection con, etxt*resp) {
		uint16 cid = 0;
		cid = resp.char_at(7);
		cid |= (resp.char_at(8) << 8);
		uint8 cmd = resp.char_at(9); // cmd = 3
		uint8 cmd_id = resp.char_at(10);
		if(cmd_id >= cmdId) {
			cmdId += cmd_id;
		}
		uint16 cmd_len = 0;
		cmd_len = resp.char_at(11);
		cmd_len |= (resp.char_at(12) << 8);
		uint16 token = 0;
		token = resp.char_at(13);
		token |= (resp.char_at(14) << 8);
		L2CAPConnection?lcon = l2capForge.get(token);
		if(lcon == null) {
			etxt dlg = etxt.stack(128);
			dlg.printf("L2CAP connection(%d) not found", token);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, &dlg);
			return 0;
		}
		int status = resp.char_at(17);
		status |= (resp.char_at(18) << 8);
		if(status != 0) {
			etxt dlg = etxt.stack(128);
			dlg.printf("L2CAP connection(%d) configuration failed:%d", token, status);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, &dlg);
			return 0;
		}
		etxt dlg = etxt.stack(128);
                dlg.printf("onL2CAPConfigureResponse");
                HCIExecRule(&dlg);
		return 0;
	}
}
