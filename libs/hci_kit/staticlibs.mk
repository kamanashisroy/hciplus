HCI_KITTY_CSOURCES=$(wildcard $(HCIPLUS_HOME)/libs/hci_kit/vsrc/*.c)
HCI_KITTY_VSOURCE_BASE=$(basename $(notdir $(HCI_KITTY_CSOURCES)))
OBJECTS+=$(addprefix $(HCIPLUS_HOME)/build/.objects/, $(addsuffix .o,$(HCI_KITTY_VSOURCE_BASE)))
