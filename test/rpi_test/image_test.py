import cv2
from gray_sobel_rpi import *
from matplotlib import pyplot as plt


class image_test():
    def __init__(self, img_path, select_process):
        self.image_path = img_path
        self.select_process = select_process
        self.img_original = cv2.imread(img_path, cv2.IMREAD_COLOR)
        self.img_original = cv2.cvtColor(self.img_original, cv2.COLOR_BGR2RGB)
        self.height, self.width, _ = self.img_original.shape
        self.array_input_image = []
        self.input_image = None
        self.convert_input_img()
        self.input_image_array()

    def get_grayscale_px(self):
        gray_opencv = cv2.cvtColor(self.img_original, cv2.COLOR_RGB2GRAY)
        self.input_image = gray_opencv
        self.array_input_image = [f'{pixel:08b}' for i in range(240) for j in range(320) for pixel in [self.input_image[i][j]]]

    def get_rgb_px(self):
        self.input_image = self.img_original
        self.array_input_image = [f"{pixel[0]:08b}{pixel[1]:08b}{pixel[2]:08b}" for i in range(240) for j in range(320) for pixel in [self.input_image[i][j]]]


    def convert_input_img(self):
        if self.select_process == 1:  # If only sobel
            self.get_grayscale_px()
        else:                         # If sobel + gray, gray or bypass 
            self.get_rgb_px()

    def input_image_array(self):
        if self.select_process == 0 or self.select_process == 1:  # If only sobel or sobel + gray
            self.array_input_image = self.neighbors_array()
        else:                                                     # If sobel + gray or bypass
            pass
        
    def neighbors_px(self, index):
        neighbors = []
        x = index % self.width
        y = index // self.width

        for i in range(max(0, x - 1), min(self.width, x + 2)):
            for j in range(max(0, y - 1), min(len(self.array_input_image) // self.width, y + 2)):
                neighbor_index = j * self.width + i
                neighbors.append(self.array_input_image[neighbor_index])
        return neighbors

    def neighbors_array(self):
        array_neighbors = []
        neighbor_count = 0
        for y in range(1, self.height - 1):
            for x in range(1, self.width - 1):
                i = y * self.width + x
                neighbors = self.neighbors_px(i)
                array_neighbors.append(neighbors)
                neighbor_count += 1
        return array_neighbors

    def get_array_input_image (self):
        return self.array_input_image

    
if __name__ == "__main__":
    image = 'monarch_320x240.jpg'
    bus_spi = SpiBus()
    chip = ImgPreprocessingChip(spi=bus_spi)
    chip.set_graysobel_conf()
    select_process = 0
    img_test = image_test(image, select_process)
    input_array = img_test.get_array_input_image()

    output_array = []

    if select_process == 2 or  select_process == 3:
        for pixel in input_array:
            processed_pixel = chip.get_processed_pixel(int(pixel, 2))
            output_array.append(processed_pixel)
    else:
        for first_9_array in input_array[:1]:
            for i, pixel in enumerate(first_9_array):
                processed_pixel = chip.get_processed_pixel(int(pixel, 2))
                if i == 8:
                    output_array.append(processed_pixel)

        for ind, neighbor_array in enumerate(input_array[1:]):
            for i, pixel in enumerate(neighbor_array[6:]):
                processed_pixel = chip.get_processed_pixel(int(pixel, 2))
                if i == 2:
                    output_array.append(processed_pixel)
            if ind %10000 == 0:
                print(f'Processed pixels: {ind}')

    #Write output RAM into txt file
    if select_process == 3:
        with open('output_image.txt', 'w') as file_out:
            for pixel in output_array:
                file_out.write(f"{pixel}\n")

    else:
       with open('output_image.txt', 'w') as file_out:
           for pixel in output_array:
               file_out.write(f"{int(pixel)}\n")


     # Arrange pixels
    if select_process == 3:
        with open('output_image.txt', 'r') as f: 
            out_hw_txt = f.read().splitlines()

        array_out = np.array(out_hw_txt)

        encode_image = []
        for ind, pixel in enumerate(array_out):
            value = int(pixel)
            red = ((value >> 16) & 0xFF)
            green = ((value >> 8) & 0xFF)
            blue = (value & 0xFF)
            row = [blue, green, red]
            encode_image.append(row)
        array_out_reshape = np.reshape(encode_image, (240, 320, 3))        
    else:
        with open('output_image.txt', 'r') as f: 
            out_hw_txt = f.read().splitlines()  

        array_out = np.array(out_hw_txt)
        
        if select_process == 2:
            array_out_reshape = np.reshape(array_out, (240, 320))
        else:   
            array_out_reshape = np.reshape(array_out, (240-2, 320-2))
        

    array_out = array_out_reshape.astype(np.uint8)
    cv2.imwrite('output_image.jpg', array_out)
    out_image = cv2.imread('output_image.jpg')
    plt.imshow(out_image)
    plt.show()
