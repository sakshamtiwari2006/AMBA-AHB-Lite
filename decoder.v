module decoder (
    input  wire [31:0] HADDR,    
    
    output reg        HSEL1,  
    output reg        HSEL2,
    output reg        HSEL3,
    output reg        HSEL4,
    output reg        HSEL_DEFAULT   
);

    always @(*) begin
        // Set default values first to avoid repetitive code
        HSEL1        = 1'b0;
        HSEL2        = 1'b0;
        HSEL3        = 1'b0;
        HSEL4        = 1'b0;
        HSEL_DEFAULT = 1'b0;

        case (HADDR[31:30])
            2'b00: HSEL1 = 1'b1;
            2'b01: HSEL2 = 1'b1;
            2'b10: HSEL3 = 1'b1;
            2'b11: HSEL4 = 1'b1;
            default: HSEL_DEFAULT = 1'b1; // Kept for 4-state simulation safety (x/z handling)
        endcase
    end

endmodule