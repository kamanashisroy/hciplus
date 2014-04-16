using aroop;
using hciplus;

public class hciplus.ACLScribe : hciplus.ACLSpokesMan {
	enum ACLEvent {
		CONNECTION_CREATE_RESULT = 0x0F,
	}
	public ACLScribe(etxt*devName) {
		base(devName);
		subscribe(ACLEvent.CONNECTION_CREATE_RESULT , onACLConnection);
	}

	int onACLConnection(etxt*buf) {
		if(buf.char_at(3) != 0) {
			print("Acl connection creation failed\n");
		} else {
			print("Successful\n");
		}
		return 0;
	}
}
