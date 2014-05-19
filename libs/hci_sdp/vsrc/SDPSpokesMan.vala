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
	int count;

	public SDPSpokesMan(etxt*devName) {
		base(devName);
		sdpTransactions = ArrayList<SDPTransaction?>();
		count = 0;
		cmds.register(new hciplus.SDPCommand(this));
	}

	~SDPSpokesMan() {
		sdpTransactions.destroy();
	}

	public void SDPConnect(int aclHandle, int l2capCID) {
		etxt pkt = etxt.stack(10);
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP:SDP Connecting");
		int clen = 18;
		concatL2CAPHeader(&pkt, clen);
		
		pkt.concat_uchar(6); // service search attribute request
		pkt.concat16(tid);
		pkt.concat16(clen-3);
		pkt.concat16(0x0335); // search pattern
		pkt.concat(19);
		pkt.concat(11);
		pkt.concat(13);
		pkt.concat16(65535); // maximum attribute byte count
		pkt.concat(a);
		pkt.concat16(0); // starting from 0
		pkt.concat16(f); // to f
		pkt.concat(0); // end
		sendL2CAPData(handle, &pkt);
	}
}

