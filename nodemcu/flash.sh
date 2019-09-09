# You need a float binary built from the master branch with i2c and bme280
# modules enabled along side all the default modules.
IMAGE=${IMAGE:-'~/Downloads/nodemcu-master-10-modules-2019-09-05-19-08-46-float.bin'}
esptool.py --port /dev/cu.SLAB_USBtoUART write_flash --flash_size=detect 0 $IMAGE
