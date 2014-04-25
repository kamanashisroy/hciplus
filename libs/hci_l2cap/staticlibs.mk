HCI_L2CAP_CSOURCES=$(wildcard $(HCIPLUS_HOME)/libs/hci_l2cap/vsrc/*.c)
HCI_L2CAP_VSOURCE_BASE=$(basename $(notdir $(HCI_L2CAP_CSOURCES)))
OBJECTS+=$(addprefix $(HCIPLUS_HOME)/build/.objects/, $(addsuffix .o,$(HCI_L2CAP_VSOURCE_BASE)))
