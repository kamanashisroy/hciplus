using aroop;
using shotodol;
using hciplus;

public class hciplus.SDPCommand : shotodol.M100Command {
	etxt prfx;
	SDPSpokesMan spkr;
	enum Options {
		ACL_HANDLE = 1,
		L2CAP_CID,
	}
	public SDPCommand(SDPSpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt aclHandle = etxt.from_static("-acl");
		etxt l2capHandle = etxt.from_static("-l2cap");
		etxt aclHelp = etxt.from_static("acl handle");
		etxt l2capHelp = etxt.from_static("l2cap cid");
		addOption(&aclHandle, M100Command.OptionType.INT, Options.ACL_HANDLE, &aclHelp);
		addOption(&l2capHandle, M100Command.OptionType.INT, Options.L2CAP_CID, &l2capHelp);
	}

	~SDPCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("sdp");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		SearchableSet<txt> vals = SearchableSet<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		int aclHandle = -1;
		int l2capHandle = -1;
		container<txt>? mod;
		if((mod = vals.search(Options.ACL_HANDLE, match_all)) == null) {
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		}
		unowned txt ? arg = mod.get();
		if(arg.is_empty_magical())
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		aclHandle = arg.to_int();
		if((mod = vals.search(Options.L2CAP_CID, match_all)) == null) {
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		}
		arg = mod.get();
		if(arg.is_empty_magical())
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		l2capHandle = arg.to_int();
		spkr.SDPSearch(aclHandle, l2capHandle);
		return 0;
	}
}
