using aroop;
using hciplus;

public class hciplus.RFCOMMSpokesMan : hciplus.ACLScribe {
	enum RFCOMMCommand {
#if false
		REGISTER_PERSISTENT_CHANNEL = 0x46,
#endif
		REGISTER_SERVICE = 0x42,
		INCOMING_CONNECTION = 0x82,
		CONNECTION_COMPLETE = 0x80,
		DISCONNECT_COMPLETE = 0x05,
		ACCEPT_CONNECTION = 0x44,
	}
	public RFCOMMSpokesMan(etxt*devName) {
		base(devName);
	}

#if false
	public void RFCOMMRegisterPersistentChannel(etxt*nm) {
		etxt pkt = etxt.stack(256);
		concat_string(&pkt, nm.to_string());
		pushCommand(HCISpokesMan.HCICommandType.PROTO_STACK, RFCOMMCommand.REGISTER_PERSISTENT_CHANNEL, &pkt);
	}
#endif

	public void RFCOMMRegisterService(int channelId) {
		etxt pkt = etxt.stack(4);
		pkt.concat_char(((uchar)channelId));
		concat_16bit(&pkt, 100); // mtu
		//pushCommand(HCISpokesMan.HCICommandType.PROTO_STACK, RFCOMMCommand.REGISTER_SERVICE, &pkt);
	}


	public void RFCOMMAccept(int handle) {
		etxt pkt = etxt.stack(5);
		concat_16bit(&pkt, handle);
		//pushCommand(HCISpokesMan.HCICommandType.PROTO_STACK, RFCOMMCommand.ACCEPT_CONNECTION, &pkt);
	}
}

