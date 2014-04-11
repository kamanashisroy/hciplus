using aroop;
using shotodol;
using hciplus;
using hciplus_platform;

public class hciplus.HCIInputStream : InputStream {
	HCIDev*dev;
	bool closed;
	public HCIInputStream(HCIDev*aDev) {
		dev = aDev;
		closed = false;
	}
	~HCIInputStream() {
	}

	public override int read(etxt*buf) throws IOStreamError.InputStreamError {
		int ret = 0;
		if((ret = dev.read(buf)) == 0) {
			throw new IOStreamError.InputStreamError.END_OF_DATA("File end");
		}
		return ret;
	}

	/*public override int write(etxt*buf) throws IOStreamError.OutputStreamError {
		return dev.write(buf);
	}*/
	public override void close() throws IOStreamError.InputStreamError {
		if(!closed) {
			dev.close();
			closed = true;
		}
	}
}
