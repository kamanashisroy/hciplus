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
		etxt sabm = etxt.from_static("-sabm");
		etxt sabmHelp = etxt.from_static("set assynchronous balanced mode (start a connection) through an acl connection");
		addOption(&sabm, M100Command.OptionType.INT, Options.SABM, &sabmHelp);
		etxt l2capcid = etxt.from_static("-l2cap");
		etxt l2capcidHelp = etxt.from_static("Conversation ID");
		addOption(&l2capcid, M100Command.OptionType.INT, Options.L2CAP_CID, &l2capcidHelp);
	}

	~RFCOMMCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("rfcomm");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		int ecode = 0;
		SearchableSet<txt> vals = SearchableSet<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		container<txt>? mod = null;
		int cid = 0;
		if((mod = vals.search(Options.L2CAP_CID, match_all)) != null)cid = mod.get().to_int();
		if((mod = vals.search(Options.SABM, match_all)) != null)spkr.RFCOMMSendSABM(mod.get().to_int(), cid);
		return 0;
	}
}
