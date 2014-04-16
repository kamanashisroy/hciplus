using aroop;
using hciplus;

public class hciplus.HCISpokesMan : hciplus.HCICommandStateMachine {
	enum HCICommand {
		INQUIRY = 0x01,
	}
	public enum HCICommandType {
		HCI_LINK_CONTROL = 0x01,
	}
	public HCISpokesMan(etxt*devName) {
		base(devName);
	}

	public void reset() {
		etxt pkt = etxt.stack(128);
		pushCommand(0x03, 0x0003, &pkt);
		pushCommand(0x04, 0x0003, &pkt);
		pushCommand(0x04, 0x0001, &pkt);
		pushCommand(0x04, 0x0009, &pkt);
		pushCommand(0x04, 0x0005, &pkt);
		pushCommand(0x03, 0x0023, &pkt);
		pushCommand(0x03, 0x0014, &pkt);
		pushCommand(0x03, 0x0025, &pkt);
		pushCommand(0x03, 0x0038, &pkt);
		pushCommand(0x03, 0x0039, &pkt);
		pkt.concat_char(0x00);
		pushCommand(0x03, 0x0005, &pkt); // clear all filter
		pkt.trim_to_length(0);
		pkt.concat_char((uchar)(32000 & 0xFF));
		pkt.concat_char((uchar)(32000 >> 8));
		pushCommand(0x03, 0x0016, &pkt); // accept timeout
		pkt.trim_to_length(0);
		pushCommand(0x03, 0x001b, &pkt); // read page scan activity
		pushCommand(0x03, 0x0046, &pkt); // read page scan type
		pushCommand(0x08, 0x0002, &pkt); // LE read buffer size
		pushCommand(0x08, 0x0007, &pkt); // LE read advertising channel tx power
		pushCommand(0x08, 0x000f, &pkt); // LE read white list size
		pushCommand(0x08, 0x0001, &pkt); // LE supported states
		pushCommand(0x04, 0x0002, &pkt); // local supported commands
		pkt.concat_char(0x01);
		pushCommand(0x03, 0x0056, &pkt); // set simple paring mode
		pkt.trim_to_length(0);
		pkt.concat_char(0x02);
		pushCommand(0x03, 0x0045, &pkt); // set inquiry mode
		pkt.trim_to_length(0);
		pushCommand(0x03, 0x0058, &pkt); // read power level while inquiry
		pkt.concat_char(0x01);
		pushCommand(0x04, 0x0004, &pkt); // read local extended feature
		pkt.trim_to_length(0);
		pkt.concat_char(0x02);
		pushCommand(0x03, 0x001A, &pkt); // Write scan enable
		pkt.trim_to_length(0);
		pkt.concat_char(0x0c);
		pkt.concat_char(0x01);
		pkt.concat_char(0x1c);
		pushCommand(0x03, 0x0024, &pkt); // Write class of device
		pkt.trim_to_length(0);
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

