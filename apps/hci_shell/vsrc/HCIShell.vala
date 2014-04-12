using aroop;
using shotodol;
using hciplus;

public class hciplus.HCIShell : Replicable {
	HCISpokesMan hci;

	public HCIShell() {
		etxt hcidev = etxt.from_static("0");
		hci = new HCISpokesMan(&hcidev);
		MainTurbine.gearup(hci);
	}

	~HCIShell() {
		hci.unwatch();
		MainTurbine.geardown(hci);
	}

	public int up() {
		hci.watch();
		hci.describe("Up ..\n");
		return 0;
	}

	public int down() {
		hci.unwatch();
		hci.describe("Down ..\n");
		return 0;
	}

	public int scan() {
		hci.describe("Scanning ..\n");
		hci.inquery();
		hci.describe("Scanning .. ..\n");
		return 0;
	}
}
