using aroop;
using shotodol;
using hciplus;

public class hciplus.HCIShell : Replicable {
	ACLScribe hci;

	public HCIShell() {
		etxt hcidev = etxt.from_static("0");
		hci = new ACLScribe(&hcidev);
		MainTurbine.gearup(hci);
	}

	~HCIShell() {
		hci.unwatch();
		MainTurbine.geardown(hci);
	}

	public int up(etxt*devid) {
		hci.setDevId(devid);
		hci.watch();
		hci.describe("Up ..\n");
		return 0;
	}

	public int reset() {
		hci.reset();
		return 0;
	}

	public int down() {
		hci.unwatch();
		hci.describe("Down ..\n");
		return 0;
	}

	public int scan() {
		hci.describe("Scanning ..\n");
		hci.inquiry();
		hci.describe("Scanning .. ..\n");
		return 0;
	}

	public int ACLConnect(int index, OutputStream pad) {
		BluetoothDevice?dev = hci.getBluetoothDevice(index);
		if(dev == null)
			return 0;
	
		hci.ACLConnect(dev);
		return 0;
	}

	public int list(OutputStream pad) {
		int i = 0;
		for(i = 0; i < 100; i++) {
			BluetoothDevice?dev = hci.getBluetoothDevice(i);
			if(dev == null) {
				break;
			}
			etxt msg = etxt.stack(128);
			msg.printf("[%5d] -", i);
			dev.copyaddr(&msg);
			msg.concat_char('\n');
			pad.write(&msg);
		}
		return 0;
	}
}
