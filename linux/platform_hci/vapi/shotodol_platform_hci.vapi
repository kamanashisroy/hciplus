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
		[CCode (cname="hci_dev_write", cheader_filename = "hciplus_platform.h")]
		public int write(etxt*buf);
		[CCode (cname="hci_dev_write_command", cheader_filename = "hciplus_platform.h")]
		public int writeCommand(int ogf, int ocf, int plen, void*param);
		[CCode (cname="hci_dev_platform_info", cheader_filename = "hciplus_platform.h")]
		public int platformInfo();
		[CCode (cname="hci_dev_set_dev_id", cheader_filename = "hciplus_platform.h")]
		public int setDevId(etxt*devId);
		[CCode (cname="hci_dev_close", cheader_filename = "hciplus_platform.h")]
		public int close();
		[CCode (cname="hci_dev_get_bd_addr", cheader_filename = "hciplus_platform.h")]
		public static int getBluetoothAddress(etxt*dst, etxt*rawsrc);
	}
}
