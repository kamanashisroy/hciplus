#ifndef SHOTODOL_PLATFORM_HCI_DEV_INCLUDE_H
#define SHOTODOL_PLATFORM_HCI_DEV_INCLUDE_H

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

typedef struct {
	int hci_fd;
	int dev_id;
} hci_dev_t;

#define HCI_PLUS_BIND_CHANNEL HCI_CHANNEL_RAW

#include <linux/version.h>
#ifdef KERNEL_VERSION
#undef HCI_PLUS_BIND_CHANNEL
#if LINUX_VERSION_CODE <= KERNEL_VERSION(3,11,0)
#define HCI_PLUS_BIND_CHANNEL HCI_CHANNEL_RAW
#else
/*#ifndef HCI_CHANNEL_USER
#define HCI_CHANNEL_USER 1
#endif*/
#define HCI_PLUS_BIND_CHANNEL HCI_CHANNEL_USER
#endif
#endif

#include "shotodol_watchdog.h"
#define watchdog_log_string(x) aroop_cl_shotodol_shotodol_watchdog_logString(__FILE__, __LINE__, 5 , x)

#define hci_dev_new(x,y) ({ \
	memset(x, 0, sizeof(hci_dev_t)); \
	(x)->hci_fd = -1; \
	(x)->dev_id = atoi(y->str); \
})

#define hci_dev_set_dev_id(x,y) ({ \
	(x)->dev_id = atoi(y->str); \
})


#define hci_dev_open(x) ({ \
	int _hciret = -1; \
	(x)->hci_fd = socket(AF_BLUETOOTH, SOCK_RAW/* | SOCK_CLOEXEC*/ | SOCK_NONBLOCK, BTPROTO_HCI); \
	if((x)->hci_fd < 0) { \
		watchdog_log_string("HCI client socket creation failed\n"); \
	} else { \
		struct sockaddr_hci addr; \
		memset(&addr, 0, sizeof(addr)); \
		addr.hci_family = AF_BLUETOOTH; \
		addr.hci_dev = (x)->dev_id; \
		addr.hci_channel = HCI_PLUS_BIND_CHANNEL; \
		if(bind((x)->hci_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) { \
			watchdog_log_string("Could not bind\n"); \
			close((x)->hci_fd); \
			(x)->hci_fd = -1; \
		} else { \
			watchdog_log_string("HCI device is opened successfully\n"); \
			_hciret = 0; \
		} \
	} \
	_hciret; \
})

#define hci_dev_close(x) ({if((x)->hci_fd > 0)close((x)->hci_fd);(x)->hci_fd = -1;})

#define hci_dev_read(x, y) ({int _rd = read((x)->hci_fd, (y)->str+(y)->len, (y)->size - (y)->len);if(_rd > 0){(y)->len += _rd;}_rd;})
#define hci_dev_write(x, y) ({write((x)->hci_fd, (y)->str, (y)->len);})
#define hci_dev_write_command(x, y, z, plen, param) ({watchdog_log_string("sending cmd\n");hci_send_cmd((x)->hci_fd, y, z, plen, param);})
#define hci_dev_platform_info(x) ({(x)->hci_fd;})
#define hci_dev_get_bd_addr(x,y) ({ba2str((y)->str, (x)->str+(x)->len);(x)->len+=17;})
#define hci_dev_get_bd_addr_from_array(x,y) ({ba2str((y), (x)->str+(x)->len);(x)->len += 17;})

#endif //SHOTODOL_PLUGIN_INCLUDE_H
