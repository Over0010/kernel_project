#include "serial.h"
#include "io.h"
#include <stdint.h>
#include <stddef.h>

#define COM1 0x3F8

bool serial_init(void){

    outb(COM1 + 1, 0x00);    // Disable all serial interrupts
    outb(COM1 + 3, 0x80);    // Enable DLAB (set baud rate divisor)
    outb(COM1 + 0, 0x03);    // Divisor low byte = 3 (38400 baud)
    outb(COM1 + 1, 0x00);    // Divisor high byte = 0
    outb(COM1 + 3, 0x03);    // 8 bits, no parity, 1 stop bit (8N1), clear DLAB
    outb(COM1 + 2, 0xC7);    // Enable FIFO, clear TX/RX queues, 14-byte threshold
    outb(COM1 + 4, 0x0B);    // IRQs enabled, RTS/DSR set

    // Loopback test to verify the serial chip exists and works
    outb(COM1 + 4, 0x1E);    // Set in loopback mode
    outb(COM1 + 0, 0xAE);    // Send test byte 0xAE

    if (inb(COM1 + 0) != 0xAE) {
        return false;        // Serial port faulty or absent
    }

    // Normal operation mode (not loopback)
    outb(COM1 + 4, 0x0F);
    return true;
}

static bool serial_is_transmit_empty(void) {
    return (inb(COM1 + 5) & 0x20) != 0;
}

void serial_write_char(char c) {
    // Convert '\n' to '\r\n' so terminals return the cursor to column 0
    if (c == '\n') {
        serial_write_char('\r');
    }

    while (!serial_is_transmit_empty()) {
        // Wait until UART transmit buffer is ready
    }

    outb(COM1, (uint8_t)c);
}

void serial_print(const char *str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        serial_write_char(str[i]);
    }
}

