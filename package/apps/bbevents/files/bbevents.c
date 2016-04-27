/*
 * bbevents.c
 *
 *  Created on: Apr 5, 2016
 *      Author: yuyue
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/epoll.h>
#include <sys/time.h>
#include <linux/types.h>
#include <linux/netlink.h>
#include <errno.h>
#include <unistd.h>

#include "bbevents.h"

static int netlink_create(void)
{
	struct sockaddr_nl snl;
	int sockfd;
	int ret;

	memset(&snl, 0, sizeof(snl));
	snl.nl_family = AF_NETLINK;
	snl.nl_pid    = getpid();
	snl.nl_groups = 1;

	errno = 0;

	sockfd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_KOBJECT_UEVENT);
	fcntl(sockfd, F_SETFL, fcntl(sockfd, F_GETFL) | O_NONBLOCK);
	if (sockfd >= 0) {
		ret = bind(sockfd, (struct sockaddr *)&snl, sizeof(struct sockaddr_nl));
		if (ret < 0) {
			close(sockfd);
			sockfd = -1;
		}
	}

	return sockfd;
}

static int recv_msg(char *buffer, size_t size, int timeout)
{
	static int first_init = 0;
	static int nlfd = -1;
	static int epollfd = -1;
	int retval;
	int len;
	int recv_size = 0;
	struct epoll_event event;

	if (!first_init) {
		nlfd = netlink_create();
		epollfd = epoll_create(1);
		if (epollfd < 0 || nlfd < 0)
			return -1;
		event.events  = EPOLLIN | EPOLLET;
		event.data.fd = nlfd;
		epoll_ctl(epollfd, EPOLL_CTL_ADD, nlfd, &event);
		first_init = 1;
//		BBPRINT("info: EPOLL first initialize done.\n");
	}


retry_again:
	errno = 0;
	retval = epoll_wait(epollfd, &event, 1, timeout < 0 ? -1 : timeout * 1000 / 4);
	if (retval == 0)
		return 0;
	if (retval < 0) {
		if (errno == EINTR)
			goto retry_again;
		return -1;
	}

	while (size && (len = recv(event.data.fd, buffer, size, 0)) > 0) {
		buffer += len;
		size -= len;
		recv_size += len;
	}
	if (len < 0 && errno != EWOULDBLOCK && errno != EAGAIN)
		return -1;

	return recv_size;
}

static double t2d(struct timeval tm)
{
	return (double)tm.tv_sec + (double)tm.tv_usec / 1000000;
}

int main(void)
{
	char buffer[1024 * 4];
	int ret;
	struct timeval start = {0};
	struct timeval stop = {0};
	struct timeval interval = {0};
	int button_flags = 0;
	int count = 0;

	while (1) {
		memset(buffer, 0, 1024 * 4);

		ret = recv_msg(buffer, 1024 * 4, 1);
		if (ret < 0) {
			BBPRINT("error: %s\n", strerror(errno));
			exit(EXIT_FAILURE);
		}
		if (ret == 0) {
			if (t2d(interval) > 0.0 && t2d(interval) < INTERVAL_DECLARE) {
				/* TODO: interval pressed event process */
				BBPRINT("debug: interval pressed: %d\n", count);
			}

			if (t2d(interval) > INTERVAL_DECLARE) {
				/* TODO: long pressed event process */
				BBPRINT("debug: long pressed %lf\n", t2d(interval));
			}

			/* reset button state */
			if (t2d(interval) > 0.0) {
				button_flags = 0;
				memset(&interval, 0, sizeof(interval));
				count = 0;
			}
		}

		if (!strncasecmp(buffer, "pressed", strlen("pressed")) && !button_flags) {
			memset(&start, 0, sizeof(start));
			memset(&stop, 0, sizeof(stop));
			memset(&interval, 0, sizeof(interval));
			gettimeofday(&start, NULL);
			count = 0;
			button_flags = 1;
		} else if (!strncasecmp(buffer, "released", strlen("released")) && button_flags) {
			gettimeofday(&stop, NULL);

			/* Counter interval time and counts */
			if (stop.tv_usec < start.tv_usec) {
				stop.tv_sec--;
				stop.tv_usec += 1000000;
			}
			interval.tv_sec = stop.tv_sec - start.tv_sec;
			interval.tv_usec = stop.tv_usec - start.tv_usec;
			count++;
		}

	}
	return 0;
}
