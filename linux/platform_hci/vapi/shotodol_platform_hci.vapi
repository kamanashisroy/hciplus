using aroop;

namespace hciplus_platform {
	[CCode (cname="hci_dev_t", cheader_filename = "hciplus_platform.h")]
	public struct HCIDev {
		[CCode (cname="hci_dev_new", cheader_filename = "hciplus_platform.h")]
		public HCIDev(etxt*devName);
		[CCode (cname="hci_dev_open", cheader_filename = "hciplus_platform.h")]
		public int open();
		[CCode (cname="hci_dev_read", cheader_filename = "hciplus_platform.h")]
		public int read(etxt*buf);
		[CCode (cname="hci_dev_close", cheader_filename = "hciplus_platform.h")]
		public int close();
	}
}
