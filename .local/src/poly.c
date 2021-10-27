/*******************************************************
 Windows HID simplification

 Alan Ott
 Signal 11 Software

 8/22/2009

 Copyright 2009

 This contents of this file may be used by anyone
 for any reason without any conditions and may be
 used as a starting point for your own applications
 which use HIDAPI.
********************************************************/

#include <stdio.h>
#include <wchar.h>
#include <string.h>
#include <stdlib.h>
#include <hidapi/hidapi.h>

// Headers needed for sleeping.
#ifdef _WIN32
	#include <windows.h>
#else
	#include <unistd.h>
#endif

int main(int argc, char* argv[])
{
	(void)argc;
	(void)argv;

	int res;
	unsigned char buf[256];
	#define MAX_STR 255
	hid_device *handle;
	int i;

	// Set up the command buffer.
	memset(buf,0x00,sizeof(buf));
	buf[0] = 0x01;
	buf[1] = 0x81;

	// Open the device using the VID, PID,
	// and optionally the Serial number.
	////handle = hid_open(0x4d8, 0x3f, L"12345");
	handle = hid_open(0x047f, 0xac29, NULL);
	if (!handle) {
		printf("unable to open device\n");
 		return 1;
	}

	// Try to read from the device. There should be no
	// data here, but execution should not block.
	res = hid_read(handle, buf, 17);

	// Request state (cmd 0x81). The first byte is the report number (0x1).
	buf[0] = 0x1;
	buf[1] = 0x81;
	hid_write(handle, buf, 17);
	if (res < 0)
		printf("Unable to write() (2)\n");

	res = hid_read(handle, buf, sizeof(buf));
	if (res == 0)
		printf("waiting...\n");
	if (res < 0)
		printf("Unable to read()\n");

	printf("Data read:\n   ");
	// Print out the returned buffer.
	for (i = 0; i < res; i++)
		printf("%02hhx ", buf[i]);
	printf("\n");

	hid_close(handle);

	/* Free static HIDAPI objects. */
	hid_exit();

	return 0;
}
