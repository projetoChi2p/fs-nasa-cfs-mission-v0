import serial
import struct

reset_serial = serial.Serial(
    port='/dev/ttyUSB-FlashPro5B',
    baudrate=921600,
    bytesize=serial.EIGHTBITS,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    timeout=1
)

address = 0
bit = 0
tx_buffer = bytearray(14)
struct.pack_into('<Q', tx_buffer, 0, address)
struct.pack_into('<H', tx_buffer, 8, bit)
tx_buffer[10] = 0x00

reset_serial.write(tx_buffer)
