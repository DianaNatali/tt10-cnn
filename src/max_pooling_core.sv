`ifdef COCOTB_SIM
  `include "../src/parameters.svh"
`else
  `include "parameters.svh"
`endif

module maxpooling_2x2 (
    input matrix_4x4_Q4_6 input_data,  
    output matrix_2x2_Q4_6 output_data  
);

    logic [BITS_Q4_6-1:0] max_p0, max_p1;

    always @(*) begin
        // Output 1st row and 1st column 
        max_p0 = (input_data.vector0.p0 > input_data.vector0.p1) ? input_data.vector0.p0 : input_data.vector0.p1;
        max_p1 = (input_data.vector0.p2 > input_data.vector0.p3) ? input_data.vector0.p2 : input_data.vector0.p3;
        output_data.vector0.p0 = (max_p0 > max_p1) ? max_p0 : max_p1;

        // Output 2nd row and 1st column 
        max_p0 = (input_data.vector1.p0 > input_data.vector1.p1) ? input_data.vector1.p0 : input_data.vector1.p1;
        max_p1 = (input_data.vector1.p2 > input_data.vector1.p3) ? input_data.vector1.p2 : input_data.vector1.p3;
        output_data.vector1.p0 = (max_p0 > max_p1) ? max_p0 : max_p1;

        // Output 1st row and 2nd column
        max_p0 = (input_data.vector2.p0 > input_data.vector2.p1) ? input_data.vector2.p0 : input_data.vector2.p1;
        max_p1 = (input_data.vector2.p2 > input_data.vector2.p3) ? input_data.vector2.p2 : input_data.vector2.p3;
        output_data.vector0.p1 = (max_p0 > max_p1) ? max_p0 : max_p1;

        // Output 2nd row and 2nd column 
        max_p0 = (input_data.vector3.p0 > input_data.vector3.p1) ? input_data.vector3.p0 : input_data.vector3.p1;
        max_p1 = (input_data.vector3.p2 > input_data.vector3.p3) ? input_data.vector3.p2 : input_data.vector3.p3;
        output_data.vector1.p1 = (max_p0 > max_p1) ? max_p0 : max_p1;
    end

endmodule
