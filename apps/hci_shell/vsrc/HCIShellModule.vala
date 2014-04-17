using aroop;
using shotodol;
using hciplus;

public class hciplus.HCIShellModule : ModulePlugin {
	HCICommand cmd;
	HCIShellTest test;
	public override int init() {
		cmd = new HCICommand();
		test = new HCIShellTest();
		CommandServer.server.cmds.register(cmd);
		UnitTestModule.inst.register(test);
		return 0;
	}

	public override int deinit() {
		CommandServer.server.cmds.unregister(cmd);
		UnitTestModule.inst.unregister(test);
		base.deinit();
		return 0;
	}

	[CCode (cname="get_module_instance")]
	public static Module get_module_instance() {
		return new HCIShellModule();
	}
}
