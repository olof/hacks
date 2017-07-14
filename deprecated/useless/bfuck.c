/* Copyright (c) 2009, 2011, Olof Johansson <olof@ethup.se>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 *
 *   * Redistributions of source code must retain the above copyright 
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above 
 *     copyright notice, this list of conditions and the following 
 *     disclaimer in the documentation and/or other materials provided 
 *     with the distribution.
 *   * The names of its contributors may not be used to endorse or 
 *     promote products derived from this software without specific 
 *     prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* * Quirks, and behaviour * * * * * * * * * * * * * * * * * * * * * * 
 * bfuck dynamically allocates memory before parsing, based on numbers 
 * of > and <.  this is handled in mem_used helper function.
 * 
 * if the brainfuck script tries to run outside the allocated realm 
 * the parser will put it on the other side (i.e it's circular).
 *
 * , will handle a EOF as 0. (this makes it possible to use ^D to 
 * produce a NULL-character from stdin.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

int mem_used(char *fb, off_t siz);

int main(int argc, char *argv[])
{
	FILE *fp;
	struct stat st;
	char *fbuf, *fbuf_0;
	char *bbuf, *bbuf_0;
	int msize;

	int l=0;

	if(argc!=2) {
		printf("USAGE: %s <file>\n", argv[0]);
		exit(1);
	}

	if(stat(argv[1], &st)!=0) {
		perror("stat");
		exit(2);
	}

	if((fp=fopen(argv[1], "r"))<0) {
		perror("fopen");
		exit(2);
	}

	fbuf=fbuf_0=calloc(st.st_size+1, 1);
	if(!fbuf) { 
		perror("calloc");
		exit(2);
	}

	fread(fbuf_0, 1, st.st_size, fp);
	fclose(fp);
	msize=mem_used(fbuf_0, st.st_size);
	bbuf=bbuf_0=calloc(msize, 1);

	if(!bbuf) {
		perror("calloc");
		exit(2);
	}

	while(fbuf<fbuf_0+st.st_size) {
		switch(*fbuf) {
			case '+': ++(*bbuf); break;
			case '-': --(*bbuf); break;
			case '>': 
				bbuf<bbuf_0+msize-1?(++bbuf):(bbuf=bbuf_0); 
				break;
			case '<': 
				bbuf>bbuf_0?(--bbuf):(bbuf=(bbuf_0+msize-1)); 
				break;
			case '.': putchar(*bbuf); break;
			case ',': 
				*bbuf=getchar(); 
				*bbuf==EOF?*bbuf=0:0; 
				break;
			case '[': 
				if(!*bbuf) {
					while(*(++fbuf)!=']' || l>0) {
						if(*fbuf=='[') ++l;
						if(*fbuf==']') --l;
					}
				}
				break;
			case ']': 
				if( *bbuf) {
					while(*(--fbuf)!='[' || l>0) {
						if(*fbuf=='[') --l;
					   	if(*fbuf==']') ++l;
					}
				}
				break;
			default: break;
		}
		++fbuf;
	}

	free(fbuf_0);
	free(bbuf_0);
	return 0;
}

int mem_used(char *fb, off_t siz)
{
	int i,n,m;
	n=m=0;
	for(i=0;i<siz;++i) {
		if(fb[i]=='>') {
			++n;
			if(n>m) ++m;
		} else if(fb[i]=='<' && n>0) {
			--n;
		}
	}

	return m+1;
}

