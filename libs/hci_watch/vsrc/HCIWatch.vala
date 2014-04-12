using aroop;
using hciplus;
using hciplus_platform;

public class hciplus.HCIWatch : shotodol.Spindle {
	HCIDev dev;
	HCIInputStream his;
	protected HCIOutputStream hos;
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

	public int watch() {
		if(state == HCIWatchState.IDLE)state = HCIWatchState.OPENING;
		return 0;
	}

	public int unwatch() {
		if(state == HCIWatchState.WATCHING)state = HCIWatchState.CLOSING;
		return 0;
	}

	public override int start(shotodol.Spindle?plr) {
		print("Started console stepping ..\n");
		
		return 0;
	}

	public override int step() {
		if(state == HCIWatchState.OPENING) {
			if(dev.open() != 0) {
				state = HCIWatchState.ERROR;
			} else {
				state = HCIWatchState.WATCHING;
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
		if(buf.length() != 0)print("There is something ..\n");
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

