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
		addOptionString("-up", M100Command.OptionType.INT, Options.UP, "Open device");
		addOptionString("-down", M100Command.OptionType.NONE, Options.DOWN, "Close device"); 
		addOptionString("-scan", M100Command.OptionType.NONE, Options.SCAN, "Scan device"); 
		addOptionString("-l", M100Command.OptionType.NONE, Options.LIST, "List devices"); 
		addOptionString("-acl", M100Command.OptionType.INT, Options.ACL_CONNECT, "Create acl connection."); 
		addOptionString("-r", M100Command.OptionType.NONE, Options.RESET, "Reset connection"); 
		addOptionString("-rfcomm", M100Command.OptionType.NONE, Options.RFCOMM, "RFCOMM initiate"); 
	}

	~HCICommand() {
	}

	public override etxt*get_prefix() {
		prfx = etxt.from_static("hci");
		return &prfx;
	}

	public override int act_on(etxt*cmdstr, OutputStream pad) throws M100CommandError.ActionFailed {
		ArrayList<txt> vals = ArrayList<txt>();
		if(parseOptions(cmdstr, &vals) != 0) {
			throw new M100CommandError.ActionFailed.INVALID_ARGUMENT("Invalid argument");
		}
		txt? arg = null;
		if((arg = vals[Options.UP]) != null)shell.up(arg);
		if(vals[Options.DOWN] != null)shell.down();
		if(vals[Options.SCAN] != null) shell.scan();
		if(vals[Options.RESET] != null) shell.reset();
		if(vals[Options.LIST] != null) shell.list(pad);
		if((arg = vals[Options.ACL_CONNECT]) != null) shell.ACLConnect(arg.to_int(), pad);
		if(vals[Options.RFCOMM] != null) shell.rfcomm();
		return 0;
	}
}
