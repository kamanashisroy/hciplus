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
		addOptionString("-acl", M100Command.OptionType.INT, Options.ACL_HANDLE, "acl handle");
		addOptionString("-l2cap", M100Command.OptionType.INT, Options.L2CAP_CID, "l2cap cid");
	}

	~SDPCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("sdp");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		ArrayList<txt> vals = ArrayList<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		int aclHandle = -1;
		int l2capHandle = -1;
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
		spkr.SDPSearch(aclHandle, l2capHandle);
		return 0;
	}
}
