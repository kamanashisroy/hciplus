using aroop;
using shotodol;
using hciplus;

public class hciplus.HCICommand : M100Command {
	etxt prfx;
	HCIShell shell;
	enum Options {
		UP = 1,
		DOWN,
		SCAN,
	}
	public HCICommand() {
		base();
		shell = new HCIShell();
		etxt up = etxt.from_static("-up");
		etxt up_help = etxt.from_static("Open dev");
		etxt down = etxt.from_static("-down");
		etxt down_help = etxt.from_static("Close dev");
		etxt scan = etxt.from_static("-scan");
		etxt scan_help = etxt.from_static("Scan dev");
		addOption(&up, M100Command.OptionType.TXT, Options.UP, &up_help);
		addOption(&down, M100Command.OptionType.NONE, Options.DOWN, &down_help); 
		addOption(&scan, M100Command.OptionType.NONE, Options.SCAN, &scan_help); 
	}

	~HCICommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("hci");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) {
		greet(pad);
		int ecode = 0;
		SearchableSet<txt> vals = SearchableSet<txt>();
		parseOptions(cmdstr, &vals);
		do {
			container<txt>? mod;
			if((mod = vals.search(Options.UP, match_all)) != null)shell.up(mod.get());
			if((mod = vals.search(Options.DOWN, match_all)) != null)shell.down();
			if((mod = vals.search(Options.SCAN, match_all)) != null) shell.scan();
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
