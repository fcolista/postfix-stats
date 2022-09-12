/*
 * $jwk: postfix-stats-get.c,v 1.6 2022/09/10 15:31:25 jwk Exp $
 *
 * Copyright (c) 2004 by Joel Knight (www.packetmischief.ca)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * [2004.09.21]
 */


#include <stdio.h>
#include <fcntl.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef LINUX
#include <db_185.h>
#else
#include <db.h>
#endif

#define DBFILE "/tmp/postfix-stats.db"

int main(int argc, char *argv[])
{
	DB *db = NULL;
	DBT key, value;

	if (argc == 1)
		exit(1);

	if ((db = dbopen(DBFILE, O_RDONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH,
			DB_HASH, NULL)) == NULL) {
		perror("Couldn't open dbfile");
		return (1);
	}

	memset(&key, 0, sizeof(key));
	memset(&value, 0, sizeof(value));
	key.data = (u_char *)argv[1];
	key.size = strlen(argv[1]);
	if (db->get(db, &key, &value, 0)) {
		printf("No such key \"%s\"\n", (char *)key.data);
		return (1);
	}

	printf("%d\n", atoi(value.data));

	db->close(db);
	return (0);
}
