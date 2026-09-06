module slave_mux(
    input  wire        HCLK,
    input  wire        HRESETn,

    input  wire [3:0]  HSELx,
    input  wire        HSEL_DEFAULT,

    input  wire [31:0] S0_HRDATA, S1_HRDATA, S2_HRDATA, S3_HRDATA, SDEF_HRDATA,
    input  wire        S0_HRESP,  S1_HRESP,  S2_HRESP,  S3_HRESP,  SDEF_HRESP,
    input  wire        S0_HREADY, S1_HREADY, S2_HREADY, S3_HREADY, SDEF_HREADY,

    output reg  [31:0] HRDATA,
    output reg         HRESP,
    output reg         HREADY         
);

    reg [4:0] hsel_reg;

    // Register HSEL during Address Phase; update only when current transfer completes
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            hsel_reg <= 5'b00000;
        end else if (HREADY) begin
            hsel_reg <= {HSEL_DEFAULT, HSELx};
        end
    end

    always @(*) begin
        case (hsel_reg)
            5'b00001: begin HRDATA = S0_HRDATA;   
                            HRESP = S0_HRESP;   
                            HREADY = S0_HREADY;   
                      end
            5'b00010: begin HRDATA = S1_HRDATA;   
                            HRESP = S1_HRESP;   
                            HREADY = S1_HREADY;   
                      end
            5'b00100: begin 
                            HRDATA = S2_HRDATA;   
                            HRESP = S2_HRESP;   
                            HREADY = S2_HREADY;   
            end
            5'b01000: begin 
                            HRDATA = S3_HRDATA;   
                            HRESP = S3_HRESP;   
                            HREADY = S3_HREADY;   
            end
            5'b10000: begin 
                            HRDATA = SDEF_HRDATA; 
                            HRESP = SDEF_HRESP; 
                            HREADY = SDEF_HREADY; 
            end
            default:  begin 
                            HRDATA = 32'b0;       
                            HRESP = 1'b0;       
                            HREADY = 1'b1;        
            end
        endcase
    end

endmodule
