#include <reent.h>
#include <sys/types.h>

#define CSKY_UART (0x40015000)
static inline void putch(const char val) { *(volatile int *)CSKY_UART = val; }

ssize_t _write_r(struct _reent *ptr, int fd, const void *buf, size_t count)
{
	const char *data = (const char *)buf;
	for (int i = 0; i < count; i++) {
		putch(data[i]);
	}
	return count;
}