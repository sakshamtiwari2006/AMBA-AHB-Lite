module master (
    input HCLK,
    input HRESETn,
    input HENABLE,         // Start transfer trigger
    
    input [31:0] start_addr,
    input [31:0] write_data,
    input write,           // 1 = Write, 0 = Read
    input [2:0] size,      // FIX: Changed from [1:0] to [2:0]
    input [2:0] burst,     // FIX: Changed from [1:0] to [2:0]
    
    input [31:0] HRDATA,
    input HRESP,
    input HREADY,
    
    output reg [31:0] HWDATA,
    output reg [31:0] HADDR,
    output reg [2:0]  HSIZE,  // FIX: Changed from [1:0] to [2:0]
    output reg [3:0]  HWSTRB,
    output reg HWRITE,
    output reg [1:0] HTRANS,
    output reg [2:0] HBURST  // FIX: Changed from [1:0] to [2:0]
);

    // State Encoding
    localparam IDLE    = 2'b00, 
               BUSY    = 2'b01, 
               NON_SEQ = 2'b10, 
               SEQ     = 2'b11;

    reg [1:0] ps, ns;
    reg [3:0] beat_count;
    reg       data_phase_active;
    reg       data_phase_write;

    // ------------------------------------------------------------------------
    // 1. Present State Register Block
    // ------------------------------------------------------------------------
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            ps <= IDLE;
        else if (HREADY)
            ps <= ns;
    end

    // ------------------------------------------------------------------------
    // 2. Next State Combinational Logic
    // ------------------------------------------------------------------------
    always @(*) begin
        case (ps)
            IDLE: begin
                if (HENABLE) 
                    ns = NON_SEQ;
                else 
                    ns = IDLE;
            end

            NON_SEQ: begin
                if (HRESP)
                    ns = IDLE;          // Slave error: abort burst
                else if (burst != 3'b000) // FIX: Adjusted for 3-bit burst width
                    ns = SEQ;
                else 
                    ns = IDLE;
            end

            SEQ: begin
                if (HRESP)
                    ns = IDLE;
                else if (beat_count > 0) 
                    ns = SEQ;
                else if (HENABLE)    // Seamless restart for continuous bursts
                    ns = NON_SEQ;
                else 
                    ns = IDLE;
            end

            BUSY:    ns = IDLE;
            default: ns = IDLE;
        endcase
    end

    // ------------------------------------------------------------------------
    // 3. Beat Counter Register Block
    // ------------------------------------------------------------------------
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            beat_count <= 4'd0;
        end else if (HREADY) begin
            case (ns)
                NON_SEQ: begin
                    case (burst)
                        3'b001:  beat_count <= 4'd3;  // INCR4 / BURST 1
                        3'b010:  beat_count <= 4'd3;  // WRAP4 / BURST 2
                        default: beat_count <= 4'd0; 
                    endcase
                end
                SEQ: begin
                    if (beat_count > 0)
                        beat_count <= beat_count - 1'b1;
                end
                default: beat_count <= 4'd0;
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // 4. Drive HTRANS Output
    // ------------------------------------------------------------------------
    always @(*) begin
        case (ps)
            IDLE:    HTRANS = IDLE;
            BUSY:    HTRANS = BUSY;
            NON_SEQ: HTRANS = NON_SEQ;
            SEQ:     HTRANS = SEQ;
            default: HTRANS = IDLE;
        endcase
    end

    // Track active data phase
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            data_phase_active <= 1'b0;
        else if (HREADY)
            data_phase_active <= (ps != IDLE);
    end

    // ------------------------------------------------------------------------
    // 5. Address Phase & Data Phase Pipelined Register Block
    // ------------------------------------------------------------------------
    function [31:0] get_next_addr;
        input [31:0] current_addr;
        input [2:0]  size;  
        input [2:0]  burst; 
        
        reg [31:0] incr_step;
        reg [31:0] boundary_mask;
        
        begin
            case (size)
                3'b000:  incr_step = 32'd1; 
                3'b001:  incr_step = 32'd2; 
                3'b010:  incr_step = 32'd4; 
                default: incr_step = 32'd4;
            endcase

            if (burst == 3'b010) begin 
                boundary_mask = (incr_step << 2) - 1'b1;
                get_next_addr = (current_addr & ~boundary_mask) | ((current_addr + incr_step) & boundary_mask);
            end 
            else begin 
                get_next_addr = current_addr + incr_step;
            end
        end
    endfunction
    
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR            <= 32'b0;
            HWRITE           <= 1'b0;
            HSIZE            <= 3'b010;   // Default 32-bit Word
            HWDATA           <= 32'b0;
            HWSTRB           <= 4'b0000;
            HBURST           <= 3'b000;   // Default SINGLE
            data_phase_write <= 1'b0;
        end else if (HREADY) begin
            // Lock control attributes
            HWRITE           <= write;
            HSIZE            <= size;
            data_phase_write <= write;

            // Address Phase Generation
            case (ns)
                NON_SEQ: begin
                    HADDR  <= start_addr;
                    HBURST <= burst;
                end
                
                SEQ: begin
                    HADDR  <= get_next_addr(HADDR, size, HBURST);
                end

                default: begin
                    HADDR            <= HADDR; 
                    HBURST           <= 3'b000;
                    if (ps == IDLE) begin
                        data_phase_write <= 1'b0;
                    end
                end
            endcase

            // Data Phase Execution: Drive write data and strobe
            if (ps != IDLE || data_phase_active) begin
                if (data_phase_write) begin
                    HWDATA <= write_data;
                    case (HSIZE)
                        3'b000:  HWSTRB <= (4'b0001 << HADDR[1:0]);
                        3'b001:  HWSTRB <= HADDR[1] ? 4'b1100 : 4'b0011;
                        3'b010:  HWSTRB <= 4'b1111;
                        default: HWSTRB <= 4'b1111;
                    endcase
                end else begin
                    HWDATA <= 32'b0;
                    HWSTRB <= 4'b0000;
                end
            end else begin
                HWSTRB <= 4'b0000;
            end
        end
    end

endmodule