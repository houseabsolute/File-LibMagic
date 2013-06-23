#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <magic.h>

int main(void) {
	magic_t m,m2;
	int a;
	void * ptr;

	m=magic_open(MAGIC_NONE);
	ptr=(void*) &m;

	printf("size %d %d\n",sizeof(m), (int) m);

	a = (int) m;
	m2= (magic_t) a;

	printf("W: %d\n",strncmp((char *) &m,(char *) &m2,sizeof(m)));

	printf("size %d %d\n",sizeof(m2), (int) m2);

	return 0;
}
