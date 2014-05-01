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
	enum RFCOMMEvent {
		EVT_REGISTER_PERSISTENT_CHANNEL = 0x86,
	}
	public RFCOMMScribe(etxt*devName) {
		base(devName);
		count = 0;
		sessions = ArrayList<RFCOMMSession?>();
		services = ArrayList<RFCOMMService?>();
#if false
		subscribe(RFCOMMEvent.EVT_REGISTER_PERSISTENT_CHANNEL , onRFCOMMPersistentChannelRegistered);
		subscribe(RFCOMMCommand.INCOMING_CONNECTION , onRFCOMMIncomingConnection);
		subscribe(RFCOMMCommand.CONNECTION_COMPLETE , onRFCOMMConnectionComplete);
		subscribe(RFCOMMCommand.DISCONNECT_COMPLETE , onRFCOMMDisconnect);
#endif
	}

	~RFCOMMScribe() {
		sessions.destroy();
	}

	protected virtual int	onRFCOMMRegisterChannelSuccessful(RFCOMMService service) {
		return 0;
	}

	int onRFCOMMPersistentChannelRegistered(etxt*buf) {
		if(buf.char_at(4) != 0) {
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.ERROR, 0, 0, "RFCOMM channel registration failed");
		} else {
			RFCOMMService service = new RFCOMMService();
			service.channel = buf.char_at(5);
			services.set(service.channel, service);
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "RFCOMM channel registered");
			onRFCOMMRegisterChannelSuccessful(service);
		}
		return 0;
	}

	int onRFCOMMIncomingConnection(etxt*buf) {
		etxt resp = etxt.same_same(buf);
		resp.shift(HCIPacket.EVENT_PACKET_HEADER_LEN); // header length + plen
		RFCOMMSession sess = new RFCOMMSession();
		sess.remote_channel = resp.char_at(8);
		sess.copyaddr(&resp);
		sess.handle = (((uint16)resp.char_at(10)) << 8) | ((uint16)resp.char_at(9));
		sess.state = RFCOMMSession.RFCOMMState.INCOMING;
		//sessions.set(count, sess);
		sessions.set(sess.handle, sess);
		count++;
		count=count & ((1<<30) - 1);
		etxt dlg = etxt.stack(128);
		dlg.printf("RFCOMM Accept incoming connection [channel %d, handle %d]", sess.remote_channel, sess.handle);
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
		return 0;
	}

	int onRFCOMMDisconnect(etxt*buf) {
		int handle = (((uint16)buf.char_at(HCIPacket.EVENT_PACKET_HEADER_LEN+1)) << 8) | ((uint16)buf.char_at(HCIPacket.EVENT_PACKET_HEADER_LEN));
		RFCOMMSession?sess = sessions.get(handle);
		if(sess == null) {
			return 0;
		}
		sess.state = RFCOMMSession.RFCOMMState.CLOSED;
		sessions.set(handle, null);
		etxt dlg = etxt.stack(128);
		dlg.printf("RFCOMM closed [handle %d]", handle);
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
		return 0;
	}

	protected virtual int onRFCOMMConnectionSuccessful(RFCOMMSession s) {
		return 0;
	}

	int onRFCOMMConnectionComplete(etxt*buf) {
		int status = buf.char_at(HCIPacket.EVENT_PACKET_HEADER_LEN);
		int handle = (((uint16)buf.char_at(HCIPacket.EVENT_PACKET_HEADER_LEN+2)) << 8) | ((uint16)buf.char_at(HCIPacket.EVENT_PACKET_HEADER_LEN+1));
		RFCOMMSession?sess = sessions.get(handle);
		if(sess == null) {
			return 0;
		}
		etxt dlg = etxt.stack(128);
		if(status == 0) {
			sess.state = RFCOMMSession.RFCOMMState.CONNECTED;
			dlg.printf("RFCOMM connected [handle %d]", handle);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
			onRFCOMMConnectionSuccessful(sess);
		} else {
			sess.state = RFCOMMSession.RFCOMMState.DISCONNECTED;
			sessions.set(handle, null);
			dlg.printf("RFCOMM connect failure [handle %d]", handle);
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
		}
		return 0;
	}
}
