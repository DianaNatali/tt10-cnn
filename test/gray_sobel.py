def emulation_gray(data):
    red = (data >> 16) & 0xFF
    green = (data >> 8) & 0xFF
    blue = data & 0xFF
    result = (red>>2)+(red>>5)+(green>>1)+(green>>4)+(blue>>4)+(blue>>5)
    return result