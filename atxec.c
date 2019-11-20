/*
 * atxec - run command expanding arguments from file or environment
 *
 * To the extent possible under law, Leah Neukirchen <leah@vuxu.org>
 * has waived all copyright and related or neighboring rights to this work.
 * http://creativecommons.org/publicdomain/zero/1.0/
 */

// '''' => '

// # line comment (space or beginning of line before #)
// @file
// @$ENV
// @@argwithone@
// fallbacks?

#include <sys/stat.h>

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAXARGS 2048
int narg;
char *args[MAXARGS];

static void
push_arg(char *s)
{
	if (narg >= MAXARGS) {
		fprintf(stderr, "atxec: too many arguments\n");
		exit(111);
	}

	args[narg++] = s;
}

void
arg_splice(char *s)
{
	char *beg;
	char *t;

	if (!s)
		return;

	while (1) {
		while (isspace(*s) || *s == '#')
			if (*s == '#')  /* skip line comment */
				while (*s && *s != '\n')
					s++;
			else
				s++;

		if (!*s)
			break;

		if (*s == '\'') {  /* rc-quoted string */
			s++;
			beg = t = s;

			while (*s)
				if (*s == '\'') {
					*t++ = *s++;
					if (*s == '\'') {
						s++;
					} else {
						*--t = 0;
						if (!*s)
							beg--;
						break;
					}
				} else {
					*t++ = *s++;
				}
		} else {  /* bareword, may contain # without whitespace */
			beg = s;
			while (*s && !isspace(*s))
				s++;
		}

		push_arg(beg);

		if (*s) {
			*s = 0;
			s++;
		} 
	}
}

void
file_splice(char *file)
{
	struct stat st;
	char *s;

	FILE *f = fopen(file, "rb");
	if (!f)
		return;   /* ignore file does not exist */

	fstat(fileno(f), &st);

	s = calloc(1, st.st_size + 1);
	if (!s) {
		fclose(f);
		return;
	}
	fread(s, 1, st.st_size, f);
	fclose(f);

	arg_splice(s);

	/* leak string, args points into it! */
}

int
main(int argc, char *argv[])
{
	if (argc == 1) {
		fprintf(stderr, "usage\n");
		return 1;
	}

	for (int i = 1; i < argc; i++)
		if (argv[i][0] == '@') {
			if (argv[i][1] == '@')
				push_arg(argv[i]+1);
			if (argv[i][1] == '$')
				arg_splice(getenv(argv[i]+2));
			else
				file_splice(argv[i]+1);
		} else {
			push_arg(argv[i]);
		}

	execvp(args[0], args);

	perror("argsplice: exec");
	return 111;
}
