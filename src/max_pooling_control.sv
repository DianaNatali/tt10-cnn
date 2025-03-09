`ifdef COCOTB_SIM
  `include "../src/parameters.svh"
`else
  `include "parameters.svh"
`endif


module max_pooling_ctr (
        input logic    clk_i,
        input logic    nreset_i,

        input logic    start_mp_i,
        input logic    px_rdy_i,
        input logic    [PIXEL_WIDTH_OUT-1:0] in_value_i,

        output logic   [BITS_Q4_6-1:0] out_px_o,
        output logic   px_rdy_o
    );

    logic [POOL_COUNTER_MAX_BITS:0] counter_pool;
    logic [MAX_RESOLUTION_BITS-1:0] counter_pixels;
    logic px_ready;
    
    matrix_4x4_Q4_6 matrix_in_values; 

    logic [BITS_Q4_6-1:0] out_conv_core;
    logic [BITS_Q4_6-1:0] out_conv;

    typedef enum logic [2:0]{
        IDLE,
        FIRST_MATRIX, 
        NEXT_MATRIX, 
        END_FRAME} state_t;

    state_t fsm_state, next;

    conv_core conv1(
        .input_data(matrix_in_values),
        .kernel(kernel_i),
        .out_conv_o(out_conv_core)
    );


    always_ff @(posedge clk_i)begin
        if(!nreset_i)begin
            fsm_state <= IDLE;
        end else begin
            fsm_state <= next;
        end
    end

    always_comb begin
        case(fsm_state)
            IDLE: begin
                if(start_mp_i) next = FIRST_MATRIX;
                else next = IDLE;
            end
            FIRST_MATRIX: begin 
                if (counter_pixels == 1) next = NEXT_MATRIX; 
                else next = FIRST_MATRIX;
            end
            NEXT_MATRIX:begin
                if (start_mp_i == 0) next = FIRST_MATRIX; 
                else next = NEXT_MATRIX;
            end
            default: next = IDLE;
        endcase
    end

    always_ff @(posedge clk_i)begin
        if (!nreset_i)begin
            counter_pool <= 'b0;
            counter_pixels <= 'b0;
            px_ready <= 'b0;
            matrix_in_values <= 'b0;
        end else begin
            case (next)
                IDLE: begin
                    px_ready <= 'b0;
                    counter_pixels <= 'b0;
                    counter_pool <= 'b0;
                end
                FIRST_MATRIX: begin
                    px_ready <= 'b0;
                    if (px_rdy_i) begin
                        case(counter_pool)
                            0: matrix_in_values.vector0.p0 <= in_value_i;
                            1: matrix_in_values.vector0.p1 <= in_value_i;
                            2: matrix_in_values.vector0.p2 <= in_value_i;
                            3: matrix_in_values.vector0.p3 <= in_value_i;
                            4: matrix_in_values.vector1.p0 <= in_value_i;
                            5: matrix_in_values.vector1.p1 <= in_value_i;
                            6: matrix_in_values.vector1.p2 <= in_value_i;
                            7: matrix_in_values.vector1.p3 <= in_value_i;
                            8: matrix_in_values.vector2.p0 <= in_value_i;
                            9: matrix_in_values.vector2.p1 <= in_value_i;
                            10: matrix_in_values.vector2.p2 <= in_value_i;
                            11: matrix_in_values.vector2.p3 <= in_value_i;
                            12: matrix_in_values.vector3.p0 <= in_value_i;
                            13: matrix_in_values.vector3.p1 <= in_value_i;
                            14: matrix_in_values.vector3.p2 <= in_value_i;
                            15: matrix_in_values.vector3.p3 <= in_value_i;
                        endcase
                        counter_pool <= counter_pool + 1;
                        if (counter_pool == 15) begin
                            counter_pixels <= counter_pixels + 1;
                            counter_pool <= 'b0;
                            px_ready <= 'b1;
                        end
                    end
                end
                NEXT_MATRIX: begin
                    px_ready <= 'b0;
                    if (px_rdy_i) begin
                        case(counter_pool)
                            0: begin 
                                matrix_in_values.vector0 <= matrix_in_values.vector2;
                                matrix_in_values.vector1 <= matrix_in_values.vector3;
                                matrix_in_values.vector2.p0 <= in_value_i;
                            end
                            1: begin
                                matrix_in_values.vector2.p1 <= in_value_i;
                            end
                            2: begin
                                matrix_in_values.vector2.p2 <= in_value_i;
                            end
                            3: begin
                                matrix_in_values.vector3.p0 <= in_value_i;
                            end
                            4: begin
                                matrix_in_values.vector3.p1 <= in_value_i;
                            end
                            5: begin
                                matrix_in_values.vector3.p2 <= in_value_i;
                            end
                        endcase
                        counter_pool <= counter_pool + 1;
                        if (counter_pool == 5) begin
                            counter_pixels <= counter_pixels + 1;
                            counter_pool <= 'b0;
                            px_ready <= 'b1;
                        end
                    end
                end
                default: begin
                    px_ready <= 'b0;
                    counter_pixels <= 'b0;
                    counter_pool <= 'b0;
                end
            endcase
        end
    end

    always_ff @(posedge clk_i)begin
        if (!nreset_i)begin
            out_conv <= '0;
            px_rdy_o <= '0;
        end else begin
            px_rdy_o <= '0;
            if(px_ready) begin
                out_conv <= out_conv_core;
                px_rdy_o <= px_ready;
            end
        end
    end
    
    assign  out_px_o = out_conv;

endmodule