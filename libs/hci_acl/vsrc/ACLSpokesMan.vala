using aroop;
using hciplus;

public class hciplus.ACLConnection : Replicable {
	public BluetoothDevice dev;
	internal uint16 handle;
	protected uint8 linkType;
	protected uint8 encryptionMode;
	protected uint8 maxSlots;
	protected enum ACLState {
		CONNECTING = 0,
		CONNECTED,
		CLOSED,
	}
	protected ACLState state;
	internal ACLConnection.fromConnectionCompleteEvent(etxt*resp) {
		core.assert(resp.char_at(1) == 0x03);
		handle = resp.char_at(4);
		handle |= (resp.char_at(5) << 8);
		linkType = resp.char_at(12);
		encryptionMode = resp.char_at(13);
	}
	internal int update(etxt*resp) {
		if(resp.char_at(1) == 0x1b) { // max slots
			maxSlots = resp.char_at(5);
		}
		return 0;
	}
}

public class hciplus.ACLSpokesMan : hciplus.HCIRuleSet {
	enum ACLCommand {
		CREATE_CONNECTION = 0x05,
		LE_CREATE_CONNECTION = 0x0d,
		ACL_PACKET_TYPE = 0x0008 | 0x0010 | 0x0400 | 0x0800 | 0x4000 | 0x8000,
	}
	protected enum ACLPacket {
		ACL_DATA = 0x02,
	}
	public ACLSpokesMan(etxt*devName) {
		base(devName);
		cmds.register(new hciplus.ACLConnectCommand(this));
	}


	public void LEConnect(BluetoothDevice to) {
		etxt pkt = etxt.stack(128);
		concat_16bit(&pkt, 1000); // scan 625 ms
		concat_16bit(&pkt, 1000); // scan 625 ms
		pkt.concat_char(0); // scanning filter policy: any (0), only whitelist (1)
		pkt.concat_char(0); // peer address type: public (0), random (1)
		pkt.concat_char(to.rawaddr[0]); // bluetooth address
		pkt.concat_char(to.rawaddr[1]); // bluetooth address
		pkt.concat_char(to.rawaddr[2]); // bluetooth address
		pkt.concat_char(to.rawaddr[3]); // bluetooth address
		pkt.concat_char(to.rawaddr[4]); // bluetooth address
		pkt.concat_char(to.rawaddr[5]); // bluetooth address
		pkt.concat_char(0); // own address type: public (0), random (1)
		concat_16bit(&pkt, 80); // connect interval min
		concat_16bit(&pkt, 80); // connect interval max
		concat_16bit(&pkt, 0); // latency
		concat_16bit(&pkt, 2000); // supervision timeout
		concat_16bit(&pkt, 0); // min ce length
		concat_16bit(&pkt, 1000); // max ce length

		pushCommand(HCISpokesMan.HCICommandType.HCI_LINK_CONTROL, ACLCommand.LE_CREATE_CONNECTION, &pkt);
		//hos.writeCommand(HCISpokesMan.HCICommandType.HCI_LINK_CONTROL, ACLCommand.LE_CREATE_CONNECTION, &pkt);
	}

	public void connectACLByID(int id) {
		BluetoothDevice?dev = getBluetoothDevice(id);
		if(dev == null)
			return;
		ACLConnect(dev);
	}

	public void ACLConnect(BluetoothDevice to) {
#if false
typedef struct {
	bdaddr_t	bdaddr;
	uint16_t	pkt_type;
	uint8_t		pscan_rep_mode;
	uint8_t		pscan_mode;
	uint16_t	clock_offset;
	uint8_t		role_switch;
} __attribute__ ((packed)) create_conn_cp;
#endif
		etxt pkt = etxt.stack(14); // plen = 13
		pkt.concat_char(to.rawaddr[0]); // bluetooth address
		pkt.concat_char(to.rawaddr[1]); // bluetooth address
		pkt.concat_char(to.rawaddr[2]); // bluetooth address
		pkt.concat_char(to.rawaddr[3]); // bluetooth address
		pkt.concat_char(to.rawaddr[4]); // bluetooth address
		pkt.concat_char(to.rawaddr[5]); // bluetooth address
		aroop_uword16 ptype = ACLCommand.ACL_PACKET_TYPE;
		ptype = 0xcc18; // packet type
		concat_16bit(&pkt, ptype);
		//pkt.concat_char(to.pscan_rep_mode); // page scan repetition mode
		pkt.concat_char(0x02); // page scan repetition mode
		//pkt.concat_char(to.pscan_mode); // pscan mode
		pkt.concat_char(0x00); // mandatory page scan mode
		aroop_uword16 clock_offset = 0; // to.clock_offset
		concat_16bit(&pkt, clock_offset); // clock offset
		pkt.concat_char(0x1); // role switch, if we have changed ourself from master to slave
#if false
		print("Connect .. %X %X %X \n"
			, pkt.char_at(8)
			, pkt.char_at(9)
			, to.clock_offset);
#endif
		pushCommand(HCISpokesMan.HCICommandType.HCI_LINK_CONTROL, ACLCommand.CREATE_CONNECTION, &pkt);
		//hos.writeCommand(HCISpokesMan.HCICommandType.HCI_LINK_CONTROL, ACLCommand.CREATE_CONNECTION, &pkt);
	}

	public void sendACLData(int handle, etxt*gPkt) {
		etxt pkt = etxt.stack(64);
		pkt.concat_char(ACLPacket.ACL_DATA);
		concat_16bit(&pkt, handle); // handle, PB and BC flag
		concat_16bit(&pkt, gPkt.length()); // length
		int pktlen = pkt.length();
		int payload_len = gPkt.length();
		pkt.concat(gPkt);
		core.assert(pkt.length() == (pktlen+payload_len));
		txWrapperRaw(&pkt);
	}
}

