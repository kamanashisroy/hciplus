HCI_SDP_CSOURCES=$(wildcard $(HCIPLUS_HOME)/libs/hci_sdp/vsrc/*.c)
HCI_SDP_VSOURCE_BASE=$(basename $(notdir $(HCI_SDP_CSOURCES)))
OBJECTS+=$(addprefix $(HCIPLUS_HOME)/build/.objects/, $(addsuffix .o,$(HCI_SDP_VSOURCE_BASE)))
