using aroop;
using hciplus;

public class hciplus.L2CAPScribe : hciplus.L2CAPSpokesMan {
	public L2CAPScribe(etxt*devName) {
		base(devName);
	}

#if false
	protected override int onSDPData(etxt*resp) {
		return 0;
	}
#endif
}
