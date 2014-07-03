using aroop;
using shotodol;
using hciplus;

public class hciplus.L2CAPCommand : shotodol.M100Command {
	etxt prfx;
	L2CAPSpokesMan spkr;
	enum Options {
		ACL_HANDLE = 1,
		L2CAP_CID,
		L2CAP_COMMAND_IDENTIFIER,
		L2CAP_CONNECTION_TOKEN,
		L2CAP_TYPE,
		CONNECT,
		ACCEPT,
		CONFIGURE_REQUEST,
		CONFIGURE_RESPONSE,
	}
	public L2CAPCommand(L2CAPSpokesMan gspkr) {
		base();
		spkr = gspkr;
		addOptionString("-acl", M100Command.OptionType.INT, Options.ACL_HANDLE, "acl handle.");
		addOptionString("-l2cap", M100Command.OptionType.INT, Options.L2CAP_CID, "l2cap cid.");
		addOptionString("l2captp", M100Command.OptionType.INT, Options.L2CAP_TYPE, "l2cap request type.");
		addOptionString("-l2capcontoken", M100Command.OptionType.INT, Options.L2CAP_CONNECTION_TOKEN, "l2cap connection token.");
		addOptionString("-l2capcmdid", M100Command.OptionType.INT, Options.L2CAP_COMMAND_IDENTIFIER, "Identifier for the command to response to.");
		addOptionString("-connect", M100Command.OptionType.INT, Options.CONNECT, "Create a l2cap connection");
		addOptionString("-accept", M100Command.OptionType.NONE, Options.ACCEPT, "Accept a l2cap connection.");
		addOptionString("-confreq", M100Command.OptionType.NONE, Options.CONFIGURE_REQUEST, "Send l2cap configuration request");
		addOptionString("-confresp", M100Command.OptionType.NONE, Options.CONFIGURE_RESPONSE, "Send l2cap configuration response.");
	}

	~L2CAPCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("l2cap");
		return &prfx;
	}

	public void sendL2CAPInfo(int l2type, uchar command_identifier, int aclHandle, int l2capConversationID) {
		if(l2type == L2CAPSpokesMan.InformationType.EXTENDED_FEATURES_MASK)
			spkr.sendL2CAPExtendedFeaturesMaskInfo(command_identifier, aclHandle, l2capConversationID);
		else if(l2type == L2CAPSpokesMan.InformationType.FIXED_CHANNELS_SUPPORTED)
			spkr.sendL2CAPFixedChannelsSupportedInfo(command_identifier, aclHandle, l2capConversationID);
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		ArrayList<txt> vals = ArrayList<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		int aclHandle = -1;
		int l2capHandle = -1;
		int l2type = 2;
		int l2capConnectionToken = 0;
		int cmdId = 0;
		txt? arg;
		if((arg = vals[Options.ACL_HANDLE]) == null) {
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		}
		if(arg.is_empty_magical())
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		aclHandle = arg.to_int();
		if((arg = vals[Options.L2CAP_CID]) == null) {
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		}
		if(arg.is_empty_magical())
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		l2capHandle = arg.to_int();
		if((arg = vals[Options.L2CAP_TYPE]) != null) {
			l2type = arg.to_int();
		}
		if((arg = vals[Options.L2CAP_COMMAND_IDENTIFIER]) != null) {
			cmdId = arg.to_int();
		}
		if((arg = vals[Options.L2CAP_CONNECTION_TOKEN]) != null) {
			l2capConnectionToken = arg.to_int();
		}
		if((arg = vals[Options.CONNECT]) != null) {
			int proto = 1; // SDP
			proto = arg.to_int();
			spkr.connectL2CAP((uchar)l2type, aclHandle, l2capHandle, proto);
			return 0;
		}
		if(vals[Options.ACCEPT] != null) {
			spkr.acceptL2CAP(aclHandle, l2capHandle, (aroop_uword8)cmdId, l2capConnectionToken);
			return 0;
		}
		if(vals[Options.CONFIGURE_REQUEST] != null) {
			spkr.sendL2CAPConfigureRequest(aclHandle, l2capHandle, l2capConnectionToken);
			return 0;
		}
		if(vals[Options.CONFIGURE_RESPONSE] != null) {
			spkr.sendL2CAPConfigureResponse(aclHandle, l2capHandle, l2capConnectionToken, (aroop_uword8)cmdId);
			return 0;
		}
		sendL2CAPInfo(l2type, (aroop_uword8)cmdId, aclHandle, l2capHandle);
		return 0;
	}
}
