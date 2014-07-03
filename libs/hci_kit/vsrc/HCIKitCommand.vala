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
		addOptionString("-reset", M100Command.OptionType.NONE, Options.RESET, "Reset hci device.");
		addOptionString("-inquery", M100Command.OptionType.NONE, Options.INQUIRY, "Inquiry devices around.");
	}

	~HCIKitCommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("hcikit");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		ArrayList<txt> vals = ArrayList<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		if(vals[Options.RESET] != null)spkr.reset();
		if(vals[Options.INQUIRY] != null)spkr.inquiry();
		return 0;
	}
}
