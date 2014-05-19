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
		cmds.register(new hciplus.L2CAPCommand(this));
	}

	~L2CAPSpokesMan() {
		l2capConvs.destroy();
	}

	public void L2CAPConnect(BluetoothDevice to, int handle) {
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
		sendACLData(handle, &pkt);
	}

	enum InformationType {
		EXTENDED_FEATURES_MASK = 0x02,
		FIXED_CHANNELS_SUPPORTED = 0x03,
	}

	enum ExtendedFeaturesMask {
		FLOW_CONTROL_MODE = 1,
		RETRANSMISSION_MODE = 1<<1,
		BIDIRECTIONAL_QOS = 1<<2,
		ENHANCED_RETRNASMISSION_MODE = 1<<3,
		STREAMING_MODE = 1<<4,
		FCS = 1<<5,
		EXTENDED_FLOW_SPECIFICATION = 1<<6,
		FIXED_CHANNELS = 1 << 7,
		EXTENDED_WINDOW_SIZE = 1 << 8,
		UNICAST_CONNECTIONLESS_DATA_RECEPTION = 1 << 9,
		
	}

	enum FixedChannels {
		L2CAP_SIGNALING_CHANNEL = 1<<1,
		CONNECTIONLESS_RECEPTION = 1<<2,
	}

	public void L2CAPSendFixedChannelsSupportedInfo(int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(64);
		uint16 clen = 12; // length of command
		concat_16bit(&pkt, clen+4); // length of l2cap packet
		concat_16bit(&pkt, l2capConnectionID); // Connection ID
		pkt.concat_char(0x0b); // information response
		pkt.concat_char(InformationType.FIXED_CHANNELS_SUPPORTED); // command identifier
		concat_16bit(&pkt, clen);
		concat_16bit(&pkt, InformationType.FIXED_CHANNELS_SUPPORTED); // extended features mask
		concat_16bit(&pkt, 0); // Result -> success
		// features ..
		concat_32bit(&pkt, FixedChannels.L2CAP_SIGNALING_CHANNEL | FixedChannels.CONNECTIONLESS_RECEPTION); 
		concat_32bit(&pkt, 0); 
		
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending information");
		sendACLData(aclHandle, &pkt);
	}

	public void L2CAPSendExtendedFeaturesMaskInfo(int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(64);
		uint16 clen = 8; // length of command
		concat_16bit(&pkt, clen+4); // length of l2cap packet
		concat_16bit(&pkt, l2capConnectionID); // Connection ID
		pkt.concat_char(0x0b); // information response
		pkt.concat_char(InformationType.EXTENDED_FEATURES_MASK); // command identifier
		concat_16bit(&pkt, clen);
		concat_16bit(&pkt, InformationType.EXTENDED_FEATURES_MASK); // extended features mask
		concat_16bit(&pkt, 0); // Result -> success
		// features ..
		concat_32bit(&pkt, ExtendedFeaturesMask.ENHANCED_RETRNASMISSION_MODE | ExtendedFeaturesMask.STREAMING_MODE | ExtendedFeaturesMask.FCS | ExtendedFeaturesMask.FIXED_CHANNELS); 
		
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending information");
		sendACLData(aclHandle, &pkt);
	}
	public void L2CAPSendInfo(int l2type, int aclHandle, int l2capConnectionID) {
		if(l2type == InformationType.EXTENDED_FEATURES_MASK)
			L2CAPSendExtendedFeaturesMaskInfo(aclHandle, l2capConnectionID);
		else if(l2type == InformationType.FIXED_CHANNELS_SUPPORTED)
			L2CAPSendFixedChannelsSupportedInfo(aclHandle, l2capConnectionID);
	}
}

