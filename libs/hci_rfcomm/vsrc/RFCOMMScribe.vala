using aroop;
using hciplus;


public class hciplus.RFCOMMSession : Replicable {
	public aroop_uword8 rawaddr[6];
	public aroop_uword16 handle;
	public aroop_uword8 local_channel;
	public aroop_uword8 remote_channel;
	public enum RFCOMMState {
		INCOMING = 1,
		ACCEPTING = 2,
		CONNECTED = 3,
		DISCONNECTED = 4,
		CLOSED = 5,
	}
	public RFCOMMState state;
	public void copyaddr(etxt*buf) {
		hciplus_platform.HCIDev.getBluetoothAddress2(buf, rawaddr);
	}
}

public class hciplus.RFCOMMService : Replicable {
	public aroop_uword8 channel;

}

public class hciplus.RFCOMMScribe : hciplus.RFCOMMSpokesMan {
	ArrayList<RFCOMMSession?> sessions;
	ArrayList<RFCOMMService?> services;
	int count;
	public RFCOMMScribe(etxt*devName) {
		base(devName);
		count = 0;
		sessions = ArrayList<RFCOMMSession?>();
		//services = ArrayList<RFCOMMService?>();
	}

	~RFCOMMScribe() {
		sessions.destroy();
		//services.destroy();
	}
}
