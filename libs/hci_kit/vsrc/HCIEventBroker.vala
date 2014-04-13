using aroop;
using hciplus;

public delegate int hciplus.HCIEventOccured(etxt*buf);
public class hciplus.HCIEventBroker : hciplus.HCIWatch {
	HCIEventOccured subscribers[10];
	public HCIEventBroker(etxt*devName) {
		base(devName);
	}

	public int subscribe(int type, HCIEventOccured oc) {
		core.assert(type < 10);
		subscribers[type] = oc;
		return 0;
	}
}

