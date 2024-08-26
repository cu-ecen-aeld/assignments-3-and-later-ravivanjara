TARGET = writer
CC = gcc
CFLAGS = -g -Wall
.PHONY: default all clean

default: $(TARGET)

$(TARGET).o: $(TARGET).c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $(TARGET).c -o $(TARGET).o

$(TARGET): $(TARGET).o
	$(CROSS_COMPILE)$(CC) $(TARGET).o -o $(TARGET)

clean:
	-rm $(TARGET).o
	-rm $(TARGET)
