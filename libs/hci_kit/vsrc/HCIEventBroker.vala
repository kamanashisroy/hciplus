using aroop;
using hciplus;

/***
 * \addtogroup hcikit
 * @{
 */
public delegate int hciplus.HCIEventOccured(etxt*buf);
public class hciplus.HCIEventBroker : hciplus.HCIWatch {
	protected enum HCIEvent {
		COMMAND_STATUS = 0x0F,
		COMMAND_COMPLETE = 0x0E,
	}
	enum HCIConfig {
		MAX_SUBSCRIBERS = 128,
	}
	HCIEventOccured subscribers[128];
	HCIEventOccured command_status_subscribers[128];
	public HCIEventBroker(etxt*devName) {
		base(devName);
		subscribeForIncomingPacket(0x04, onEvent);
		subscribeForEvent(HCIEvent.COMMAND_STATUS , onCommandStatusEvent);
	}

	public int subscribeForEvent(int type, HCIEventOccured oc) {
		core.assert(type < HCIConfig.MAX_SUBSCRIBERS);
		subscribers[type] = oc;
		return 0;
	}

	public int subscribeForEventOnCommand(int type, HCIEventOccured oc) {
		core.assert(type < HCIConfig.MAX_SUBSCRIBERS);
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

	public int onEvent(etxt*resp) {
		uint etype = resp.char_at(1);
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 20, shotodol.Watchdog.WatchdogSeverity.DEBUG, 0, 0, " -- Event");
		if(subscribers[etype] != null) {
			subscribers[etype](resp);
		}
		return 0;
	}
	protected uint8 getCommandStatus(etxt*resp) {
		return resp.char_at(3);
	}
}

/** @} */
