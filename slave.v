module slave(
    input HCLK,
    input HRESETn,
    input HENABLE,
    
    input [31:0] HADDR,
    input [31:0] HWDATA,
    input HWRITE,
    input [1:0] HSIZE,
    input [3:0] HWSTRB,
    input [1:0] HBURST,
    input [1:0] HTRANS,
    input HSELx,
    
    output [31:0] HRDATA,
    output reg HRESP,
    output reg HREADYOUT
);
    
    reg [31:0] mem[0:1023];
    reg [31:0] addr;
    reg [1:0]  size;
    reg        write;
    reg        valid_read; // High ONLY during a valid Read Data Phase
    
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'h0000_0000;
        end
    end
    
    // Drive HRDATA only when a valid read transfer is in its Data Phase
    assign HRDATA = valid_read ? mem[addr[11:2]] : 32'h0000_0000;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HRESP      <= 1'b0;
            HREADYOUT  <= 1'b1;
            addr       <= 32'b0;
            size       <= 2'b10;
            write      <= 1'b0;
            valid_read <= 1'b0;
        end 
        else begin
            if (HSELx) begin
                // 1. Data Phase Execution (Write)
                if (write) begin
                    case(size)
                        2'b00: begin
                            case(HWSTRB)
                                4'b0001 : mem[addr[11:2]][7:0]   <= HWDATA[7:0];
                                4'b0010 : mem[addr[11:2]][15:8]  <= HWDATA[15:8];
                                4'b0100 : mem[addr[11:2]][23:16] <= HWDATA[23:16];
                                4'b1000 : mem[addr[11:2]][31:24] <= HWDATA[31:24];
                            endcase
                        end
                        2'b01: begin
                            case(HWSTRB)
                                4'b0011 : mem[addr[11:2]][15:0]  <= HWDATA[15:0];
                                4'b1100 : mem[addr[11:2]][31:16] <= HWDATA[31:16];
                                default : mem[addr[11:2]][15:0]  <= HWDATA[15:0];
                            endcase
                        end
                        2'b10:   mem[addr[11:2]] <= HWDATA;
                        default: mem[addr[11:2]] <= HWDATA;
                    endcase
                end            
                
                // 2. Address Phase Sampling for Next Cycle's Data Phase
                addr  <= HADDR;
                size  <= HSIZE;
                
                // Qualify transfers with HTRANS[1] (NONSEQ = 10, SEQ = 11)
                write      <= HWRITE && HTRANS[1]; 
                valid_read <= !HWRITE && HTRANS[1]; // True ONLY during valid Read cycles
                
                HRESP      <= 1'b0;
                HREADYOUT  <= 1'b1;
            end else begin
                write      <= 1'b0;
                valid_read <= 1'b1;
            end
        end
    end   
    
endmodule