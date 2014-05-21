using aroop;
using hciplus;

public class hciplus.SDPScribe : hciplus.SDPSpokesMan {
	public SDPScribe(etxt*devName) {
		base(devName);
	}

#if false
	protected override int onSDPData(etxt*resp) {
		return 0;
	}
#endif
}
