using aroop;
using hciplus;

public delegate int hciplus.HCIEventOccured(etxt*buf);
public class hciplus.HCIEventBroker : hciplus.HCIWatch {
	protected enum HCIEvent {
		COMMAND_STATUS = 0x0F,
		COMMAND_COMPLETE = 0x0E,
	}
	HCIEventOccured subscribers[100];
	HCIEventOccured command_status_subscribers[100];
	public HCIEventBroker(etxt*devName) {
		base(devName);
		subscribe(HCIEvent.COMMAND_STATUS , onCommandStatusEvent);
	}

	public int subscribe(int type, HCIEventOccured oc) {
		core.assert(type < 100);
		subscribers[type] = oc;
		return 0;
	}

	public int subscribe_for_command(int type, HCIEventOccured oc) {
		core.assert(type < 100);
		command_status_subscribers[type] = oc;
		return 0;
	}

	int onCommandStatusEvent(etxt*resp) {
		// get the command ..
		uint8 ctype = resp.char_at(5);
		if(command_status_subscribers[ctype] != null) {
			command_status_subscribers[ctype](resp);
		}
		return 0;
	}

	public override int onEvent(int type, etxt*resp) {
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 20, shotodol.Watchdog.WatchdogSeverity.DEBUG, 0, 0, " -- Event");
		if(subscribers[type] != null) {
			subscribers[type](resp);
		}
		return 0;
	}
}

