$(CC) = gcc
LIBS = -ldb
CFLAGS = -Wall
TARGET = postfix-stats-get
PREFIX = /usr

all: $(TARGET)

$(TARGET):
	$(CC) -DLINUX -o $(TARGET) $(TARGET).c $(CFLAGS) $(LIBS)

install:
	install -Dm755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/postfix-stats-get

uninstall:
	-rm -f $(DESTDIR)$(PREFIX)/bin/postfix-stats-get

clean:
	rm -f *.o  postfix-stats-get

.PHONY: all install uninstall clean
