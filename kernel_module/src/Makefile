obj-m += kernel_module.o
ccflags-y := -Wno-declaration-after-statement -std=gnu99

default: modules

modules:
	$(MAKE) -C '$(LINUX_DIR)' M='$(PWD)' modules
clean:
	$(MAKE) -C '$(LINUX_DIR)' M='$(PWD)' clean
