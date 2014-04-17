using aroop;
using shotodol;

internal class HCIShellTest : UnitTest {
	etxt tname;
	public HCIShellTest() {
		tname = etxt.from_static("HCI shell test");
	}
	public override aroop_hash getHash() {
		return tname.get_hash();
	}
	public override void getName(etxt*name) {
		name.dup_etxt(&tname);
	}
	public override int test() throws UnitTestError {
		print("HCI shell test:~~~~TODO fill me\n");
		return 0;
	}
}

