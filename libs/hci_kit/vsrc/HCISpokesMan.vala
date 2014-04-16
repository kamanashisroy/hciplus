using aroop;
using hciplus;

public class hciplus.HCISpokesMan : hciplus.HCIEventBroker {
	enum HCICommand {
		INQUIRY = 0x01,
	}
	public enum HCICommandType {
		HCI_LINK_CONTROL = 0x01,
	}
	public HCISpokesMan(etxt*devName) {
		base(devName);
	}

	public void inquiry() {
#if false
		/* FIXME: Check if lap is valid first */
		/* Set default lap */
		lap[0] = 0x33;
		lap[1] = 0x8b;
		lap[2] = 0x9e;
		inq_res->nbr_of_units = 0;
		c_pkt.type = CMD_PKT;
		c_pkt.opcode = hci_put_opcode(INQUIRY, HCI_LC);
		memcpy(c_pkt.data, lap, 3);
		c_pkt.data[3] = inq_len;
		c_pkt.data[4] = num_resp;
		c_pkt.len = 5;
		tmp = send_inq_cmd_block((u8*) &c_pkt,
					 c_pkt.len + CMD_HDR_LEN + HCI_HDR_LEN,
					 inq_len);
#endif
		etxt pkt = etxt.stack(7);
		pkt.concat_char(0x33);
		pkt.concat_char(0x8b);
		pkt.concat_char(0x9e);
		pkt.concat_char(0x4); // inquiry length
		pkt.concat_char(0x4); // number of responses
		hos.writeCommand(HCICommandType.HCI_LINK_CONTROL, HCICommand.INQUIRY, &pkt);
	}
}

