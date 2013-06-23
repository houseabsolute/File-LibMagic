#include <magic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int Exit(char * c, int i, magic_t m);

int main(void) {

	char * TestPattern="Hello World\n";
	magic_t m;
	int ret_i;
	char * c;

	m    =magic_open(MAGIC_NONE); if (m==NULL)   { Exit("Err",1,m); }
	ret_i=magic_load(m,"magic");     if (ret_i==-1) { Exit("Error Load",1,m); }
	// ret_i=magic_load(m,"/NotExistentFile");
				      if (ret_i==-1) { Exit("Error Load NotExistentFile",1,m); }

	c = (char *) magic_buffer(m, TestPattern, strlen(TestPattern));
	if (c==NULL) { 
		Exit("E",2,m); 
	} else {
		printf("%s\n",c);
	}

	// c = (char *) magic_file(m, "/etc/passwd"); 
	c = (char *) magic_file(m, "/NotExistent"); 
	if (c==NULL) { 
		Exit("F",3,m); 
	} else {
		printf("%s\n",c);
	}

	magic_close(m);

	exit(0);
}

int Exit(char * c, int i, magic_t m) {
	
	
	printf("%s\n",c);
	if (i==1) { printf("%s\n", magic_error(m)); }

	exit(i);
}

