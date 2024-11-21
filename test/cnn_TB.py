from pathlib import Path
import numpy as np
import cocotb
import cv2

from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb.triggers import Timer
from matplotlib import pyplot as plt

PIXEL_WIDTH_OUT = 8
FRAC_BITS = 6

def get_neighbors(ram_in, index, width):
    neighbors = []
    x = index % width
    y = index // width

    for i in range(max(0, x - 1), min(width, x + 2)):
        for j in range(max(0, y - 1), min(len(ram_in) // width, y + 2)):
            neighbor_index = j * width + i
            neighbors.append(ram_in[neighbor_index])
    return neighbors


def get_neighbor_array(image, ram_input):
    height, width, _ = image.shape

    ram_neighbors = []

    neighbor_count = 0
    for y in range(1, height - 1):
        for x in range(1, width - 1):
            i = y * width + x
            neighbors = get_neighbors(ram_input, i, width)
            ram_neighbors.append(neighbors)
            neighbor_count += 1
    return ram_neighbors


# Función para convertir a punto fijo si los valores están en formato decimal
def to_fixed_point(value):
    # Factor de escala para convertir a punto fijo (Q1.6, 6 bits para la parte fraccionaria)
    SCALE = 64  # 2^6, porque estamos usando 6 bits de fracción
    return int(value * SCALE)


def create_matrix_3x3(p0, p1, p2, p3, p4, p5, p6, p7, p8, pixel_width):
    #print(f'{p0} {p1} {p2} {p3} {p4} {p5} {p6} {p7}')

    # Convertir los valores a punto fijo
    p0 = to_fixed_point(p0)
    p1 = to_fixed_point(p1)
    p2 = to_fixed_point(p2)
    p3 = to_fixed_point(p3)
    p4 = to_fixed_point(p4)
    p5 = to_fixed_point(p5)
    p6 = to_fixed_point(p6)
    p7 = to_fixed_point(p7)
    p8 = to_fixed_point(p8)

    # Función para empaquetar los valores en vectores de 3 elementos
    def pack_vector_3(a, b, c, width):
        return (a & ((1 << width) - 1)) << (2 * width) | (b & ((1 << width) - 1)) << width | (c & ((1 << width) - 1))

    # Crear los vectores para cada fila
    vector0 = pack_vector_3(p0, p1, p2, pixel_width)
    vector1 = pack_vector_3(p3, p4, p5, pixel_width)
    vector2 = pack_vector_3(p6, p7, p8, pixel_width)

    # Concatena las 3 filas para formar el valor de matrix_3x3
    matrix_3x3_val = (vector0 << (2 * 3 * pixel_width)) | (vector1 << (3 * pixel_width)) | vector2
    return matrix_3x3_val

def decode_q4_6_from_binaryvalue(binary_value):
    if not binary_value.is_resolvable:
        raise ValueError("El valor contiene bits 'X' o 'Z', no puede resolverse.")

    # Obtener el valor entero del BinaryValue (unsigned por defecto)
    raw_value = binary_value.integer

    # Determinar el signo (bit más significativo, MSB)
    num_bits = len(binary_value.binstr)  # Longitud del BinaryValue
    is_negative = (raw_value & (1 << (num_bits - 1))) != 0  # Si el MSB está encendido

    # Si es negativo, aplicar complemento a dos
    if is_negative:
        raw_value -= (1 << num_bits)  # Restar el rango total

    # Separar parte entera y fraccional
    integer_part = raw_value >> 6  # Los 4 bits más significativos
    fractional_part = raw_value & 0x3F  # Los 6 bits menos significativos
    fractional_value = fractional_part / 2**6  # Convertir a decimal

    # Combinar y retornar
    return integer_part + fractional_value



#-------------------------------Convert RGB image to grayscale------------------------------------------
img_original = cv2.imread('monarch_RGB.jpg', cv2.IMREAD_COLOR) 
img_original = cv2.cvtColor(img_original, cv2.COLOR_BGR2RGB)

gray_opencv = cv2.cvtColor(img_original, cv2.COLOR_RGB2GRAY) 
input_image = cv2.normalize(gray_opencv, None, 0, 255, cv2.NORM_MINMAX) / 255.0

#print(input_image)

RAM_input_image = []

for i in range(input_image.shape[0]): 
    for j in range(input_image.shape[1]):
        pixel = input_image[i][j]
        fixed_point_pixel = pixel * (1 << FRAC_BITS) #?
        RAM_input_image.append(pixel)


# with open('monarch_320x240.txt', 'w') as f:
#     for pixel in RAM_input_image:
#         f.write(f"{int(str(pixel), 2)}\n")


#----------------------------------------cocotb test bench----------------------------------------------
# Reset
async def reset_dut(dut, duration_ns):
    dut.nreset_i.value = 0
    await Timer(duration_ns, units="ns")
    dut.nreset_i.value = 1
    dut.nreset_i._log.debug("Reset complete")

# Wait until output file is completely written
async def wait_file():
    Path('output_image_sobel.txt').exists()

async def monitor_px_rdy(px_rdy_o, RAM, px_out):
    while True:
        await RisingEdge(px_rdy_o)
        await FallingEdge(px_rdy_o)
        out_px = decode_q4_6_from_binaryvalue(px_out.value)
        RAM.append(out_px)


@cocotb.test()
async def cnn_TB(dut):


    RAM_neighbors = get_neighbor_array(img_original, RAM_input_image)

    first_neighbors = RAM_neighbors[0]
    print(first_neighbors)

    input_data_val = create_matrix_3x3(*first_neighbors, PIXEL_WIDTH_OUT)

    kernel_val = create_matrix_3x3(1, 1, 1, 1, 1, 1, 1, 1, 1, PIXEL_WIDTH_OUT)


    # Clock cycle
    clock = Clock(dut.clk_i, 20, units="ns") 
    cocotb.start_soon(clock.start(start_high=False))

    # Inital
    dut.in_px_sobel_i.value = 0
    dut.start_cnn_i.value = 0
    dut.px_rdy_i.value = 0

    RAM_output_image = []

    px_rdy_o = dut.px_rdy_o
    px_out_o = dut.out_px_o

    dut.kernel_i.value = kernel_val

    # Start the process to monitor the px_rdy_o signal in parallel
    cocotb.start_soon(monitor_px_rdy(px_rdy_o, RAM_output_image, px_out_o))

    await reset_dut(dut, 10) 

    await FallingEdge(dut.clk_i)

    dut.start_cnn_i.value = 1

    print("La suma de los elementos es:", sum(first_neighbors))

    for ind, pixel in enumerate(first_neighbors):
        dut.in_px_sobel_i.value = to_fixed_point(pixel)
        await FallingEdge(dut.clk_i)
        dut.px_rdy_i.value = 1
        await FallingEdge(dut.clk_i)
        dut.px_rdy_i.value = 0
        print(f'{pixel} {to_fixed_point(pixel)}')
        if ind%8 == 0:
            print(f'Processed pixels: {ind}')

    for i, neighbor_array in enumerate(RAM_neighbors[1:]):
        for ind, pixel in enumerate(neighbor_array[6:]):
            dut.in_px_sobel_i.value = to_fixed_point(pixel)
            await FallingEdge(dut.clk_i)
            dut.px_rdy_i.value = 1
            await FallingEdge(dut.clk_i)
            dut.px_rdy_i.value = 0
        if i%10000 == 0:
            print(f'Processed pixels: {i}')

    await FallingEdge(dut.clk_i)
    dut.px_rdy_i.value = 1
    await FallingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    dut.start_cnn_i.value = 0

    # print(dut.out_px_o.value)
    # print(decode_q4_6_from_binaryvalue(dut.out_px_o.value))

    print(len(RAM_output_image))


    