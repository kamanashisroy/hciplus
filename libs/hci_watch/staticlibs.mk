HCI_WATCH__IMPL_CSOURCES=$(wildcard $(HCIPLUS_HOME)/libs/hci_watch/vsrc/*.c)
HCI_WATCH__IMPL_VSOURCE_BASE=$(basename $(notdir $(HCI_WATCH__IMPL_CSOURCES)))
OBJECTS+=$(addprefix $(HCIPLUS_HOME)/build/.objects/, $(addsuffix .o,$(HCI_WATCH__IMPL_VSOURCE_BASE)))
