using aroop;
using hciplus;
using hciplus_platform;

public class hciplus.HCIWatch : shotodol.Spindle {
	HCIDev dev;
	HCIInputStream hios;

	public HCIWatch(etxt*devName) {
		dev = HCIDev(devName);
		hios = new HCIInputStream(&dev);
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
		etxt buf = etxt.stack(512);
		hios.read(&buf);
		print("There is something ..\n");
		return 0;
	}

	public override int cancel() {
		return 0;
	}
}

