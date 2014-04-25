using aroop;
using shotodol;
using hciplus;

public class hciplus.RFCOMMCommand : shotodol.M100Command {
	etxt prfx;
	RFCOMMSpokesMan spkr;
	enum Options {
		ACCEPT = 1,
	}
	public RFCOMMCommand(RFCOMMSpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt accept = etxt.from_static("-accept");
		etxt accept_help = etxt.from_static("Open dev");
		addOption(&accept, M100Command.OptionType.TXT, Options.ACCEPT, &accept_help);
	}

	~HCICommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("rfcomm");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) {
		greet(pad);
		int ecode = 0;
		SearchableSet<txt> vals = SearchableSet<txt>();
		parseOptions(cmdstr, &vals);
		do {
			container<txt>? mod;
			if((mod = vals.search(Options.ACCEPT, match_all)) != null)spkr.RFCOMMAccept(mod.get().to_int());
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
