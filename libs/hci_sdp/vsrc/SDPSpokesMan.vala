using aroop;
using hciplus;

public class hciplus.SDPTransaction : Replicable {
	public uint16 transactionID;
	public SDPTransaction(uint16 gTransactionID) {
		transactionID = gTransactionID;
	}
}

public class hciplus.SDPSpokesMan : hciplus.L2CAPScribe {
	protected ArrayList<SDPTransaction?>sdpTransactions;
	uint16 tidCount;

	public SDPSpokesMan(etxt*devName) {
		base(devName);
		sdpTransactions = ArrayList<SDPTransaction?>();
		tidCount = 0;
		cmds.register(new hciplus.SDPCommand(this));
	}

	~SDPSpokesMan() {
		sdpTransactions.destroy();
	}

	enum SDPParams {
		SERVICE_SEARCH = 0x35,
	}

	enum SDPPacket {
		SERVICE_SEARCH_ATTRIBUTE_REQUEST = 6,
	}

	public void SDPPrepareParamAttributeList(etxt*param) {
		param.concat_char(SDPParams.SERVICE_SEARCH);
		param.concat_char(5); // length 
		param.concat_char(0x0a); // list attributes ids
		param.concat_char(0); // list attributes ids
		param.concat_char(0); // list attributes ids
		param.concat_char(0xFF); // list attributes ids
		param.concat_char(0xFF); // list attributes ids
		param.concat_char(0); // continue
	}

	public void SDPPrepareParamAskProto(etxt*param, uchar proto1, uchar proto2, uchar proto3, uint16 size) {
		param.concat_char(SDPParams.SERVICE_SEARCH);
		param.concat_char(3); // length 
		param.concat_char(proto1);
		param.concat_char(proto2);
		param.concat_char(proto3);
		if(size != 0) {
			param.concat_char((uchar)((size >> 8) & 0xFF)); // maximum response attribute byte count (msb first)
		}
		param.concat_char((uchar)(size & 0xFF)); // maximum response attribute byte count (msb first)
	}

	public void SDPPrepareParam(etxt*param) {
#if false
		SDPPrepareParamAskProto(param, 0x19, 0x11, 0x1e, 0x00, 0xf0); // ask handfree
		SDPPrepareParamAskProto(param, 0x09, 0x00, 0x01, 0x00, 0x00); // ask service class
#endif
		SDPPrepareParamAskProto(param, 0x19, 0x01, 0x00, 0x0ff0); // ask l2cap
		SDPPrepareParamAttributeList(param);
	}

	public void SDPSearch(int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(64);
		etxt params = etxt.stack(64);
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP:SDP Connecting");

		SDPPrepareParam(&params);
		pkt.concat_char(SDPPacket.SERVICE_SEARCH_ATTRIBUTE_REQUEST); // service search attribute request
		uint16 tid = tidCount++;
		SDPTransaction?talk = new SDPTransaction(tid);
		sdpTransactions.set(tid, talk);
		concat_16bit(&pkt,tid);
		concat_16bit(&pkt,params.length());
		pkt.concat(&params);
		sendL2CAPContent(aclHandle, 0x40/* | l2capConnectionID*/, &pkt);
	}
}

