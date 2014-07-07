using aroop;
using hciplus;
using shotodol;

internal class HCIShellTest : UnitTest {
	etxt tname;
	public HCIShellTest() {
		tname = etxt.from_static("HCI shell test");
	}
	public override aroop_hash getHash() {
		return tname.getStringHash();
	}
	public override void getName(etxt*name) {
		name.dup_etxt(&tname);
	}
	public override int test() throws UnitTestError {
		etxt hci0 = etxt.from_static("0");
		HCIShell shell = new HCIShell();
		print("HCI shell test: opening hci0\n");
		shell.up(&hci0);
		print("HCI shell test: rest hci0\n");
		shell.reset();
		shell.down();
		return 0;
	}
}

