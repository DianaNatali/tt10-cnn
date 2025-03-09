`ifndef __CONSTANTS_SOBEL__
`define __CONSTANTS_SOBEL__

localparam MAX_PIXEL_BITS = 24;              
localparam PIXEL_WIDTH_OUT = 8;
localparam KERNEL_NUM = 24;
localparam KERNEL_COUNTER_BITS = $clog2(KERNEL_NUM);
localparam MATRIX_COUNTER_MAX_BITS = 3;                             //Counter for 3x3 matrix of pixels to convolve with kernel
localparam POOL_COUNTER_MAX_BITS = 4;
localparam MAX_GRADIENT_WIDTH = $clog2((1 << PIXEL_WIDTH_OUT)*3);   //Max value of gradient could be a sum of three max values of 2^(PIXEL WIDTH) bits
localparam MAX_PIXEL_VAL = 1<< PIXEL_WIDTH_OUT;                     //Binarization max value
localparam MAX_GRADIENT_SUM_WIDTH = $clog2((1 << MAX_GRADIENT_WIDTH)*2);    
localparam MAX_RESOLUTION_BITS = 24;
localparam ZERO_PAD_WIDTH = MAX_PIXEL_BITS - PIXEL_WIDTH_OUT;
localparam FRAC_BITS = 6;
localparam BITS_Q4_6 = 11;

    typedef struct packed {
        logic signed [BITS_Q4_6-1:0] p0;
        logic signed [BITS_Q4_6-1:0] p1;
        logic signed [BITS_Q4_6-1:0] p2;
        logic signed [BITS_Q4_6-1:0] p3;
        logic signed [BITS_Q4_6-1:0] p4;
        logic signed [BITS_Q4_6-1:0] p5;
        logic signed [BITS_Q4_6-1:0] p6;
        logic signed [BITS_Q4_6-1:0] p7;
        logic signed [BITS_Q4_6-1:0] p8;
        logic signed [BITS_Q4_6-1:0] p9;
        logic signed [BITS_Q4_6-1:0] p10;
        logic signed [BITS_Q4_6-1:0] p11;
        logic signed [BITS_Q4_6-1:0] p12;
        logic signed [BITS_Q4_6-1:0] p13;
        logic signed [BITS_Q4_6-1:0] p14;
        logic signed [BITS_Q4_6-1:0] p15;
        logic signed [BITS_Q4_6-1:0] p16;
        logic signed [BITS_Q4_6-1:0] p17;
        logic signed [BITS_Q4_6-1:0] p18;
        logic signed [BITS_Q4_6-1:0] p19;
        logic signed [BITS_Q4_6-1:0] p20;
        logic signed [BITS_Q4_6-1:0] p21;
        logic signed [BITS_Q4_6-1:0] p22;
        logic signed [BITS_Q4_6-1:0] p23;
    } vector_8_Q4_6;

    typedef struct packed {
        logic signed [PIXEL_WIDTH_OUT-1:0] p0;
        logic signed [PIXEL_WIDTH_OUT-1:0] p1;
        logic signed [PIXEL_WIDTH_OUT-1:0] p2;
    } vector_3_8bits;

    typedef struct packed {
        vector_3_8bits vector0;
        vector_3_8bits vector1;
        vector_3_8bits vector2;
    } matrix_3x3_8bits;

    typedef struct packed {
        logic signed [BITS_Q4_6-1:0] p0;
        logic signed [BITS_Q4_6-1:0] p1;
    } vector_2_Q4_6;

    typedef struct packed {
        logic signed [BITS_Q4_6-1:0] p0;
        logic signed [BITS_Q4_6-1:0] p1;
        logic signed [BITS_Q4_6-1:0] p2;
        logic signed [BITS_Q4_6-1:0] p3;
    } vector_4_Q4_6;

    typedef struct packed {
        vector_2_Q4_6 vector0;
        vector_2_Q4_6 vector1;
    } matrix_2x2_Q4_6;

    typedef struct packed {
        vector_4_Q4_6 vector0;
        vector_4_Q4_6 vector1;
        vector_4_Q4_6 vector2;
        vector_4_Q4_6 vector3;
    } matrix_4x4_Q4_6;

`endif
