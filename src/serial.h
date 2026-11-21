#ifndef SERIAL_H
#define SERIAL_H

#include <stdbool.h>

bool serial_init(void);
void serial_write_char(char c);
void serial_print(const char *str);


#endif // !

