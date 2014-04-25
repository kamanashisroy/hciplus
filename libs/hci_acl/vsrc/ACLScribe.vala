using aroop;
using hciplus;

public class hciplus.ACLScribe : hciplus.ACLSpokesMan {
	public ACLScribe(etxt*devName) {
		base(devName);
		subscribe_for_command(ACLCommand.CREATE_CONNECTION , onACLConnection);
	}

	int onACLConnection(etxt*buf) {
		if(buf.char_at(4) != 0) {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "ACL connection failed");
		} else {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "ACL connection successful");
		}
		return 0;
	}
}
