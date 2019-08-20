# You need a float binary built from the master branch with i2c and bme280
# modules enabled along side all the default modules.
binary=~/Downloads/nodemcu-master-9-modules-2019-08-15-20-32-24-float.bin
esptool.py --port /dev/cu.SLAB_USBtoUART write_flash --flash_size=detect 0 $binary
