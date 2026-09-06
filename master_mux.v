module master_mux(
    input  [1:0]  HMASTER,

    input  [31:0] M0_HADDR,  
    input  [1:0]  M0_HTRANS,
    input         M0_HWRITE, 
    input  [2:0]  M0_HSIZE,
    input  [2:0]  M0_HBURST, 
    input  [3:0]  M0_HWSTRB,  // ADDED
    input  [31:0] M0_HWDATA,

    input  [31:0] M1_HADDR,  
    input  [1:0]  M1_HTRANS,
    input         M1_HWRITE, 
    input  [2:0]  M1_HSIZE,
    input  [2:0]  M1_HBURST, 
    input  [3:0]  M1_HWSTRB,  // ADDED
    input  [31:0] M1_HWDATA,

    input  [31:0] M2_HADDR,  
    input  [1:0]  M2_HTRANS,
    input         M2_HWRITE, 
    input  [2:0]  M2_HSIZE,
    input  [2:0]  M2_HBURST, 
    input  [3:0]  M2_HWSTRB,  // ADDED
    input  [31:0] M2_HWDATA,

    input  [31:0] M3_HADDR,  
    input  [1:0]  M3_HTRANS,
    input         M3_HWRITE, 
    input  [2:0]  M3_HSIZE,
    input  [2:0]  M3_HBURST, 
    input  [3:0]  M3_HWSTRB,  // ADDED
    input  [31:0] M3_HWDATA,

    output reg [31:0] HADDR,
    output reg [1:0]  HTRANS,
    output reg        HWRITE,
    output reg [2:0]  HSIZE,
    output reg [2:0]  HBURST,
    output reg [3:0]  HWSTRB, // ADDED
    output reg [31:0] HWDATA
);

    always @(*) begin
        case (HMASTER)
            2'b00: begin
                HADDR  = M0_HADDR; 
                HTRANS = M0_HTRANS; 
                HWRITE = M0_HWRITE;
                HSIZE  = M0_HSIZE; 
                HBURST = M0_HBURST; 
                HWSTRB = M0_HWSTRB; // ADDED
                HWDATA = M0_HWDATA;
            end
            2'b01: begin
                HADDR  = M1_HADDR; 
                HTRANS = M1_HTRANS; 
                HWRITE = M1_HWRITE;
                HSIZE  = M1_HSIZE; 
                HBURST = M1_HBURST; 
                HWSTRB = M1_HWSTRB; // ADDED
                HWDATA = M1_HWDATA;
            end
            2'b10: begin
                HADDR  = M2_HADDR; 
                HTRANS = M2_HTRANS; 
                HWRITE = M2_HWRITE;
                HSIZE  = M2_HSIZE; 
                HBURST = M2_HBURST; 
                HWSTRB = M2_HWSTRB; // ADDED
                HWDATA = M2_HWDATA;
            end
            2'b11: begin
                HADDR  = M3_HADDR; 
                HTRANS = M3_HTRANS;
                HWRITE = M3_HWRITE;
                HSIZE  = M3_HSIZE; 
                HBURST = M3_HBURST; 
                HWSTRB = M3_HWSTRB; // ADDED
                HWDATA = M3_HWDATA;
            end
            default: begin
                HADDR  = 32'b0; 
                HTRANS = 2'b00; 
                HWRITE = 1'b0;
                HSIZE  = 3'b010;  
                HBURST = 3'b000;  
                HWSTRB = 4'b0000;  // ADDED
                HWDATA = 32'b0;
            end
        endcase
    end

endmodule