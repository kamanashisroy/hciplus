#ifndef SHOTODOL_PLATFORM_HCI_DEV_INCLUDE_H
#define SHOTODOL_PLATFORM_HCI_DEV_INCLUDE_H

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

typedef struct {
	int hci_fd;
	int cmd_cnt;
	int sco_cnt;
	int evt_cnt;
	int err_cnt;
} hci_dev_t;

#define hci_dev_new(x,y) ({ \
	memset(x, 0, sizeof(hci_dev_t)); \
	(x)->hci_fd = -1; \
})
#define hci_dev_open(x) ({ \
	/*TODO fill me*/ \
})

#define hci_dev_close(x) ({if((x)->hci_fd > 0)close((x)->hci_fd);(x)->hci_fd = -1;})

#endif //SHOTODOL_PLUGIN_INCLUDE_H
