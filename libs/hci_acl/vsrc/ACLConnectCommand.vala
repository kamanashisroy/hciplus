using aroop;
using shotodol;
using hciplus;

public class hciplus.ACLConnectCommand : shotodol.M100Command {
	etxt prfx;
	ACLSpokesMan spkr;
	enum Options {
		DEV_ID = 1,
		RECEIVE,
	}
	public ACLConnectCommand(ACLSpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt dev = etxt.from_static("-devid");
		etxt devHelp = etxt.from_static("Bluetooth device ID");
		etxt receive = etxt.from_static("-receive");
		etxt receiveHelp = etxt.from_static("It is an incoming connection, and we want to allow the connection.");
		addOption(&dev, M100Command.OptionType.INT, Options.DEV_ID, &devHelp);
		addOption(&receive, M100Command.OptionType.NONE, Options.RECEIVE, &receiveHelp);
	}

	~ACLConnectCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("acl");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		SearchableSet<txt> vals = SearchableSet<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		container<txt>? mod;
		if((mod = vals.search(Options.DEV_ID, match_all)) == null) {
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		}
		int id = mod.get().to_int();
		bool receving = false;
		if((mod = vals.search(Options.RECEIVE, match_all)) != null) receving = true;
		if(receving) {
			spkr.receiveACLByID(id);
		} else {
			spkr.connectACLByID(id);
		}
		return 0;
	}
}
