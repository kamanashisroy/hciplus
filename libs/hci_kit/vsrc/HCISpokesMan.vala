using aroop;
using hciplus;

public class hciplus.HCISpokesMan : hciplus.HCICommandStateMachine {
	enum HCICommand {
		INQUIRY = 0x01,
		SCAN_ENABLE=0x001A,
		INQUIRY_MODE=0x45,
		SIMPLE_PAIRING_MODE=0x56,
		CLEAR_WHITE_LIST=0x12,
		WRITE_LOCAL_NAME=0x52,
		LE_SCAN_PARAM=0x0b,
		LE_SCAN_ENABLE=0x0c,
	}
	public enum HCICommandType {
		HCI_LINK_CONTROL = 0x01,
	}
	public HCISpokesMan(etxt*devName) {
		base(devName);
	}

	public void reset() {
		etxt pkt = etxt.stack(512);
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
		pushCommand(0x08, 0x0003, &pkt); // LE local supported features
		pushCommand(0x08, 0x0007, &pkt); // LE read advertising channel tx power
		pushCommand(0x08, 0x000f, &pkt); // LE read white list size
		pushCommand(0x08, 0x0001, &pkt); // LE supported states
		pushCommand(0x04, 0x0002, &pkt); // local supported commands
		pkt.concat_char(0x01); // 0 = off, 1 = on
		pushCommand(0x03, HCICommand.SIMPLE_PAIRING_MODE, &pkt); // set simple paring mode
		pkt.trim_to_length(0);
		pkt.concat_char(0x01); // 0x00 = standard, 0x01 = with RSSI, 0x02 = extended
		pushCommand(0x03, HCICommand.INQUIRY_MODE, &pkt); // set inquiry mode
		pkt.trim_to_length(0);
		pushCommand(0x03, 0x0058, &pkt); // read power level while inquiry
		pkt.concat_char(0x01);
		pushCommand(0x04, 0x0004, &pkt); // read local extended feature
#if false
		pkt.trim_to_length(0);
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(1); // remove all
		pushCommand(0x04, HCICommand.CLEAR_WHITE_LIST, &pkt); // Delete white list
#endif
		pkt.trim_to_length(0);
		pkt.concat_char(0x03); // 0x02 = page scan only, 0x03 inquiry and page scan , 0x00 no scan , 0x01 inquiry only
		pushCommand(0x03, HCICommand.SCAN_ENABLE, &pkt); // Write scan enable
		pkt.trim_to_length(0);
		pkt.concat_char(0x0c);
		pkt.concat_char(0x01);
		pkt.concat_char(0x1c);
		pushCommand(0x03, 0x0024, &pkt); // Write class of device
		pkt.trim_to_length(0);
		pkt.concat_string("hciplus");
		{
			int i = pkt.length();
			int len = 248;
			for(;i<len;i++)pkt.concat_char(0);
		}
		pushCommand(0x03, HCICommand.WRITE_LOCAL_NAME, &pkt); 
		pkt.trim_to_length(0);
		pkt.concat_char(1); // le scan type: passive (0), active (1)
		pkt.concat_char(0x0004); pkt.concat_char(0x0004); /// le scan interval [0x0004,0x4000], unit: 0.625 msec
		pkt.concat_char(0x0004); pkt.concat_char(0x0004); /// le scan window [0x0004,0x4000], unit: 0.625 msec
		pkt.concat_char(0x0); // own address type: public (0), random (1)
		pkt.concat_char(0x0); // scanning filter policy: any (0), only whitelist (1)
		pushCommand(0x08, HCICommand.LE_SCAN_PARAM, &pkt); 
		pkt.trim_to_length(0);
		pkt.concat_char(0x1); // le scan enable:  disabled (0), enabled (1)
		pkt.concat_char(0x0); // filter duplices: disabled (0), enabled (1)
		pushCommand(0x08, HCICommand.LE_SCAN_ENABLE, &pkt); 
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
		//shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 1, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "Enquery");
		hos.writeCommand(HCICommandType.HCI_LINK_CONTROL, HCICommand.INQUIRY, &pkt);
	}
}

