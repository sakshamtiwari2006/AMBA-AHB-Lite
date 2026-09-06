module arbiter(
    input        HCLK,
    input        HRESETn,
    input        HREADY,
    input  [3:0] HBUSREQ,
    input  [3:0] HLOCK,

    output reg [3:0] HGRANT,
    output reg [1:0] HMASTER,
    output reg       HMASTLOCK
);

    reg [1:0] current_master;
    reg [1:0] next_master;
    reg       locked_state;

    always @(*) begin
        next_master = current_master;

        case (current_master)
            2'd0: begin
                if      (HBUSREQ[1]) next_master = 2'd1;
                else if (HBUSREQ[2]) next_master = 2'd2;
                else if (HBUSREQ[3]) next_master = 2'd3;
                else if (HBUSREQ[0]) next_master = 2'd0;
            end
            2'd1: begin
                if      (HBUSREQ[2]) next_master = 2'd2;
                else if (HBUSREQ[3]) next_master = 2'd3;
                else if (HBUSREQ[0]) next_master = 2'd0;
                else if (HBUSREQ[1]) next_master = 2'd1;
            end
            2'd2: begin
                if      (HBUSREQ[3]) next_master = 2'd3;
                else if (HBUSREQ[0]) next_master = 2'd0;
                else if (HBUSREQ[1]) next_master = 2'd1;
                else if (HBUSREQ[2]) next_master = 2'd2;
            end
            2'd3: begin
                if      (HBUSREQ[0]) next_master = 2'd0;
                else if (HBUSREQ[1]) next_master = 2'd1;
                else if (HBUSREQ[2]) next_master = 2'd2;
                else if (HBUSREQ[3]) next_master = 2'd3;
            end
        endcase
    end

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_master <= 2'd0;
            locked_state   <= 1'b0;
        end else if (HREADY) begin
            if (!locked_state) begin
                current_master <= next_master;
                locked_state   <= HLOCK[next_master] && HBUSREQ[next_master];
            end else begin
                locked_state   <= HLOCK[current_master];
            end
        end
    end

    always @(*) begin
        HGRANT = 4'b0000;
        HGRANT[next_master] = 1'b1;
    end

    always @(*) begin
        HMASTER   = current_master;
        HMASTLOCK = locked_state;
    end

endmodule