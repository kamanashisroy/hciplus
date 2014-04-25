using aroop;
using hciplus;

public class hciplus.L2CAPScribe : hciplus.L2CAPSpokesMan {
	public L2CAPScribe(etxt*devName) {
		base(devName);
		subscribe_for_command(L2CAPCommand.CREATE_CONNECTION , onL2CAPConnection);
	}

	int onL2CAPConnection(etxt*buf) {
		if(buf.char_at(4) != 0) {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "L2CAP connection failed");
		} else {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "L2CAP connection successful");
		}
		return 0;
	}
}
