using aroop;
using shotodol;
using hciplus;
using hciplus_platform;

/***
 * \addtogroup hcikit
 * @{
 */
public class hciplus.HCIOutputStream : OutputStream {
	HCIDev*dev;
	bool closed;
	internal int bwritten;
	public HCIOutputStream(HCIDev*aDev) {
		dev = aDev;
		closed = false;
		bwritten = 0;
	}
	~HCIOutputStream() {
	}

	public override int write(etxt*buf) throws IOStreamError.OutputStreamError {
		int ret = dev.write(buf);
		if(ret > 0) {
			bwritten += ret;
		}
		return ret;
	}

	public int writeCommand(int ogf, int ocf, etxt*buf) throws IOStreamError.OutputStreamError {
		dev.writeCommand(ogf, ocf, buf.length(), buf.to_string());
		return 0;
	}

	public override void close() throws IOStreamError.OutputStreamError {
		if(!closed) {
			dev.close();
			closed = true;
		}
	}
}
/** @} */
