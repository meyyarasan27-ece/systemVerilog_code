module spi_pro (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] tx_data,
    input  logic       miso,

    output logic [7:0] rx_data,
    output logic       busy,
    output logic       sclk,
    output logic       mosi,
    output logic       cs_n
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        TRANSFER,
        DONE
    } state_t;

    state_t state;

    logic [7:0] shift_tx;
    logic [7:0] shift_rx;
    logic [2:0] bit_cnt;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state    <= IDLE;
            sclk     <= 1'b0;
            cs_n     <= 1'b1;
            mosi     <= 1'b0;
            rx_data  <= 8'h00;
            shift_tx <= 8'h00;
            shift_rx <= 8'h00;
            bit_cnt  <= 3'd0;
            busy     <= 1'b0;
        end

        else begin

            case(state)
                IDLE: begin
                    busy <= 1'b0;
                    cs_n <= 1'b1;
                    sclk <= 1'b0;

                    if(start)
                        state <= LOAD;
                end

                LOAD: begin
                    busy     <= 1'b1;
                    cs_n     <= 1'b0;
                    shift_tx <= tx_data;
                    shift_rx <= 8'h00;
                    bit_cnt  <= 3'd7;
                    mosi <= tx_data[7];
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    sclk <= ~sclk;
                    if(sclk == 1'b0) begin
                        shift_rx <= {shift_rx[6:0], miso};
                    end

                    else begin
                        if(bit_cnt != 0) begin
                            shift_tx <= {shift_tx[6:0],1'b0};
                            bit_cnt <= bit_cnt - 1'b1;
                            mosi <= shift_tx[6];
                        end
                        else begin
                            state <= DONE;
                        end

                    end

                end

                DONE: begin

                    busy <= 1'b0;
                    cs_n <= 1'b1;
                    sclk <= 1'b0;

                    rx_data <= shift_rx;

                    state <= IDLE;

                end

               
                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end

endmodule
