using aroop;
using hciplus;


public class hciplus.HCIRuleSet : hciplus.HCIScribe {
	shotodol.M100Script? script;
	shotodol.StandardOutputStream stdo;
	public HCIRuleSet(etxt*devName) {
		base(devName);
		script = null;
		hciplus.HCIKitCommand cmd = new hciplus.HCIKitCommand(this);
		cmds.register(cmd);
		ProgrammingInstruction cp = new ProgrammingInstruction();
		cp.register(cmds);
		stdo = new shotodol.StandardOutputStream();
		etxt rls = etxt.from_static("./hci_kit_ruleset.mk");
		loadRules(&rls);
	}
	~HCIRuleSet() {
	}
	public void loadRules(etxt*fn) {
		try {
			shotodol.FileInputStream f = new shotodol.FileInputStream.from_file(fn);
			shotodol.LineInputStream lis = new shotodol.LineInputStream(f);
			script = new shotodol.M100Script();
			script.startParsing();
			while(true) {
				try {
					etxt buf = etxt.stack(128);
					if(lis.read(&buf) == 0) {
						break;
					}
					script.parseLine(&buf);
				} catch(IOStreamError.InputStreamError e) {
					break;
				}
			}
			lis.close();
			f.close();
			script.endParsing();
		} catch (IOStreamError.FileInputStreamError e) {
		}
	}
	public void HCIExecRule(etxt*tgt) {
		etxt dlg = etxt.stack(128);
		if(script == null) {
			dlg.printf("target:%s is undefined", tgt.to_string());
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(),10,0,0,0,&dlg);
			return;
		}
		dlg.printf("target:%s\n", tgt.to_string());
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(),10,0,0,0,&dlg);
		script.target(tgt);
		while(true) {
			txt? cmd = script.step();
			if(cmd == null) {
				break;
			}
			//dlg.printf("command:%s\n", cmd.to_string());
			//shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(),10,0,0,0,&dlg);
			// execute command
			cmds.act_on(cmd, stdo);
		}
	}
#if false
	protected override int onHCIReset() {
		etxt dlg = etxt.stack(128);
		dlg.printf("onreset");
		HCIExecRule(&dlg);
		return 0;
	}
#endif
	public override int onSetup() {
		etxt dlg = etxt.stack(128);
		dlg.printf("onhciSetup");
		HCIExecRule(&dlg);
		onCommandComplete(null);
		//base.onSetup();
		return 0;
	}
	protected override int onNewDevice(BluetoothDevice dev) {
		etxt varName = etxt.from_static("newDevice");
		etxt varval = etxt.stack(20);
		dev.copyAddressTo(&varval);
		shotodol.M100Variable val = new shotodol.M100Variable();
		val.set(&varval);
		txt nm = new txt.memcopy_etxt(&varName);
		cmds.vars.set(nm, val);
		etxt dlg = etxt.stack(128);
		dlg.printf("onNewDevice");
		HCIExecRule(&dlg);
		return 0;
	}
}