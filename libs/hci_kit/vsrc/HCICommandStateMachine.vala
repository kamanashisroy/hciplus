using aroop;
using hciplus;

/***
 * \addtogroup hcikit
 * @{
 */
public class hciplus.HCICommandStateMachine : hciplus.HCIEventBroker {
	Queue<txt>commands;
	bool bussy;
	public HCICommandStateMachine(etxt*devName) {
		base(devName);
		subscribe(HCIEvent.COMMAND_COMPLETE, onCommandComplete);
		subscribe(0x01/* command complete */, onCommandComplete);
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
			shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 10, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "Executing Command on request");
			onCommandComplete(null);
		}
	}

	protected int onCommandComplete(etxt*buf) {
		bussy = false;
		if(buf != null) {
			etxt dlg = etxt.stack(64);
			dlg.printf("Command (0x%X|0x%X) complete (length:%d)", buf.char_at(3), buf.char_at(4), buf.length());
			shotodol.Watchdog.watchit(core.sourceFileName(), core.sourceLineNo(), 10, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, &dlg);
		}
		// push the next command ..
		txt? cmd = commands.dequeue();
		if(cmd == null) {
			return 0;
		}
		tx_wrapper(cmd);
		bussy = true;
		return 0;
	}

	public override int onSetup() {
		onCommandComplete(null);
		shotodol.Watchdog.watchit_string(core.sourceFileName(), core.sourceLineNo(), 1, shotodol.Watchdog.WatchdogSeverity.LOG, 0, 0, "Setup Complete");
		return 0;
	}
}	
/** @} */
