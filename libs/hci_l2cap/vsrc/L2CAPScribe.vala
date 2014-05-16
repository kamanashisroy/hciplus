using aroop;
using hciplus;

public class hciplus.L2CAPScribe : hciplus.L2CAPSpokesMan {
	public L2CAPScribe(etxt*devName) {
		base(devName);
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
		uint8 cmd_id = resp.char_at(10);
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
			etxt dlg = etxt.stack(128);
                	dlg.printf("onL2CAPInfoRequest");
                	HCIExecRule(&dlg);
		}
		return 0;
	}
}
