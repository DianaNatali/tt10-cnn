import gpiozero as gpio
import spidev
import numpy as np
from emulation_gray import *

class SpiBus:
    def __init__(self, freq=1000000):
        self.spi = spidev.SpiDev()
        self.spi.open(0, 0)  # Open SPI bus 0, device 0
        self.spi.max_speed_hz = freq  # Set SPI speed
        self.spi.mode = 0b11  # SPI mode

    def spi_transfer(self, data, n_bytes):
        data &= 0xFFFFFF
        msg = data.to_bytes(n_bytes, 'little')
        response = self.spi.xfer2(msg)
        return response

    def set_freq(self, freq):
        self.spi.max_speed_hz = freq  # Set SPI speed

class ImgPreprocessingChip:
    def __init__(self, spi:SpiBus=None):
        self.spi_bus = spi
        self.nreset = gpio.OutputDevice(18, active_high=True, initial_value=False )
        self.select_process_bit0 = gpio.OutputDevice(17, active_high=True, initial_value=False)
        self.select_process_bit1 = gpio.OutputDevice(27, active_high=True, initial_value=False)
        self.start_sobel = gpio.OutputDevice(22, active_high=True, initial_value=False)
        self.LFSR_enable = gpio.OutputDevice(2, active_high=True, initial_value=False)
        self.seed_stop = gpio.OutputDevice(3, active_high=True, initial_value=False)
        self.lfsr_en_i = gpio.OutputDevice(4, active_high=True, initial_value=False)

    def set_bypass_conf(self):
        self.select_process_bit0.on()
        self.select_process_bit1.on()
        self.start_sobel.off()

    def set_gray_conf(self):
        self.select_process_bit0.off()
        self.select_process_bit1.on()
        self.start_sobel.off()

    def set_sobel_conf(self):
        self.select_process_bit0.on()
        self.select_process_bit1.off()
        self.start_sobel.on()

    def set_graysobel_conf(self):
        self.select_process_bit0.off()
        self.select_process_bit1.off()
        self.start_sobel.on()

    def echo(self, n_rand, use_gray=False):
        self.nreset.on()

        random_array = np.random.randint(0, 2**24, n_rand, dtype=np.uint32)
        for i, data in enumerate(random_array):
            print(hex(data))
            received_data = self.spi_bus.spi_transfer(int(data), 6)
            print(f'{i} {int.from_bytes(received_data[3:], "little"):x}', end='')

            if use_gray:
                print(f' {emulation_gray(data):x}', end='')

            print()  
            hex_data = [hex(x) for x in received_data]
            print(hex_data)

    def echo_sobel(self):
        self.nreset.on()

        random_array = [89, 88, 84, 89, 90, 88, 92, 94, 91, 95, 96, 92, 94, 95, 92, 96, 101, 104, 0, 0]
        for i, data in enumerate(random_array[:9]):
            received_data = self.spi_bus.spi_transfer(int(data), 5)
            if i == 8:
                print(f'{i} {int.from_bytes(received_data[3:], "little"):x}')
                hex_data = [hex(x) for x in received_data]
                print(hex_data)

        for i, data in enumerate(random_array[9:]):
            received_data = self.spi_bus.spi_transfer(int(data), 5)
            if i%3 == 0 and i > 1:
                print(f'{i} {int.from_bytes(received_data[3:], "little"):x}')
                hex_data = [hex(x) for x in received_data]
                print(hex_data)

    def get_processed_pixel(self, pixel):
        self.nreset.on()

        received_data = self.spi_bus.spi_transfer(int(pixel), 6)
        processed_pixel = int.from_bytes(received_data[3:], "little")
        
        return processed_pixel


if __name__ == "__main__":
    bus_spi = SpiBus()
    chip = ImgPreprocessingChip(spi=bus_spi)
    chip.set_bypass_conf()
    chip.echo(10)
    print('')
    chip.set_gray_conf()
    chip.echo(10, True)
    print('')
    chip.set_sobel_conf()
    chip.echo_sobel()