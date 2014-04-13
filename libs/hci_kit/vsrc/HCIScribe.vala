using aroop;
using hciplus;

public class hciplus.HCIScribe : hciplus.HCISpokesMan {
	public HCIScribe(etxt*devName) {
		base(devName);
		subscribe(0x22 /* EVT_INQUIRY_RESULT_WITH_RSSI */, onRSSIEvent);
	}

/*
typedef struct {
  bdaddr_t  bdaddr;
  uint8_t   pscan_rep_mode;
  uint8_t   pscan_period_mode;
  uint8_t   dev_class[3];
  uint16_t  clock_offset;
  int8_t    rssi;
} __attribute__ ((packed)) inquiry_info_with_rssi;
 */
	int onRSSIEvent(etxt*buf) {
		etxt addr = etxt.stack(128);
		etxt resp = etxt.same_same(buf);
		resp.shift(HCIPacket.EVENT_PACKET_HEADER_LEN); // header length + plen
		hciplus_platform.HCIDev.getBluetoothAddress(&addr, &resp);
		etxt msg = etxt.stack(128);
		msg.printf("New device identified %s\n", addr.to_string());
		msg.concat_char('\n');
		msg.zero_terminate();
		shotodol.Watchdog.logMsgDoNotUse(core.sourceFileName(), core.sourceLineNo(), &msg);
		return 0;
	}
}
