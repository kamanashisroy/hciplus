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
		RFCOMM,
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
		etxt rfcomm = etxt.from_static("-rfcomm");
		etxt rfcomm_help = etxt.from_static("RFCOMM initiate");
		addOption(&up, M100Command.OptionType.INT, Options.UP, &up_help);
		addOption(&down, M100Command.OptionType.NONE, Options.DOWN, &down_help); 
		addOption(&scan, M100Command.OptionType.NONE, Options.SCAN, &scan_help); 
		addOption(&list, M100Command.OptionType.NONE, Options.LIST, &list_help); 
		addOption(&acl_connect, M100Command.OptionType.INT, Options.ACL_CONNECT, &acl_connect_help); 
		addOption(&reset, M100Command.OptionType.NONE, Options.RESET, &reset_help); 
		addOption(&rfcomm, M100Command.OptionType.NONE, Options.RFCOMM, &rfcomm_help); 
	}

	~HCICommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("hci");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		SearchableSet<txt> vals = SearchableSet<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		container<txt>? mod;
		if((mod = vals.search(Options.UP, match_all)) != null)shell.up(mod.get());
		if((mod = vals.search(Options.DOWN, match_all)) != null)shell.down();
		if((mod = vals.search(Options.SCAN, match_all)) != null) shell.scan();
		if((mod = vals.search(Options.RESET, match_all)) != null) shell.reset();
		if((mod = vals.search(Options.LIST, match_all)) != null) shell.list(pad);
		if((mod = vals.search(Options.ACL_CONNECT, match_all)) != null) shell.ACLConnect(mod.get().to_int(), pad);
		if((mod = vals.search(Options.RFCOMM, match_all)) != null) shell.rfcomm();
		return 0;
	}
}
