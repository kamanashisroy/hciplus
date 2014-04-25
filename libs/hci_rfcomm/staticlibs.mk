HCI_RFCOMM_CSOURCES=$(wildcard $(HCIPLUS_HOME)/libs/hci_rfcomm/vsrc/*.c)
HCI_RFCOMM_VSOURCE_BASE=$(basename $(notdir $(HCI_RFCOMM_CSOURCES)))
OBJECTS+=$(addprefix $(HCIPLUS_HOME)/build/.objects/, $(addsuffix .o,$(HCI_RFCOMM_VSOURCE_BASE)))
