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
		addOptionString("-devid", M100Command.OptionType.INT, Options.DEV_ID, "Bluetooth device ID");
		addOptionString("-receive", M100Command.OptionType.NONE, Options.RECEIVE, "It is an incoming connection, and we want to allow the connection.");
	}

	~ACLConnectCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("acl");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		ArrayList<txt> vals = ArrayList<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		txt? arg;
		if((arg = vals[Options.DEV_ID]) == null) {
			throw new M100CommandError.ActionFailed.INSUFFICIENT_ARGUMENT("Insufficient argument");
		}
		int id = arg.to_int();
		bool receving = false;
		if(vals[Options.RECEIVE] != null) receving = true;
		if(receving) {
			spkr.receiveACLByID(id);
		} else {
			spkr.connectACLByID(id);
		}
		return 0;
	}
}
