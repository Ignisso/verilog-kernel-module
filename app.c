#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#define HEX 16
#define MAX_BUFFER 1024
#define TIMEOUT 10

#define SYSFS_REG_A1 "/sys/kernel/sykt/mmaa1"
#define SYSFS_REG_A2 "/sys/kernel/sykt/mmaa2"
#define SYSFS_REG_W "/sys/kernel/sykt/mmaw"
#define SYSFS_REG_L "/sys/kernel/sykt/mmal"
#define SYSFS_REG_B "/sys/kernel/sykt/mmab"

#define RED "\033[31m"
#define GREEN "\033[32m"
#define ORANGE "\033[33m"
#define RESET "\033[0m"

int test_number = 0;

void write_to_file(char* filename, unsigned int value) {
	if(value > 0xFFFFFF) {
		printf("%sWarn (%d), value is bigger than 24-bit%s\n", ORANGE, 1069, RESET);
	}
	char buffer[MAX_BUFFER] = {0};
	int file = open(filename, O_WRONLY);
	if(file < 0) {
		printf("%sError (%d), while opening file: %s%s\n", RED, errno, filename, RESET);
		exit(2);
	}
	snprintf(buffer, MAX_BUFFER, "%x", value);
	int file_write_status = write(file, buffer, strlen(buffer));
	if(file_write_status != strlen(buffer)) {
		printf("%sError (%d), while writing to file: %s%s\n", RED, errno, filename, RESET);
		close(file);
		exit(3);
	}
	close(file);
}

int read_from_file(char* filename) {
	char buffer[MAX_BUFFER] = {0};
	int file = open(filename, O_RDONLY);
	if(file < 0) {
		printf("%sError (%d), while opening file: %s%s\n", RED, errno, filename, RESET);
		exit(4);
	}
	int file_read_status = read(file, buffer, MAX_BUFFER);
	if(file_read_status > 0) {
		buffer[file_read_status] = '\0';
	} else {
		printf("%sError (%d), while reading file: %s%s\n", RED, errno, filename, RESET);
		close(file);
		exit(5);
	}
	close(file);
	return strtoul(buffer, NULL, HEX);
}

int flag_test(char* filename, unsigned int a, unsigned int exp_b) {
	test_number++;
	write_to_file(filename, a);
	unsigned int res_b = read_from_file(SYSFS_REG_B);
	if(res_b != exp_b) {
		printf("%sTest #%0d FAIL%s\n", RED, test_number, RESET);
		printf("%sError: Wrong flag value, got %x, expected %x%s\n", RED, res_b, exp_b, RESET);
		write_to_file(filename, 0);
		return 1;
	} else {
		printf("%sTest #%0d OK%s\n", GREEN, test_number, RESET);
		write_to_file(filename, 0);
		return 0;
	}
}

int system_test(unsigned int a, unsigned int b, unsigned int exp_w, unsigned int exp_l, unsigned int exp_b, int newline) {
	int timeout = 0;
	test_number++;
	write_to_file(SYSFS_REG_A1, a);
	write_to_file(SYSFS_REG_A2, b);

	unsigned int res_b = read_from_file(SYSFS_REG_B);

	while(res_b == 0x2) {
		res_b = read_from_file(SYSFS_REG_B);
		sleep(1);
		if (timeout == TIMEOUT) {
			printf("%sWarn: Waiting for bit flag timeouted%s\n", ORANGE, RESET);
			return 0;
		}
		timeout += 1;
	}

	unsigned int res_w = read_from_file(SYSFS_REG_W);
	unsigned int res_l = read_from_file(SYSFS_REG_L);

	if(res_w != exp_w || res_l != exp_l || res_b != exp_b) {
		printf("%sTest #%d FAIL%s\n", RED, test_number, RESET);
		if(res_w != exp_w) {
			printf("%sError: Wrong product value, got %x, expected %x%s\n", RED, res_w, exp_w, RESET);
		}
		if(res_l != exp_l) {
			printf("%sError: Wrong ones value, got %x, expected %x%s\n", RED, res_l, exp_l, RESET);
		}
		if(res_b != exp_b) {
			printf("%sError: Wrong flag value, got %x, expected %x%s\n", RED, res_b, exp_b, RESET);
		}
		return 1;
	} else {
		if(newline) printf("%sTest #%0d OK%s\n", GREEN, test_number, RESET);
		else printf("%sTest #%0d OK%s\r", GREEN, test_number, RESET);
		return 0;
	}
}

int main(void) {
	printf("Compiled at %s %s\n", __DATE__, __TIME__);
	srand(time(NULL));
	system_test(0x2, 0x3, 0x6, 0x2, 0b00010000, 1);
	system_test(0x800000, 0x800001, 0x800000, 0x1, 0b00010001, 1);
	flag_test(SYSFS_REG_A1, 0x1000000, 0b00000100);
	flag_test(SYSFS_REG_A2, 0x1000000, 0b00001000);
	system_test(0xA, 0xB, 0x6e, 0x5, 0b00010000, 1);
	while(test_number <= 10000) {
		unsigned long long a = rand() % 0xFFFFFF;
		unsigned long long b = rand() % 0xFFFFFF;
		unsigned int res_w = a * b;
		unsigned int res_l = 0;
		while(res_w != 0){
  			res_w = res_w & (res_w-1);
  			res_l++;
		}
		res_w = a * b;
		unsigned int res_b = ( a * b == res_w) ? 0b00010000 : 0b00010001;
		system_test(a, b, res_w, res_l, res_b, 0);
	}
	return 0;
}
