using aroop;
using hciplus;

public class hciplus.RFCOMMSpokesMan : hciplus.SDPScribe {
	enum RFCOMMCommand {
		SET_ASYNC_BALANCED_MODE = 0x2F,
		DISCONNECT = 0x43,
	}
	public RFCOMMSpokesMan(etxt*devName) {
		base(devName);
		crcInit();
		cmds.register(new hciplus.RFCOMMCommand(this));
	}

	uchar crcTable[256];
	uchar WIDTH;
	uchar TOPBIT;
	uchar POLYNOMIAL;

	void crcInit() {
		WIDTH = 8; // we are detecting 8 bit crc
		TOPBIT = (1 << (WIDTH - 1));
		POLYNOMIAL = 0xD8;
	    uchar  remainder;

	    /*
	     * Compute the remainder of each possible dividend.
	     */
	    for (int dividend = 0; dividend < 256; ++dividend)
	    {
		/*
		 * Start with the dividend followed by zeros.
		 */
		remainder = ((uchar)dividend) << (WIDTH - 8);

		/*
		 * Perform modulo-2 division, a bit at a time.
		 */
		for (uchar bit = 8; bit > 0; --bit)
		{
		    /*
		     * Try to divide the current data bit.
		     */			
		    if ((remainder & TOPBIT) != 0)
		    {
			remainder = (remainder << 1) ^ POLYNOMIAL;
		    }
		    else
		    {
			remainder = (remainder << 1);
		    }
		}

		/*
		 * Store the result into the table.
		 */
		crcTable[dividend] = remainder;
	    }

	}   /* crcInit() */

	uchar crcFast(etxt*message, int nBytes)
	{
	    uchar data;
	    uchar remainder = 0;


	    /*
	     * Divide the message by the polynomial, a byte at a time.
	     */
	    for (int byte = 0; byte < nBytes; ++byte)
	    {
		data = ((uchar)message.char_at(byte)) ^ (remainder >> (WIDTH - 8));
		remainder = crcTable[data] ^ (remainder << 8);
	    }

	    /*
	     * The final remainder is the CRC.
	     */
	    return (remainder);

	}   /* crcFast() */

	public void RFCOMMDisconnect(int aclHandle, int l2capConnectionID) {
		etxt pkt = etxt.stack(5);
		// Address field
		// if command is sent to initiator to responder then cr = 1
		// if response is sent to responder to initiator then cr = 1
		uchar dlci = 0;
		uchar cr = 1;
		uchar addrField = (cr<<1)/* CR FLAG */ | 1/* EA FLAG */ | ((dlci & 0xF)<<3);
		pkt.concat_char(addrField);
		// Command field
		uchar pf = 1;
		uchar cmdField = RFCOMMCommand.DISCONNECT | (pf<<4);
		pkt.concat_char(cmdField);
		// payload length field
		uchar payloadLength = 0;
		uchar lengthField = 1/*EA FLAG*/ | payloadLength;
		pkt.concat_char(lengthField); // payload length
		// frame checking sequence field (CRC)
		uchar crc = crcFast(&pkt, pkt.length());
		pkt.concat_char(crc); // frame checking sequence field
		sendL2CAPContent(aclHandle, 0x40, &pkt);
	}

	public void RFCOMMSendSABM(int aclHandle, int l2capConnectionID) {
		RFCOMMSendCommand(aclHandle, l2capConnectionID, 0, RFCOMMCommand.SET_ASYNC_BALANCED_MODE);
	}

	public void RFCOMMSendCommand(int aclHandle, int l2capConnectionID, uchar dlci, uchar cmd) {
		etxt pkt = etxt.stack(5);
		// Address field
		// if command is sent to initiator to responder then cr = 1
		// if response is sent to responder to initiator then cr = 1
		uchar cr = 1;
		uchar addrField = (cr<<1)/* CR FLAG */ | 1/* EA FLAG */ | ((dlci & 0xF)<<3);
		pkt.concat_char(addrField);
		// Command field
		uchar pf = 1;
		uchar cmdField = cmd | (pf<<4);
		pkt.concat_char(cmdField);
		// payload length field
		uchar payloadLength = 0;
		uchar lengthField = 1/*EA FLAG*/ | payloadLength;
		pkt.concat_char(lengthField); // payload length
		// frame checking sequence field (CRC)
		uchar crc = crcFast(&pkt, pkt.length());
		pkt.concat_char(crc); // frame checking sequence field
		sendL2CAPContent(aclHandle, l2capConnectionID, &pkt);
	}


}

