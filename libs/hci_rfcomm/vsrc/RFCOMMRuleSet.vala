using aroop;
using hciplus;


public class hciplus.RFCOMMRuleSet : hciplus.RFCOMMScribe {
#if false
	shotodol.M100Script? script;
	shotodol.StandardOutputStream stdo;
#endif
	public RFCOMMRuleSet(etxt*devName) {
		base(devName);
#if false
		script = null;
#endif
		hciplus.RFCOMMCommand cmd = new hciplus.RFCOMMCommand(this);
		cmds.register(cmd);
#if false
		stdo = new shotodol.StandardOutputStream();
		etxt rls = etxt.from_static("./hci_kit_rulset.mk");
		RFCOMMLoadRules(&rls);
#endif
	}
	~RFCOMMRuleSet() {
	}
#if false
	public void RFCOMMLoadRules(etxt*fn) {
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
#endif
#if 0
	public int RFCOMMinit() {
		etxt dlg = etxt.stack(128);
		dlg.printf("onload");
		RFCOMMExecRule(&dlg);
		return 0;
	}
	protected override int	onRFCOMMRegisterChannelSuccessful(RFCOMMService service) {
		etxt dlg = etxt.stack(128);
		dlg.printf("onchannel %d", service.channel);
		RFCOMMExecRule(&dlg);
		return 0;
	}
	protected override int onRFCOMMConnectionSuccessful(RFCOMMSession s) {
		etxt dlg = etxt.stack(128);
		dlg.printf("onaccept %d", s.handle);
		RFCOMMExecRule(&dlg);
		return 0;
	}
#endif
}
