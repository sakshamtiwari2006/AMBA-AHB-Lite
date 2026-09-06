`timescale 1ns / 1ps

module tb_top_module;

    // Inputs to top_module - Master 0 Control Inputs
    reg        HCLK;
    reg        HRESETn;
    reg        m0_henable;
    reg [31:0] m0_start_addr;
    reg [31:0] m0_write_data;
    reg        m0_write;
    reg [2:0]  m0_size;
    reg [2:0]  m0_burst;
    reg        m0_hbusreq;
    reg        m0_hlock;

    // Control inputs for Master 1
    reg        m1_henable;
    reg [31:0] m1_start_addr;
    reg [31:0] m1_write_data;
    reg        m1_write;
    reg [2:0]  m1_size;
    reg [2:0]  m1_burst;
    reg        m1_hbusreq;
    reg        m1_hlock;

    // Control inputs for Master 2
    reg        m2_henable;
    reg [31:0] m2_start_addr;
    reg [31:0] m2_write_data;
    reg        m2_write;
    reg [2:0]  m2_size;
    reg [2:0]  m2_burst;
    reg        m2_hbusreq;
    reg        m2_hlock;

    // Control inputs for Master 3
    reg        m3_henable;
    reg [31:0] m3_start_addr;
    reg [31:0] m3_write_data;
    reg        m3_write;
    reg [2:0]  m3_size;
    reg [2:0]  m3_burst;
    reg        m3_hbusreq;
    reg        m3_hlock;

    // Outputs from top_module
    wire [31:0] HWDATA;
    wire [31:0] HADDR;
    wire        HWRITE;
    wire [2:0]  HSIZE;
    wire [1:0]  HTRANS;
    wire [2:0]  HBURST;
    wire [3:0]  HWSTRB;
    wire [31:0] HRDATA;
    wire        HRESP;
    wire        HREADY;
    wire [1:0]  HMASTER;
    wire        HMASTLOCK;

    wire hsel_default = uut.HSEL_DEFAULT;
    wire [3:0] hselx  = uut.HSELx;

    // Instantiate Top Module
    top_module uut (
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),

        .m0_henable     (m0_henable),
        .m0_start_addr  (m0_start_addr),
        .m0_write_data  (m0_write_data),
        .m0_write       (m0_write),
        .m0_size        (m0_size),
        .m0_burst       (m0_burst),
        .m0_hbusreq     (m0_hbusreq),
        .m0_hlock       (m0_hlock),

        .m1_henable     (m1_henable),
        .m1_start_addr  (m1_start_addr),
        .m1_write_data  (m1_write_data),
        .m1_write       (m1_write),
        .m1_size        (m1_size),
        .m1_burst       (m1_burst),
        .m1_hbusreq     (m1_hbusreq),
        .m1_hlock       (m1_hlock),

        .m2_henable     (m2_henable),
        .m2_start_addr  (m2_start_addr),
        .m2_write_data  (m2_write_data),
        .m2_write       (m2_write),
        .m2_size        (m2_size),
        .m2_burst       (m2_burst),
        .m2_hbusreq     (m2_hbusreq),
        .m2_hlock       (m2_hlock),

        .m3_henable     (m3_henable),
        .m3_start_addr  (m3_start_addr),
        .m3_write_data  (m3_write_data),
        .m3_write       (m3_write),
        .m3_size        (m3_size),
        .m3_burst       (m3_burst),
        .m3_hbusreq     (m3_hbusreq),
        .m3_hlock       (m3_hlock),

        .HWDATA         (HWDATA),
        .HADDR          (HADDR),
        .HWRITE         (HWRITE),
        .HSIZE          (HSIZE),
        .HTRANS         (HTRANS),
        .HBURST         (HBURST),
        .HWSTRB         (HWSTRB),
        .HRDATA         (HRDATA),
        .HRESP          (HRESP),
        .HREADY         (HREADY),
        .HMASTER        (HMASTER),
        .HMASTLOCK      (HMASTLOCK)
    );

    // 100MHz Clock Generation (10ns Period)
    always #5 HCLK = ~HCLK;

    // Full Signal Monitor
    initial begin
        $display("\nTime(ns) | CLK RSTn | MASTER | HADDR    | HWRITE | HTRANS | HSIZE HBURST | HWSTRB | HSELx HDEF | HWDATA   | HRDATA   | HREADY HRESP");
        $display("----------------------------------------------------------------------------------------------------------------------------------");
        $monitor("%8t |  %b    %b  | M%0d    | %h |   %b    |   %b   |  %b   %b  |  %b  | %b   %b  | %h | %h |   %b      %b",
                 $time, HCLK, HRESETn, HMASTER, HADDR, HWRITE, HTRANS, HSIZE, HBURST, HWSTRB, hselx, hsel_default, HWDATA, HRDATA, HREADY, HRESP);
    end

    initial begin
        // Initialize Inputs
        HCLK          = 0;
        HRESETn       = 0;

        m0_henable    = 0; m0_start_addr = 0; m0_write_data = 0; m0_write = 0; m0_size = 3'b010; m0_burst = 3'b001; m0_hbusreq = 0; m0_hlock = 0;
        m1_henable    = 0; m1_start_addr = 0; m1_write_data = 0; m1_write = 0; m1_size = 3'b010; m1_burst = 3'b001; m1_hbusreq = 0; m1_hlock = 0;
        m2_henable    = 0; m2_start_addr = 0; m2_write_data = 0; m2_write = 0; m2_size = 3'b010; m2_burst = 3'b001; m2_hbusreq = 0; m2_hlock = 0;
        m3_henable    = 0; m3_start_addr = 0; m3_write_data = 0; m3_write = 0; m3_size = 3'b010; m3_burst = 3'b001; m3_hbusreq = 0; m3_hlock = 0;

        // 1. Reset Phase
        #15;
        HRESETn = 1;
        @(posedge HCLK);

        // Request bus for Master 0
        m0_hbusreq = 1'b1;

        // =========================================================
        // 1. WRITE BURST 1 (Addresses 0x10 to 0x1C) - Master 0
        // =========================================================
        m0_start_addr = 32'h0000_0010;
        m0_write      = 1'b1;          // WRITE operation
        m0_size       = 3'b010;         
        m0_burst      = 3'b001;         
        m0_henable    = 1'b1;          

        @(posedge HCLK);
        m0_henable    = 1'b0;          
        
        @(posedge HCLK); m0_write_data = 32'hAAAA_1111; // Data Beat 0 (0x10)
        @(posedge HCLK); m0_write_data = 32'hBBBB_2222; // Data Beat 1 (0x14)
        @(posedge HCLK); m0_write_data = 32'hCCCC_3333; // Data Beat 2 (0x18)

        // =========================================================
        // 2. READ BURST 1 (Addresses 0x10 to 0x1C) - Master 0
        // Pipelined directly after Write Burst 1
        // =========================================================
        
        @(posedge HCLK);
        m0_write_data = 32'hDDDD_4444; // Write Beat 3 (0x1C) completes
        m0_start_addr = 32'h0000_0010; // Read back from 0x10
        m0_write      = 1'b0;          // READ operation
        m0_burst      = 3'b001;         
        m0_henable    = 1'b1;  
        
        @(posedge HCLK);
        m0_henable    = 1'b0;          

        @(posedge HCLK); m0_write_data = 32'h0000_0000; // Read Beat 0 (0x10) HRDATA active
        @(posedge HCLK);                             // Read Beat 1 (0x14) HRDATA active
        @(posedge HCLK);                             // Read Beat 2 (0x18) HRDATA active

        // =========================================================
        // 3. WRITE BURST 2 (Addresses 0x20 to 0x2C) - Master 1
        // Pipelined directly after Read Burst 1
        // =========================================================
        
        @(posedge HCLK);
        m0_hbusreq    = 1'b0;          // Release Master 0
        m1_hbusreq    = 1'b1;          // Request Master 1
        
        wait(HMASTER == 2'd1);         // Wait for Arbiter grant
        m1_start_addr = 32'h4000_0020; // Write to 0x20
        m1_write      = 1'b1;          // WRITE operation
        m1_size       = 3'b010;
        m1_burst      = 3'b001;          
        m1_henable    = 1'b1;
        
        @(posedge HCLK);
        m1_henable    = 1'b0;          // Read Beat 3 (0x1C) HRDATA active

        @(posedge HCLK); m1_write_data = 32'h1111_AAAA; // Data Beat 0 (0x20)
        @(posedge HCLK); m1_write_data = 32'h2222_BBBB; // Data Beat 1 (0x24)
        @(posedge HCLK); m1_write_data = 32'h3333_CCCC; // Data Beat 2 (0x28)

        // =========================================================
        // 4. READ BURST 2 (Addresses 0x20 to 0x2C) - Master 1
        // Pipelined directly after Write Burst 2
        // =========================================================
        
        @(posedge HCLK);
        m1_start_addr = 32'h4000_0020; // Read back from 0x20
        m1_write      = 1'b0;          // READ operation
        m1_burst      = 3'b001;          
        m1_henable = 1'b1;  
        m1_write_data = 32'h4444_DDDD; // Write Beat 3 (0x2C) completes
        
        @(posedge HCLK);
        m1_henable    = 1'b0;          

        @(posedge HCLK); m1_write_data = 32'h0000_0000; // Read Beat 0 (0x20) HRDATA active
        @(posedge HCLK);                             // Read Beat 1 (0x24) HRDATA active
        @(posedge HCLK);                             // Read Beat 2 (0x28) HRDATA active
        @(posedge HCLK);                             // Read Beat 3 (0x2C) HRDATA active

        @(posedge HCLK);
        m1_hbusreq    = 1'b0;          // Release bus
        
        repeat (4) @(posedge HCLK);

        // Display results written in slave memory
        $display("-----------------------------------------------------");
        $display("Verification of Memory Contents after Alternating Sequence:");
        $display("--- Burst 1 Memory Locations ---");
        $display("Mem[0x10] = %h (Expected: AAAA1111)", uut.s1.mem[4]);
        $display("Mem[0x14] = %h (Expected: BBBB2222)", uut.s1.mem[5]);
        $display("Mem[0x18] = %h (Expected: CCCC3333)", uut.s1.mem[6]);
        $display("Mem[0x1C] = %h (Expected: DDDD4444)", uut.s1.mem[7]);
        $display("--- Burst 2 Memory Locations ---");
        $display("Mem[0x20] = %h (Expected: 1111AAAA)", uut.s2.mem[8]);
        $display("Mem[0x24] = %h (Expected: 2222BBBB)", uut.s2.mem[9]);
        $display("Mem[0x28] = %h (Expected: 3333CCCC)", uut.s2.mem[10]);
        $display("Mem[0x2C] = %h (Expected: 4444DDDD)", uut.s2.mem[11]);
        $display("-----------------------------------------------------");

        $finish;
    end

endmodule