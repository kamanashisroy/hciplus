using aroop;
using hciplus;


public class hciplus.RFCOMMRules : hciplus.RFCOMMScribe {
	M100Script? script;
	public RFCOMMRules(etxt*devName) {
		base(devName);
		script = null;
	}
	~RFCOMMRules() {
	}
	public void RFCOMMLoadRules(etxt*fn) {
		try {
			FileInputStream f = new FileInputStream.from_file(fn);
			LineInputStream lis = new LineInputStream(f);
			script = new M100Script();
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
	public void RFCOMMExecRule(etxt*tgt) {
		etxt dlg = etxt.stack(128);
		if(script == null) {
			dlg.printf("target:%s is undefined", tgt.to_string());
			Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(),10,0,0,0,&dlg);
		}
		etxt dlg = etxt.stack(128);
		dlg.printf("target:%s\n", tgt.to_string());
		Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(),10,0,0,0,&dlg);
		script.target(tgt);
		while(true) {
			txt? cmd = script.step();
			if(cmd == null) {
				break;
			}
			dlg.printf("command:%s\n", cmd.to_string());
			Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(),10,0,0,0,&dlg);
			// execute command
			CommandServer.server.act_on(cmd, pad);
		}
	}
}
