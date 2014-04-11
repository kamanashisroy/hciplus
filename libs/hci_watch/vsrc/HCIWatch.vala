using aroop;
using hciplus;
using hciplus_platform;

public class hciplus.HCIWatch : shotodol.Spindle {
	HCIDev dev;
	public HCIWatch(etxt*devName) {
		dev = HCIDev(devName);
	}
	~HCIWatch() {
		dev.close();
	}

	public int activate() {
		return 0;
	}

	public int inactivate() {
		dev.close();
		return 0;
	}

	public override int start(shotodol.Spindle?plr) {
		print("Started console stepping ..\n");
		
		return 0;
	}

	public override int step() {
		// see if the is any hci activity ..
		return 0;
	}

	public override int cancel() {
		return 0;
	}
}

