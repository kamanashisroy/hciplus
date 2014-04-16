using aroop;
using hciplus;

public class hciplus.ACLSpokesMan : HCIScribe {
	enum ACLCommand {
		CREATE_CONNECTION = 0x05,
		ACL_PACKET_TYPE = 0x0008 | 0x0010 | 0x0400 | 0x0800 | 0x4000 | 0x8000,
	}
	public ACLSpokesMan(etxt*devName) {
		base(devName);
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
		etxt pkt = etxt.stack(14);
		pkt.concat_char(to.rawaddr[0]); // bluetooth address
		pkt.concat_char(to.rawaddr[1]); // bluetooth address
		pkt.concat_char(to.rawaddr[2]); // bluetooth address
		pkt.concat_char(to.rawaddr[3]); // bluetooth address
		pkt.concat_char(to.rawaddr[4]); // bluetooth address
		pkt.concat_char(to.rawaddr[5]); // bluetooth address
		aroop_uword16 ptype = ACLCommand.ACL_PACKET_TYPE;
		pkt.concat_char((aroop_uword8)(ptype & 0xFF)); // pkt_type
		pkt.concat_char((aroop_uword8)(ptype >> 8)); // pkt_type
		pkt.concat_char(to.pscan_rep_mode); // pscan rep mode
		pkt.concat_char(to.pscan_mode); // pscan mode
		pkt.concat_char((aroop_uword8)(to.clock_offset & 0xFF)); // clock offset
		pkt.concat_char((aroop_uword8)(to.clock_offset >> 8)); // clock offset
		//pkt.concat_char(0x0); // clock
		//pkt.concat_char(0x0); // clock
		pkt.concat_char(0x0); // role switch, if we have changed ourself from master to slave
		hos.writeCommand(HCISpokesMan.HCICommandType.HCI_LINK_CONTROL, ACLCommand.CREATE_CONNECTION, &pkt);
	}
}

