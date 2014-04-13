using aroop;
using hciplus;

public delegate int hciplus.HCIEventOccured(etxt*buf);
public class hciplus.HCIEventBroker : hciplus.HCIWatch {
	HCIEventOccured subscribers[40];
	public HCIEventBroker(etxt*devName) {
		base(devName);
	}

	public int subscribe(int type, HCIEventOccured oc) {
		core.assert(type < 40);
		subscribers[type] = oc;
		return 0;
	}

	public override int onEvent(int type, etxt*resp) {
		print("There is something .. %d\n", type);
		if(subscribers[type] != null) {
			subscribers[type](resp);
		}
		return 0;
	}
}

