
PROJECT_OBJDIR=$(PROJECT_HOME)/build/.objects/
#LIBS+=-lopencv_core -lopencv_imgproc
include $(PROJECT_HOME)/libs/hci_kit/staticlibs.mk
include $(PROJECT_HOME)/libs/hci_acl/staticlibs.mk
include $(PROJECT_HOME)/libs/hci_l2cap/staticlibs.mk
include $(PROJECT_HOME)/libs/hci_sdp/staticlibs.mk
include $(PROJECT_HOME)/libs/hci_rfcomm/staticlibs.mk
