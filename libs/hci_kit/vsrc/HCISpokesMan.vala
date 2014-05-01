using aroop;
using hciplus;

/***
 * \addtogroup hcikit
 * @{
 */
public class hciplus.HCISpokesMan : hciplus.HCICommandServer {
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
		HOST_CONTROL_AND_BASE_BAND_COMMAND = 0x03,
	}
	public HCISpokesMan(etxt*devName) {
		base(devName);
	}

	public void concat_16bit(etxt*pkt, int val) {
		uchar c = (uchar)(val&0xFF);
		pkt.concat_char(c);
		c = (uchar)((val&0xFF00) >> 8);
		pkt.concat_char(c);
	}

	public void concat_string(etxt*pkt, string x) {
		pkt.concat_string(x);
		{ // fill
			int i = pkt.length();
			int len = 248;
			for(;i<len;i++)pkt.concat_char(0);
			core.assert(pkt.length() == 248);
		}pkt.concat_char(0);pkt.concat_char(0);pkt.concat_char(0);
	}

	public void reset() {
		etxt pkt = etxt.stack(512);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0003, &pkt);
		pushCommand(0x04, 0x0003, &pkt);
		pushCommand(0x04, 0x0001, &pkt);
		pushCommand(0x04, 0x0009, &pkt);
		pushCommand(0x04, 0x0005, &pkt);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0023, &pkt);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0014, &pkt);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0025, &pkt);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0038, &pkt);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0039, &pkt);
		pkt.concat_char(0x00);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0005, &pkt); // clear all filter
		pkt.trim_to_length(0);
		pkt.concat_char((uchar)(32000 & 0xFF));
		pkt.concat_char((uchar)(32000 >> 8));
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0016, &pkt); // accept timeout
		pkt.trim_to_length(0);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x001b, &pkt); // read page scan activity
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0046, &pkt); // read page scan type
		pushCommand(0x08, 0x0002, &pkt); // LE read buffer size
		pkt.trim_to_length(0);
		pushCommand(0x08, 0x0003, &pkt); // LE local supported features
		pushCommand(0x08, 0x0007, &pkt); // LE read advertising channel tx power
		pushCommand(0x08, 0x000f, &pkt); // LE read white list size
		pushCommand(0x08, 0x001c, &pkt); // LE read supported states
		pkt.trim_to_length(0);
		pkt.concat_char(0xff); // 0xfffffbff07f8bf3d
		pkt.concat_char(0xff);
		pkt.concat_char(0xfb);
		pkt.concat_char(0xff);
		pkt.concat_char(0x07);
		pkt.concat_char(0xf8);
		pkt.concat_char(0xbf);
		pkt.concat_char(0x3d);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0001, &pkt); // set event mask
		pkt.trim_to_length(0);
		pkt.concat_char(0x1f);
		pkt.concat_char(0x00);
		pkt.concat_char(0x00);
		pkt.concat_char(0x00);
		pkt.concat_char(0x00);
		pkt.concat_char(0x00);
		pkt.concat_char(0x00);
		pkt.concat_char(0x00);
		pushCommand(0x08, 0x0001, &pkt); // LE set event mask
		pkt.trim_to_length(0);
		pushCommand(0x04, 0x0002, &pkt); // read local supported commands
		pkt.concat_char(0x01); // 0 = off, 1 = on
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, HCICommand.SIMPLE_PAIRING_MODE, &pkt); // set simple paring mode
		pkt.trim_to_length(0);
		pkt.concat_char(0x01); // 0x00 = standard, 0x01 = with RSSI, 0x02 = extended
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, HCICommand.INQUIRY_MODE, &pkt); // set inquiry mode
		pkt.trim_to_length(0);
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0058, &pkt); // read power level while inquiry
		pkt.concat_char(0x01);
		pushCommand(0x04, 0x0004, &pkt); // read local extended feature
		pkt.trim_to_length(0);
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(0); // 6 bytes of 0
		pkt.concat_char(1); // remove all
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, HCICommand.CLEAR_WHITE_LIST, &pkt); // Delete white list
		pkt.trim_to_length(0);
		pkt.concat_char(0x03); // 0x02 = page scan only, 0x03 inquiry and page scan , 0x00 no scan , 0x01 inquiry only
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, HCICommand.SCAN_ENABLE, &pkt); // Write scan enable
		pkt.trim_to_length(0);
		pkt.concat_char(0x0c); // supports rendering
		pkt.concat_char(0x01); // supports capturing
		pkt.concat_char(0x1c); // supports rendering
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, 0x0024, &pkt); // Write class of device
		pkt.trim_to_length(0);
		pkt.concat_char(0); // FEC required
		etxt device_name = etxt.from_static("hciplus");
		pkt.concat_char((uchar)device_name.length()+1);
		pkt.concat_char(0x09); // device name (09 = device name)
		pkt.concat(&device_name);
		pkt.concat_char(2); // power level length
		pkt.concat_char(0x0a); // power level to follow (0a = power level)
		pkt.concat_char(0x04); // power level value
		pkt.concat_char(0x05); // (supported protocols*2) + 1
		pkt.concat_char(0x03); // 16 bit protocols to follow .. (03 = protocol uuid)
		concat_16bit(&pkt, 0x110a); // 0x110a = Audio source
		concat_16bit(&pkt, 0x1112); // 0x1112 = Handset audio gateway
		{ // fill
			int i = pkt.length();
			int len = 241;
			for(;i<len;i++)pkt.concat_char(0);
			core.assert(pkt.length() == 241);
		}
		pushCommand(HCICommandType.HOST_CONTROL_AND_BASE_BAND_COMMAND, HCICommand.WRITE_LOCAL_NAME, &pkt); 
		pkt.trim_to_length(0);
		pkt.concat_char(1); // le scan type: passive (0), active (1)
		concat_16bit(&pkt, 0x1200); // le scan interval [0x0004,0x4000], unit: 0.625 msec
		concat_16bit(&pkt, 0x1200); // le scan window [0x0004,0x4000], unit: 0.625 msec
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
		pushCommand(HCICommandType.HCI_LINK_CONTROL, HCICommand.INQUIRY, &pkt);
	}
}

/** @} */
