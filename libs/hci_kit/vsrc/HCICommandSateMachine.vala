using aroop;
using hciplus;

public class hciplus.HCICommandStateMachine : hciplus.HCIEventBroker {
	Queue<txt>commands;
	bool bussy;
	public HCICommandStateMachine(etxt*devName) {
		base(devName);
		subscribe(0x0e/* command complete */, onCommandComplete);
		commands = Queue<txt>();
		bussy = false;
	}

	public void pushCommand(aroop_uword8 ogf, aroop_uword8 ocf, etxt*pkt) {
		txt cmd = new txt(null, 2+pkt.length());
		((etxt*)cmd).concat_char(ogf);
		((etxt*)cmd).concat_char(ocf);
		((etxt*)cmd).concat(pkt);
		commands.enqueue(cmd);
		if(!bussy) {
			onCommandComplete(null);
		}
	}

	int onCommandComplete(etxt*buf) {
		bussy = false;
		// push the next command ..
		txt? cmd = commands.dequeue();
		if(cmd == null) {
			return 0;
		}
		etxt pkt = etxt.same_same(cmd);
		pkt.shift(2);
		hos.writeCommand(cmd.char_at(0), cmd.char_at(1), &pkt);
		bussy = true;
		return 0;
	}

	public override int onSetup() {
		onCommandComplete(null);
		return 0;
	}
}	
