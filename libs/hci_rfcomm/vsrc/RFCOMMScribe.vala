using aroop;
using hciplus;

public class hciplus.RFCOMMScribe : hciplus.RFCOMMSpokesMan {
	public RFCOMMScribe(etxt*devName) {
		base(devName);
		subscribe_for_command(RFCOMMCommand.CREATE_CONNECTION , onRFCOMMConnection);
	}

	int onRFCOMMConnection(etxt*buf) {
		if(buf.char_at(4) != 0) {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "RFCOMM connection failed");
		} else {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "RFCOMM connection successful");
		}
		return 0;
	}
}
