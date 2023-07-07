#include <reent.h>
#include <stdint.h>
#define CSKY_EXIT (0x10002000)

void _exit(int status)
{
	*(volatile uint64_t *)CSKY_EXIT = status;
	while (1)
		;
}