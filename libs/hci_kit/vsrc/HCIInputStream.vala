using aroop;
using shotodol;
using hciplus;
using hciplus_platform;

/***
 * \addtogroup hcikit
 * @{
 */
public class hciplus.HCIInputStream : InputStream {
	HCIDev*dev;
	bool closed;
	internal int bread;
	public HCIInputStream(HCIDev*aDev) {
		dev = aDev;
		closed = false;
		bread = 0;
	}
	~HCIInputStream() {
	}

	public override int read(etxt*buf) throws IOStreamError.InputStreamError {
		int ret = 0;
		if((ret = dev.read(buf)) == 0) {
			throw new IOStreamError.InputStreamError.END_OF_DATA("File end");
		}
		if(ret > 0)bread += ret;
		return ret;
	}

	public override void close() throws IOStreamError.InputStreamError {
		if(!closed) {
			dev.close();
			closed = true;
		}
	}
}
/** @} */
