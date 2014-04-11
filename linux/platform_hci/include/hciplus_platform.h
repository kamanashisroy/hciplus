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
	(x)->hci_fd = socket(AF_BLUETOOTH, SOCK_RAW/* | SOCK_CLOEXEC | SOCK_NONBLOCK*/, BTPROTO_HCI); \
	if((x)->hci_fd < 0) { \
		perror("HCI client socket creation failed"); \
	} else { \
		struct sockaddr_hci addr; \ 
		memset(&addr, 0, sizeof(addr)); \
		addr.hci_family = AF_BLUETOOTH; \
		addr.hci_dev = 0; \
		addr.hci_channel = HCI_CHANNEL_USER; \
		if(bind((x)->hci_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) { \
			perror("Could not bind"); \
		} \
	} \
	0; \
})

#define hci_dev_close(x) ({if((x)->hci_fd > 0)close((x)->hci_fd);(x)->hci_fd = -1;})

#define hci_dev_read(x, y) ({int _rd = read((x)->hci_fd, (y)->str+(y)->len, (y)->size - (y)->len);if(_rd > 0){(y)->len += _rd;}_rd;})


#endif //SHOTODOL_PLUGIN_INCLUDE_H
