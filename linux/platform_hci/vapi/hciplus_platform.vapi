using aroop;

namespace hciplus_platform {
	[CCode (cname="hci_dev_t", cheader_filename = "hci_lib.h")]
	public struct HCIDev {
		[CCode (cname="hci_dev_open", cheader_filename = "hciplus_platform.h")]
		public HCIDev.open(string devName);
		[CCode (cname="hci_dev_close", cheader_filename = "hciplus_platform.h")]
		public int close();
	}
}
