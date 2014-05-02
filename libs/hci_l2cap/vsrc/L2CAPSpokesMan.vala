using aroop;
using hciplus;

public class hciplus.L2CAPConversation : Replicable {
	public uint16 conversationID;
	public L2CAPConversation(uint16 gConversionID) {
		conversationID = gConversionID;
	}
}

public class hciplus.L2CAPSpokesMan : hciplus.ACLScribe {
	protected ArrayList<L2CAPConversation?>l2capConvs;
	int count;
	enum L2CAPCommand {
		CONNECT = 0x02,
	}

	public L2CAPSpokesMan(etxt*devName) {
		base(devName);
		l2capConvs = ArrayList<L2CAPConversation?>();
		count = 0;
	}

	~L2CAPSpokesMan() {
		l2capConvs.destroy();
	}

	public void L2CAPConnect(BluetoothDevice to, int localChannel) {
		etxt pkt = etxt.stack(10);
#if false
typedef struct sig_cmd {
        u8 code;
        u8 id;
        u16 len;
        u8 data[0]; 
} __attribute__ ((packed)) sig_cmd;
#endif
#if false
typedef struct sig_conreq {
        u16 psm;
        CID src_cid; /* sending rsp */
} __attribute__ ((packed)) sig_conreq;
#endif
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP Connecting");
		sendACLData(&pkt);
	}
}

