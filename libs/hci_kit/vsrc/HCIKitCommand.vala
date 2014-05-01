using aroop;
using shotodol;
using hciplus;

public class hciplus.HCIKitCommand : shotodol.M100Command {
	etxt prfx;
	HCISpokesMan spkr;
	enum Options {
		RESET = 1,
		INQUIRY,
	}
	public HCIKitCommand(HCISpokesMan gspkr) {
		base();
		spkr = gspkr;
		etxt reset = etxt.from_static("-reset");
		etxt reset_help = etxt.from_static("Reset hci device");
		etxt inquiry = etxt.from_static("-inquiry");
		etxt inquiry_help = etxt.from_static("Inquiry devices around");
		addOption(&reset, M100Command.OptionType.NONE, Options.RESET, &reset_help);
		addOption(&inquiry, M100Command.OptionType.NONE, Options.INQUIRY, &inquiry_help);
	}

	~HCIKitCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("hcikit");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) {
		greet(pad);
		int ecode = 0;
		SearchableSet<txt> vals = SearchableSet<txt>();
		parseOptions(cmdstr, &vals);
		do {
			container<txt>? mod;
			if((mod = vals.search(Options.RESET, match_all)) != null)spkr.reset();
			if((mod = vals.search(Options.INQUIRY, match_all)) != null)spkr.inquiry();
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
