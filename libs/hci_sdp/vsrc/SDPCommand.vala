using aroop;
using shotodol;
using hciplus;

public class hciplus.L2CAPCommand : shotodol.M100Command {
	etxt prfx;
	L2CAPSpokesMan spkr;
	enum Options {
		ACL_HANDLE = 1,
		L2CAP_CID,
	}
	public L2CAPCommand(L2CAPSpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt aclHandle = etxt.from_static("-acl");
		etxt l2capHandle = etxt.from_static("-l2cap");
		etxt aclHelp = etxt.from_static("acl handle");
		etxt l2capHelp = etxt.from_static("l2cap cid");
		addOption(&aclHandle, M100Command.OptionType.INT, Options.ACL_HANDLE, &aclHelp);
		addOption(&l2capHandle, M100Command.OptionType.INT, Options.L2CAP_CID, &l2capHelp);
	}

	~L2CAPCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("l2cap");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) {
		greet(pad);
		int ecode = 0;
		SearchableSet<txt> vals = SearchableSet<txt>();
		parseOptions(cmdstr, &vals);
		int aclHandle = -1;
		int l2capHandle = -1;
		do {
			container<txt>? mod;
			if((mod = vals.search(Options.ACL_HANDLE, match_all)) == null) {
				break;
			}
			unowned txt ? arg = mod.get();
			if(arg.is_empty_magical())
				break;
			aclHandle = arg.to_int();
			if((mod = vals.search(Options.L2CAP_CID, match_all)) == null) {
				break;
			}
			arg = mod.get();
			if(arg.is_empty_magical())
				break;
			l2capHandle = arg.to_int();
			//spkr.L2CAPSendInfo(l2type, aclHandle, l2capHandle);
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
