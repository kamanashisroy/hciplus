using aroop;
using shotodol;
using hciplus;

public class hciplus.HCIShell : Replicable {
	HCIEventBroker hci;

	public HCIShell() {
		etxt hcidev = etxt.from_static("0");
		hci = new HCIEventBroker(&hcidev);
		MainTurbine.gearup(hci);
	}

	~HCIShell() {
		hci.inactivate();
		MainTurbine.geardown(hci);
	}

	public int up() {
		hci.activate();
		return 0;
	}

	public int down() {
		hci.inactivate();
		return 0;
	}
}