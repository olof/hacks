/* imei_validate: validate or generate checksum for IMEI
 * 
 * Copyright 2009, Olof Johansson <olof@ethup.se>
 * 
 * Copying and distribution of this file, with or without 
 * modification, are permitted in any medium without royalty 
 * provided the copyright notice are preserved. This file is 
 * offered as-is, without any warranty.
 */

#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
	int i;
	char imei[15];
	char chksum=0;

	if(argc!=2) {
		printf("%s <imei>\n", argv[0]);
		return 0;
	}

	if(strlen(argv[1])!=14 && strlen(argv[1])!=15) {
		printf("Invalid imei\n");
		return 1;
	}	

	for(i=0;i<14;++i) {
		imei[i]=argv[1][i]-'0';
	}

	for(i=1;i<14;i+=2) {
		imei[i]*=2;
	}

	for(i=0;i<14;++i) {
		if(imei[i]>=10) {
			chksum+=1;
			imei[i]-=10;
		}
		chksum+=imei[i];
	}

	for(i=0;(chksum+i)%10;++i)
		;

	chksum=i;

	if(strlen(argv[1])==15) {
		if(chksum == argv[1][14]-'0') {
			printf("Correct imei\n");
			return 0;
		} else {
			printf("Incorrect imei\n");
			return 1;
		}
	} else {
		printf("%s%d\n", argv[1], chksum);
	}

	return 0;
}

