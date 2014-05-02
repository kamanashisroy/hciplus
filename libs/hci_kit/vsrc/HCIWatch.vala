using aroop;
using hciplus;
using hciplus_platform;

/***
 * \addtogroup hcikit
 * @{
 */
public delegate int hciplus.HCIOnIncomingPacket(etxt*buf);
public class hciplus.HCIWatch : shotodol.Spindle {
	HCIDev dev;
	HCIInputStream his;
	protected HCIOutputStream hos;
	HCIOnIncomingPacket packetListeners[32];
	public enum HCIPacket {
		EVENT_PACKET_HEADER_LEN = 4,
	}
	public enum HCIWatchState {
		IDLE = 0,
		OPENING,
		ERROR,
		WATCHING,
		CLOSING,
	}
	HCIWatchState state;

	public HCIWatch(etxt*devName) {
		dev = HCIDev(devName);
		his = new HCIInputStream(&dev);
		hos = new HCIOutputStream(&dev);
		state = HCIWatchState.IDLE;
	}

	~HCIWatch() {
		his.close();
		hos.close();
		dev.close();
	}

	public int subscribeForIncomingPacket(uint8 type, HCIOnIncomingPacket oip) {
		core.assert(type < 32);
		packetListeners[type] = oip;
		return 0;
	}

	public int setDevId(etxt*devId) {
		dev.setDevId(devId);
		return 0;
	}

	public int watch() {
		if(state == HCIWatchState.IDLE)state = HCIWatchState.OPENING;
		return 0;
	}

	public int unwatch() {
		if(state == HCIWatchState.WATCHING)state = HCIWatchState.CLOSING;
		return 0;
	}

	public virtual int onSetup() {
		return 0;
	}

	public override int start(shotodol.Spindle?plr) {
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 5, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "HCIWatch:up");
		return 0;
	}

	protected void concat_hexdump(etxt*dst, etxt*src) {
			int i = 0;
			int len = src.length();
			for(i=0;i<len;i++) {
				uchar dval = src.char_at(i);
				dst.concat_char('0');
				dst.concat_char('x');
				uchar val = (dval & 0xF0) >> 4;
				uchar c = ((val < 10) ?'0':('A'-10));
				c += val;
				dst.concat_char(c);
				val = dval & 0x0F;
				c = ((val < 10) ?'0':('A'-10));
				c += val;
				dst.concat_char(c);
				dst.concat_char(',');
			}
	}

	protected void tx_wrapper(etxt*cmd) {
		etxt pkt = etxt.same_same(cmd);
		etxt dlg = etxt.stack(256);
		dlg.printf("HCICommandStateMachine:TX[%5d] ", pkt.length());
		concat_hexdump(&dlg, &pkt);
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 10, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
		pkt.shift(2);
		hos.writeCommand(cmd.char_at(0), cmd.char_at(1), &pkt);
	}

	protected void rx_wrapper(etxt*buf) {
		etxt dlg = etxt.stack(256);
		dlg.printf("HCIWatch:Rattling[%5d] ", buf.length());
		concat_hexdump(&dlg, buf);
		shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 4, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
	}

	public override int step() {
		if(state == HCIWatchState.OPENING) {
			if(dev.open() != 0) {
				state = HCIWatchState.ERROR;
			} else {
				state = HCIWatchState.WATCHING;
				onSetup();
			}
		}
		if(state == HCIWatchState.CLOSING) {
			dev.close();
			state = HCIWatchState.IDLE;
		}
		if(state != HCIWatchState.WATCHING) {
			return 0;
		}	
		// see if the is any hci activity ..
		etxt buf = etxt.stack(512);
		his.read(&buf);

/*
typedef struct event_struct {
  u8 pkt_type;
  u8 event_type;
  u8 len;
  u8 data[0];
} __attribute__ ((packed)) event_struct;
 */
		if(buf.length() != 0) {
			rx_wrapper(&buf);
			uint8 ptype = buf.char_at(0);
			if(packetListeners[ptype] != null) {
				packetListeners[ptype](&buf);
			}
		}
		return 0;
	}

	public override int cancel() {
		return 0;
	}

	public int describe(string msg) {
		etxt buf = etxt.stack(512);
		buf.printf("HCIKit: (%d,%d)[+%-4d-%-4d] ", dev.platformInfo(), state, his.bread, hos.bwritten);
		buf.concat_string(msg);
		buf.concat_char('\n');
		//shotodol.Watchdog.logMsgDoNotUse(&buf);
		buf.zero_terminate();
		print("%s", buf.to_string());
		return 0;
	}
}

/** @} */
