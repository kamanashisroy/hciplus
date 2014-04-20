
-include .config.mk
-include $(SHOTODOL_HOME)/plugin.mk

all:makecore makeapps makeshotodol

makeapps:
	$(BUILD) -C apps/hci_shell

cleanapps:
	$(CLEAN) -C apps/hci_shell

makecore:
	$(BUILD) -C libs/hci_kit
	$(BUILD) -C libs/hci_acl

cleancore:
	$(CLEAN) -C libs/hci_kit
	$(CLEAN) -C libs/hci_acl

clean:cleancore cleanapps

