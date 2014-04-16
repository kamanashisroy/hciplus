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
		LIST,
		ACL_CONNECT,
		RESET,
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
		etxt list = etxt.from_static("-l");
		etxt list_help = etxt.from_static("List devices");
		etxt acl_connect = etxt.from_static("-acl");
		etxt acl_connect_help = etxt.from_static("Create acl connection");
		etxt reset = etxt.from_static("-r");
		etxt reset_help = etxt.from_static("Reset connection");
		addOption(&up, M100Command.OptionType.TXT, Options.UP, &up_help);
		addOption(&down, M100Command.OptionType.NONE, Options.DOWN, &down_help); 
		addOption(&scan, M100Command.OptionType.NONE, Options.SCAN, &scan_help); 
		addOption(&list, M100Command.OptionType.NONE, Options.LIST, &list_help); 
		addOption(&acl_connect, M100Command.OptionType.TXT, Options.ACL_CONNECT, &acl_connect_help); 
		addOption(&reset, M100Command.OptionType.NONE, Options.RESET, &reset_help); 
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
			if((mod = vals.search(Options.RESET, match_all)) != null) shell.reset();
			if((mod = vals.search(Options.LIST, match_all)) != null) shell.list(pad);
			if((mod = vals.search(Options.ACL_CONNECT, match_all)) != null) shell.ACLConnect(mod.get().to_int(), pad);
			bye(pad, true);
			return 0;
		} while(false);
		bye(pad, false);
		return 0;
	}
}
