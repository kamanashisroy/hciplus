using aroop;
using hciplus;

/***
 * \addtogroup hcikit
 * @{
 */
public class hciplus.BluetoothDevice : Replicable {
	public aroop_uword8 rawaddr[6];
	public aroop_uword8 pscan_rep_mode;
	public aroop_uword8 pscan_mode;
	public aroop_uword16 clock_offset;
	public void copyAddressTo(etxt*buf) {
		hciplus_platform.HCIDev.getBluetoothAddress2(buf, rawaddr);
	}
}

public class hciplus.HCIScribe : hciplus.HCISpokesMan {
	ArrayList<BluetoothDevice> devices;
	int devCount;
	public HCIScribe(etxt*devName) {
		base(devName);
		subscribeForEvent(0x22 /* EVT_INQUIRY_RESULT_WITH_RSSI */, onRSSIEvent);
		subscribeForEvent(0x2f /* EVT_INQUIRY_RESULT_WITH_RSSI */, onRSSIEvent);
		subscribeForEvent(0x02 /* EVT_INQUIRY_RESULT */, onInquiryResult);
		devices = ArrayList<BluetoothDevice>();
		devCount = 0;
	}

	~HCIScribe() {
		devices.destroy();
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
		etxt resp = etxt.same_same(buf);
		resp.shift(HCIPacket.EVENT_PACKET_HEADER_LEN); // header length + plen
		BluetoothDevice dev = new BluetoothDevice();
		dev.rawaddr[0] = resp.char_at(0);
		dev.rawaddr[1] = resp.char_at(1);
		dev.rawaddr[2] = resp.char_at(2);
		dev.rawaddr[3] = resp.char_at(3);
		dev.rawaddr[4] = resp.char_at(4);
		dev.rawaddr[5] = resp.char_at(5);
		int bitindex = 6;
		dev.pscan_rep_mode = resp.char_at(bitindex);
		if(buf.char_at(1) == 0x2F) { // extended
			bitindex++;
		}
		dev.pscan_mode = resp.char_at(bitindex+1);
		dev.clock_offset = resp.char_at(bitindex+4);
		dev.clock_offset |= (((aroop_uword16)resp.char_at(bitindex+5))<<8);
		int devID = devCount;
		devCount++;
		devices.set(devID, dev);
		etxt msg = etxt.stack(128);
		msg.printf("New device identified %X %X %X "
			, resp.char_at(6)
			, resp.char_at(bitindex+1)
			, dev.clock_offset);
		dev.copyAddressTo(&msg);
		msg.zero_terminate();
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 1, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &msg);
		onNewDevice(devID, dev);
		return 0;
	}

	int onInquiryResult(etxt*buf) {
		etxt resp = etxt.same_same(buf);
		resp.shift(HCIPacket.EVENT_PACKET_HEADER_LEN); // header length + plen
		BluetoothDevice dev = new BluetoothDevice();
		dev.rawaddr[0] = resp.char_at(0);
		dev.rawaddr[1] = resp.char_at(1);
		dev.rawaddr[2] = resp.char_at(2);
		dev.rawaddr[3] = resp.char_at(3);
		dev.rawaddr[4] = resp.char_at(4);
		dev.rawaddr[5] = resp.char_at(5);
		int bitindex = 6;
		dev.pscan_rep_mode = resp.char_at(bitindex);
		if(buf.char_at(1) == 0x2F) { // extended
			bitindex++;
		}
		dev.pscan_mode = resp.char_at(bitindex+1);
		dev.clock_offset = resp.char_at(bitindex+4);
		dev.clock_offset |= (((aroop_uword16)resp.char_at(bitindex+5))<<8);
		int devID = devCount;
		devCount++;
		devices.set(devID, dev);
		etxt msg = etxt.stack(128);
		msg.printf("New device identified %X %X %X "
			, resp.char_at(6)
			, resp.char_at(bitindex+1)
			, dev.clock_offset);
		dev.copyAddressTo(&msg);
		msg.concat_char('\n');
		msg.zero_terminate();
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 1, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &msg);
		onNewDevice(devID, dev);
		return 0;
	}

	public BluetoothDevice? getBluetoothDevice(int i) {
		return devices.get(i);
	}

	protected virtual int onNewDevice(int devID, BluetoothDevice dev) {
		return 0;
	}
}
/** @} */
