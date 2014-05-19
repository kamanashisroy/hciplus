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

	public void sendL2CAPFixedChannelsSupportedInfo(int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(64);
		concat_16bit(&pkt, InformationType.FIXED_CHANNELS_SUPPORTED); // extended features mask
		concat_16bit(&pkt, 0); // Result -> success
		// features ..
		concat_32bit(&pkt, FixedChannels.L2CAP_SIGNALING_CHANNEL | FixedChannels.CONNECTIONLESS_RECEPTION); 
		concat_32bit(&pkt, 0); 
		
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending information");
		sendL2CAPInfoCommon(InformationType.FIXED_CHANNELS_SUPPORTED, aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPExtendedFeaturesMaskInfo(int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(64);
		concat_16bit(&pkt, InformationType.EXTENDED_FEATURES_MASK); // extended features mask
		concat_16bit(&pkt, 0); // Result -> success
		// features ..
		concat_32bit(&pkt, ExtendedFeaturesMask.ENHANCED_RETRNASMISSION_MODE | ExtendedFeaturesMask.STREAMING_MODE | ExtendedFeaturesMask.FCS | ExtendedFeaturesMask.FIXED_CHANNELS); 
		
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending information");
		sendL2CAPInfoCommon(InformationType.EXTENDED_FEATURES_MASK, aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPInfo(int l2type, int aclHandle, int l2capConnectionID) {
		if(l2type == InformationType.EXTENDED_FEATURES_MASK)
			sendL2CAPExtendedFeaturesMaskInfo(aclHandle, l2capConnectionID);
		else if(l2type == InformationType.FIXED_CHANNELS_SUPPORTED)
			sendL2CAPFixedChannelsSupportedInfo(aclHandle, l2capConnectionID);
	}

	public void connectL2CAP(uchar l2type, int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(64);
		pkt.concat_char(0x02); // connect request
		pkt.concat_char(0x03); // command identifier
		concat_16bit(&pkt, 4); // command length
		concat_16bit(&pkt, 1); // extended features mask
		concat_16bit(&pkt, 0x40); // source CID
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending connect");
		sendL2CAP(aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPInfoCommon(uchar l2capInfoType, int aclHandle, int l2capConnectionID, etxt*gPkt) {
		etxt pkt = etxt.stack(64);
		pkt.concat_char(0x0b); // information response
		pkt.concat_char(l2capInfoType);
		concat_16bit(&pkt, gPkt.length());
		pkt.concat(gPkt); // features
		sendL2CAP(aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAP(int aclHandle, int l2capConnectionID, etxt*gPkt) {
		etxt pkt = etxt.stack(64);
		concat_16bit(&pkt, gPkt.length()); // length of l2cap packet
		concat_16bit(&pkt, l2capConnectionID); // Connection ID
		pkt.concat(gPkt); // information response
		sendACLData(aclHandle, &pkt);
	}
}

