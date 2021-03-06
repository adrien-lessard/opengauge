
#include "port.h"
#include "Notification.h"

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stropts.h>
#include <string.h>

#include <wiringPi.h>

#define termios asmtermios
#include <asm/termios.h>
#undef  termios
#include <termios.h>

#include <QThread>
#include <asm/termios.h>

const int txPin = 14;
const int serialTimeout = 500; // ms
int uartFd = -1;

void txPinHigh()
{
	digitalWrite(txPin, HIGH);
}

void txPinLow()
{
	digitalWrite(txPin, LOW);
}

static int set_interface_attribs (int fd, int speed, int parity)
{
	struct termios tty;
	memset (&tty, 0, sizeof tty);
	if (tcgetattr (fd, &tty) != 0)
	{
		printf ("error %d from tcgetattr: %s\n", errno, strerror(errno));
		return -1;
	}

	cfsetospeed (&tty, speed);
	cfsetispeed (&tty, speed);

	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
	// disable IGNBRK for mismatched speed tests; otherwise receive break
	// as \000 chars
	tty.c_iflag &= ~IGNBRK;         // disable break processing
	tty.c_lflag = 0;                // no signaling chars, no echo,
									// no canonical processing
	tty.c_oflag = 0;                // no remapping, no delays
	tty.c_cc[VMIN]  = 0;            // read doesn't block
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

	tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
									// enable reading
	tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
	tty.c_cflag |= parity;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;

	if (tcsetattr (fd, TCSANOW, &tty) != 0)
	{
		printf ("error %d from tcsetattr: %s\n", errno, strerror(errno));
		return -1;
	}
	return 0;
}

static void set_blocking (int fd, int should_block)
{
	struct termios tty;
	memset (&tty, 0, sizeof tty);
	if (tcgetattr (fd, &tty) != 0)
	{
		printf ("error %d from tggetattr: %s\n", errno, strerror(errno));
		return;
	}

	tty.c_cc[VMIN]  = should_block ? 1 : 0;
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	if (tcsetattr (fd, TCSANOW, &tty) != 0)
		printf ("error %d setting term attributes: %s\n", errno, strerror(errno));
}

void portInit()
{
	printf("GPIO init\n");
	if(wiringPiSetupGpio() == -1)
		printf("Error wiringPiSetupGpio\n");
	
	pinMode(txPin, OUTPUT);
	
	// Serial init
	const char portname[] = "/dev/ttyS0";

	uartFd = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
	if (uartFd < 0)
	{
		printf("error %d opening %s: %s\n", errno, portname, strerror(errno));
	}
	
	set_interface_attribs(uartFd, B115200, 0);
	
	struct termios2 tio;
	if(ioctl(uartFd, TCGETS2, &tio) != 0)
	{
		printf("error %d ioctl: %s\n", errno, strerror(errno));
	}
	tio.c_cflag &= ~CBAUD;
	tio.c_cflag |= BOTHER;
	tio.c_ispeed = 10400; // Override with 10400 baud
	tio.c_ospeed = 10400;
	if(ioctl(uartFd, TCSETS2, &tio) != 0)
	{
		printf("error %d ioctl: %s\n", errno, strerror(errno));
	}
	
	set_blocking(uartFd, 0);
}

void serial_rx_on()
{
	// flush pending buffers
	tcflush(uartFd, TCIFLUSH);
}

void serial_rx_off()
{
	
}

void serial_tx_off()
{
	pinModeAlt(txPin, 1);
}

uint8_t serialRead0x55()
{
	return serialRead();
}

uint8_t serialRead0xCC()
{
	return serialRead();
}

uint8_t serialRead()
{
	uint8_t byte;
	int ret = read(uartFd, &byte, 1);
	
	if(ret < 0) {
		printf("error %d reading serial: %s\n", errno, strerror(errno));
		Notification::notify("Serial read error");
	}
	else if(ret == 0) {
		printf("Serial timeout\n");
		Notification::notify("Serial timeout");
	}
	if(ret != 1)
		return 0;
	else
		return byte;
}

void serialWrite(uint8_t data)
{
	write(uartFd, &data, sizeof(data));
}

void serial_on()
{
	pinModeAlt(txPin, 2);
	serial_rx_on();
}

void delayMs(uint32_t delay)
{
	QThread::msleep(delay);
}
