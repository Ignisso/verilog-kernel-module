#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/ioport.h>
#include <linux/printk.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/string.h>
#include <asm/errno.h>
#include <asm/io.h>

MODULE_INFO(intree, "Y");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Ignisso");
MODULE_DESCRIPTION("Simple kernel module for SYKOM lecture");
MODULE_VERSION("1.0");

#define EOF -1

#define SYKT_GPIO_BASE_ADDR (0x00100000)
#define SYKT_GPIO_SIZE (0x8000)
#define SYKT_EXIT (0x3333)
#define SYKT_EXIT_CODE (0x7F)

#define SYKT_GPIO_ADDR_SPACE (baseptr)
#define SYKT_GPIO_A1 (SYKT_GPIO_ADDR_SPACE + 0x2c8)
#define SYKT_GPIO_A2 (SYKT_GPIO_ADDR_SPACE + 0x2d0)
#define SYKT_GPIO_W (SYKT_GPIO_ADDR_SPACE + 0x2d8)
#define SYKT_GPIO_L (SYKT_GPIO_ADDR_SPACE + 0x2e0)
#define SYKT_GPIO_B (SYKT_GPIO_ADDR_SPACE + 0x2e8)

void __iomem *baseptr;
static struct kobject *sykt_sysfs;

static int mmaa1;
static ssize_t mmaa1_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count){
	if(sscanf(buf, "%x", &mmaa1) != EOF)
		writel(mmaa1, SYKT_GPIO_A1);
	else
		printk(KERN_INFO "Error while reading stdin from mmaa1");

	return count;
}
static struct kobj_attribute file_mmaa1 = __ATTR_WO(mmaa1);

static int mmaa2;
static ssize_t mmaa2_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count){
	if (sscanf(buf, "%x", &mmaa2) != EOF)
		writel(mmaa2, SYKT_GPIO_A2);
	else
		printk(KERN_INFO "Error while reading stdin from mmaa2");

	return count;
}
static struct kobj_attribute file_mmaa2 = __ATTR_WO(mmaa2);

static int mmaw;
static ssize_t mmaw_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf) {
	mmaw = readl(SYKT_GPIO_W);
	return sprintf(buf, "%x\n", mmaw);
}

static struct kobj_attribute file_mmaw = __ATTR_RO(mmaw);

static int mmal;
static ssize_t mmal_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf) {
	mmal = readl(SYKT_GPIO_L);
	return sprintf(buf, "%x\n", mmal);
}

static struct kobj_attribute file_mmal = __ATTR_RO(mmal);

static int mmab;
static ssize_t mmab_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf) {
	mmab = readl(SYKT_GPIO_B);
	return sprintf(buf, "%x\n", mmab);
}

static struct kobj_attribute file_mmab = __ATTR_RO(mmab);


int my_init_module(void){
	printk(KERN_INFO "Init my sykt module.\n");
	baseptr=ioremap(SYKT_GPIO_BASE_ADDR, SYKT_GPIO_SIZE);
	sykt_sysfs = kobject_create_and_add("sykt", kernel_kobj);

	if(!sykt_sysfs) {
		printk(KERN_INFO "Error while creating kobj");
	}
	else {
		if(sysfs_create_file(sykt_sysfs, &file_mmaa1.attr)) {
			printk(KERN_INFO "Error while creating file mmaa1.\n");
		}
		if(sysfs_create_file(sykt_sysfs, &file_mmaa2.attr)) {
			printk(KERN_INFO "Error while creating file mmaa2.\n");
			sysfs_remove_file(sykt_sysfs, &file_mmaa1.attr);
		}
		if(sysfs_create_file(sykt_sysfs, &file_mmaw.attr)) {
			printk(KERN_INFO "Error while creating file mmaw.\n");
			sysfs_remove_file(sykt_sysfs, &file_mmaa1.attr);
			sysfs_remove_file(sykt_sysfs, &file_mmaa2.attr);
		}
		if(sysfs_create_file(sykt_sysfs, &file_mmal.attr)) {
			printk(KERN_INFO "Error while creating file mmal.\n");
			sysfs_remove_file(sykt_sysfs, &file_mmaa1.attr);
			sysfs_remove_file(sykt_sysfs, &file_mmaa2.attr);
			sysfs_remove_file(sykt_sysfs, &file_mmaw.attr);
		}
		if(sysfs_create_file(sykt_sysfs, &file_mmab.attr)) {
			printk(KERN_INFO "Error while creating file mmab.\n");
			sysfs_remove_file(sykt_sysfs, &file_mmaa1.attr);
			sysfs_remove_file(sykt_sysfs, &file_mmaa2.attr);
			sysfs_remove_file(sykt_sysfs, &file_mmaw.attr);
			sysfs_remove_file(sykt_sysfs, &file_mmal.attr);
		}
	}
	return 0;
}
void my_cleanup_module(void){
	printk(KERN_INFO "Cleanup my sykt module.\n");
	writel(SYKT_EXIT | ((SYKT_EXIT_CODE)<<16), baseptr);
	kobject_put(sykt_sysfs);
	sysfs_remove_file(sykt_sysfs, &file_mmaa1.attr);
	sysfs_remove_file(sykt_sysfs, &file_mmaa2.attr);
	sysfs_remove_file(sykt_sysfs, &file_mmaw.attr);
	sysfs_remove_file(sykt_sysfs, &file_mmal.attr);
	sysfs_remove_file(sykt_sysfs, &file_mmab.attr);
	iounmap(baseptr);
}

module_init(my_init_module);
module_exit(my_cleanup_module);
