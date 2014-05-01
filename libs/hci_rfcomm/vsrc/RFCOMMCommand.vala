using aroop;
using shotodol;
using hciplus;

public class hciplus.RFCOMMCommand : shotodol.M100Command {
	etxt prfx;
	RFCOMMSpokesMan spkr;
	enum Options {
		ACCEPT = 1,
		GET_CHANNEL,
		REGISTER_SERVICE,
	}
	public RFCOMMCommand(RFCOMMSpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt accept = etxt.from_static("-accept");
		etxt accept_help = etxt.from_static("Accept rfcomm client");
		etxt getchan = etxt.from_static("-channel");
		etxt getchan_help = etxt.from_static("Get channel for an rfcomm service");
		etxt rservice = etxt.from_static("-register");
		etxt rservice_help = etxt.from_static("register service");
		addOption(&accept, M100Command.OptionType.TXT, Options.ACCEPT, &accept_help);
		addOption(&getchan, M100Command.OptionType.TXT, Options.GET_CHANNEL, &getchan_help);
		addOption(&rservice, M100Command.OptionType.TXT, Options.REGISTER_SERVICE, &rservice_help);
	}

	~RFCOMMCommand() {
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
#if false
			if((mod = vals.search(Options.GET_CHANNEL, match_all)) != null)spkr.RFCOMMRegisterPersistentChannel(mod.get());
#endif
			if((mod = vals.search(Options.REGISTER_SERVICE, match_all)) != null)spkr.RFCOMMRegisterService(mod.get().to_int());
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
