HCI_ACL_CSOURCES=$(wildcard $(HCIPLUS_HOME)/libs/hci_acl/vsrc/*.c)
HCI_ACL_VSOURCE_BASE=$(basename $(notdir $(HCI_ACL_CSOURCES)))
OBJECTS+=$(addprefix $(HCIPLUS_HOME)/build/.objects/, $(addsuffix .o,$(HCI_ACL_VSOURCE_BASE)))
