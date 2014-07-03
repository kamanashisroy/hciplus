using aroop;
using shotodol;
using hciplus;

public class hciplus.RFCOMMCommand : shotodol.M100Command {
	etxt prfx;
	RFCOMMSpokesMan spkr;
	enum Options {
		SABM = 1,
		L2CAP_CID = 1,
	}
	public RFCOMMCommand(RFCOMMSpokesMan gspkr) {
		base();
		spkr = gspkr;
		addOptionString("-sabm", M100Command.OptionType.INT, Options.SABM, "Set assynchronous balanced mode (start a connection) through an acl connection");
		addOptionString("-l2cap", M100Command.OptionType.INT, Options.L2CAP_CID, "Conversation ID");
	}

	~RFCOMMCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("rfcomm");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		int ecode = 0;
		ArrayList<txt> vals = ArrayList<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		txt? arg = null;
		int cid = 0;
		if((arg = vals[Options.L2CAP_CID]) != null)cid = arg.to_int();
		if((arg = vals[Options.SABM]) != null)spkr.RFCOMMSendSABM(arg.to_int(), cid);
		return 0;
	}
}
