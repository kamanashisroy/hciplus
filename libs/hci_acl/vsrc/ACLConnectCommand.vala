using aroop;
using shotodol;
using hciplus;

public class hciplus.ACLConnectCommand : shotodol.M100Command {
	etxt prfx;
	ACLSpokesMan spkr;
	enum Options {
		DEV_ID = 1,
	}
	public ACLConnectCommand(ACLSpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt dev = etxt.from_static("-devid");
		etxt devHelp = etxt.from_static("Bluetooth device ID");
		addOption(&dev, M100Command.OptionType.INT, Options.DEV_ID, &devHelp);
	}

	~ACLConnectCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("acl");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) {
		greet(pad);
		SearchableSet<txt> vals = SearchableSet<txt>();
		parseOptions(cmdstr, &vals);
		do {
			container<txt>? mod;
			if((mod = vals.search(Options.DEV_ID, match_all)) == null) {
				break;
			}
			int id = mod.get().to_int();
			spkr.connectACLByID(id);
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
