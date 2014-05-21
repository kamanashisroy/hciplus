using aroop;
using hciplus;

public class hciplus.L2CAPConversation : Replicable {
	public uint16 conversationID;
	public L2CAPConversation(uint16 gConversionID) {
		conversationID = gConversionID;
	}
}

public class hciplus.L2CAPConnection : Replicable {
	private hashable_ext _ext;
	public uint mtu;
	public uint hisToken;
	public bool mtuIsSet;
	public L2CAPConnection() {
	}
	public void build() {
		hisToken = 0;
		mtu = 256;
		mtuIsSet = false;
	}
}

public class hciplus.L2CAPSpokesMan : hciplus.ACLScribe {
	protected ArrayList<L2CAPConversation?>l2capConvs;
	protected Factory<L2CAPConnection>l2capForge;
	int count;
	uint16 convId;
	protected uint8 cmdId;
	enum L2CAPCommand {
		CONNECT_REQUEST = 0x02,
		CONNECTION_RESPONSE = 0x03,
		INFORMATION_REQUEST = 0x0a,
		INFORMATION_RESPONSE = 0x0b,
		CONFIGURE_REQUEST = 0x04,
		CONFIGURE_RESPONSE = 0x05,
	}

	public L2CAPSpokesMan(etxt*devName) {
		base(devName);
		l2capConvs = ArrayList<L2CAPConversation?>();
		l2capForge = Factory<L2CAPConnection>.for_type(2, 4, factory_flags.EXTENDED | factory_flags.SWEEP_ON_UNREF | factory_flags.HAS_LOCK);
		count = 0;
		convId = 0;
		cmdId = 0;
		cmds.register(new hciplus.L2CAPCommand(this));
	}

	~L2CAPSpokesMan() {
		l2capConvs.destroy();
		l2capForge.destroy();
	}

	public enum InformationType {
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

	public void sendL2CAPConfigureRequest(int aclHandle, int l2capConnectionID, int l2capConnectionToken) {
		L2CAPConnection?lcon = l2capForge.get(l2capConnectionToken);
		if(lcon == null) {
			etxt dlg = etxt.stack(128);
			dlg.printf("L2CAP connection(%d) not found", l2capConnectionToken);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, &dlg);
			return;
		}
		etxt pkt = etxt.stack(64);
		pkt.concat_char(L2CAPCommand.CONFIGURE_REQUEST);
		cmdId++;
		pkt.concat_char(cmdId); // command identifier
		concat_16bit(&pkt, 8); // length
		concat_16bit(&pkt, (uint16)lcon.hisToken); // destination token
		//concat_16bit(&pkt, l2capConnectionToken); // destination token
		concat_16bit(&pkt, 0); // not continued
		pkt.concat_char(1); // MTU
		pkt.concat_char(2); // length
		concat_16bit(&pkt, 256); // mtu = 256
		sendL2CAPContent(aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPConfigureResponse(int aclHandle, int l2capConnectionID, int l2capConnectionToken, uchar gCmdID) {
		L2CAPConnection?lcon = l2capForge.get(l2capConnectionToken);
		if(lcon == null) {
			etxt dlg = etxt.stack(128);
			dlg.printf("L2CAP connection(%d) not found", l2capConnectionToken);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, &dlg);
			return;
		}
		etxt pkt = etxt.stack(64);
		pkt.concat_char(L2CAPCommand.CONFIGURE_RESPONSE);
		pkt.concat_char(gCmdID); // command identifier
		concat_16bit(&pkt, 6);
		concat_16bit(&pkt, l2capConnectionToken); // destination token
		//concat_16bit(&pkt, (uint16)lcon.hisToken); // destination token
		concat_16bit(&pkt, 0); // not continued
		concat_16bit(&pkt, 0); // status = 0
		sendL2CAPContent(aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPFixedChannelsSupportedInfo(uchar command_identifier, int aclHandle, int l2capConversationID) {
		etxt pkt = etxt.stack(64);
		concat_16bit(&pkt, InformationType.FIXED_CHANNELS_SUPPORTED); // extended features mask
		concat_16bit(&pkt, 0); // Result -> success
		// features ..
		concat_32bit(&pkt, FixedChannels.L2CAP_SIGNALING_CHANNEL | FixedChannels.CONNECTIONLESS_RECEPTION); 
		concat_32bit(&pkt, 0); 
		
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending information");
		sendL2CAPInfoCommon(command_identifier, aclHandle, l2capConversationID, &pkt);
	}

	public void sendL2CAPExtendedFeaturesMaskInfo(uchar command_identifier, int aclHandle, int l2capConversationID) {
		etxt pkt = etxt.stack(64);
		concat_16bit(&pkt, InformationType.EXTENDED_FEATURES_MASK); // extended features mask
		concat_16bit(&pkt, 0); // Result -> success
		// features ..
		concat_32bit(&pkt, ExtendedFeaturesMask.ENHANCED_RETRNASMISSION_MODE | ExtendedFeaturesMask.STREAMING_MODE | ExtendedFeaturesMask.FCS | ExtendedFeaturesMask.FIXED_CHANNELS); 
		
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending information");
		sendL2CAPInfoCommon(command_identifier, aclHandle, l2capConversationID, &pkt);
	}

	public void connectL2CAP(uchar l2type, int aclHandle, int l2capConnectionID) {
		L2CAPConnection x = l2capForge.alloc_full(0,1);
		x.build();
		int token = ((Hashable)x).get_token();
		etxt pkt = etxt.stack(64);
		pkt.concat_char(L2CAPCommand.CONNECT_REQUEST);
		cmdId++;
		pkt.concat_char(cmdId); // command identifier
		concat_16bit(&pkt, 4); // command length
		concat_16bit(&pkt, 1); // SDP
		concat_16bit(&pkt, token); // source CID
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP sending connect");
		sendL2CAPContent(aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPInfoCommon(uchar command_identifier, int aclHandle, int l2capConnectionID, etxt*gPkt) {
		etxt pkt = etxt.stack(64);
		pkt.concat_char(L2CAPCommand.INFORMATION_RESPONSE);
		pkt.concat_char(command_identifier);
		concat_16bit(&pkt, gPkt.length());
		pkt.concat(gPkt); // features
		sendL2CAPContent(aclHandle, l2capConnectionID, &pkt);
	}

	public void sendL2CAPContent(int aclHandle, int l2capConnectionID, etxt*gPkt) {
		etxt pkt = etxt.stack(64);
		concat_16bit(&pkt, gPkt.length()); // length of l2cap packet
		concat_16bit(&pkt, l2capConnectionID); // Connection ID
		pkt.concat(gPkt); // content
		sendACLData(aclHandle, &pkt);
	}
}

