using aroop;
using hciplus;

public class hciplus.L2CAPStream : Replicable {
	public uint16 psm;
	public uint16 localChannel;
	public uint8 id;
	public enum L2CAPState {
		CONNECTING,
		CONNECTED,
		CLOSED,
	}
	public L2CAPState state;
	public L2CAPStream(uint16 gLocalChannel) {
		localChannel = gLocalChannel;
		state = L2CAPState.CONNECTING;
	}
}

public class hciplus.L2CAPSpokesMan : hciplus.ACLScribe {
	ArrayList<L2CAPStream?>l2capCloset;
	int count;
	enum L2CAPCommand {
		CONNECT = 0x02,
	}

	public L2CAPSpokesMan(etxt*devName) {
		base(devName);
		l2capCloset = ArrayList<L2CAPStream?>();
		count = 0;
	}

	~L2CAPSpokesMan() {
		l2capCloset.destroy();
	}

	public void L2CAPConnect(BluetoothDevice to, int localChannel) {
		L2CAPStream strm = new L2CAPStream((uint16)localChannel);
		l2capCloset[count++] = strm;
		count++;
		count=count & ((1<<30) - 1);
		etxt pkt = etxt.stack(10);
#if false
typedef struct sig_cmd {
        u8 code;
        u8 id;
        u16 len;
        u8 data[0]; 
} __attribute__ ((packed)) sig_cmd;
#endif
		pkt.concat_char(L2CAPCommand.CONNECT); // command
		pkt.concat_char(strm.id); // channel id
		concat_16bit(&pkt, 4); // connection request size
#if false
typedef struct sig_conreq {
        u16 psm;
        CID src_cid; /* sending rsp */
} __attribute__ ((packed)) sig_conreq;
#endif
		concat_16bit(&pkt, strm.psm);
		concat_16bit(&pkt, strm.localChannel);
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP Connecting");
		sendACLData(&pkt);
	}
}

