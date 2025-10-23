module datapath (
    
                input logic clk, clr,
                // Control signals
                input logic RegWriteD,
                input logic [1:0] ResultSrcD,
                input logic MemWriteD,
                input logic JumpD,
                input logic BranchD,
                input logic [3:0] ALUControlD,
                input logic ALUSrcD,
                input logic [2:0] ImmSrcD,
                input logic SrcAsrcD,
                input logic [2:0] funct3D,
                input logic jumpRegD,
                
                // input signals from Hazard Unit
                input logic StallF,
                input logic StallD,
                input logic FlushD,
                input logic FlushE,
                input logic [1:0] ForwardAE,
                input logic [1:0] ForwardBE,

                input logic [31:0] RD_instr, RD_data,

                // outputs
                output logic [31:0] PCF, // input for Instruction Memory
                output logic [31:0] ALUResultM, WriteDataM, // inputs to Data Memory
                output logic MemWriteM, // we signal for data memory
                output logic [31:0] InstrD, // input to Control Unit
                output logic [3:0] byteEnable, // input to data memory

                // outputs to Hazard Unit
                output logic [4:0] Rs1D, Rs2D, // outputs from ID stage
                output logic [4:0] Rs1E, Rs2E,
                output logic [4:0] RdE, // outputs from EX stage
                output logic PCSrcE, ResultSrcE_zero, RegWriteM, RegWriteW,
                output logic [4:0] RdM, // output from MEM stage
                output logic [4:0] RdW, // output from WB stage
                output logic SrcAsrcE,
                output logic ALUSrcE

);  
    // PC mux
    logic [31:0] PCPlus4F, PCTargetE, PCF_new;

    mux2 pcmux(

        .d0(PCPlus4F),
        .d1(PCTargetE),
        .s(PCSrcE),
        .y(PCF_new)

    );

    // Instruction Fetch (IF) stage
    IFregister ifreg(
        
        .clk(clk),
        .en(~StallF),
        .clr(clr),
        .d(PCF_new),
        .q(PCF)

    );

    assign PCPlus4F = PCF + 32'd4;

    // Instruction Decode (ID) stage
    logic [31:0] PCD, PCPlus4D;
    logic [31:0] RD1, RD2;
    logic [31:0] ResultW;
    logic [31:0] ImmExtD;
    logic [4:0] RdD;

    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];

    IFIDregister ifidreg(

        .clk(clk),
        .clr(FlushD | clr),
        .en(~StallD),
        .RD_instr(RD_instr),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F),
        .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D)
    );

    regfile rf(
        .clk(clk), .we3(RegWriteW), .clr(clr),
        .a1(Rs1D), .a2(Rs2D), .a3(RdW),
        .wd3(ResultW), .rd1(RD1), .rd2(RD2)
    );

    extend ext(
        .instr(InstrD),
        .immsrc(ImmSrcD),
        .immext(ImmExtD)
    );

    // Execute (EX) stage
    logic [31:0] RD1E, RD2E, PCE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4E;

    logic [31:0] SrcAE, SrcBE;
    logic [31:0] WriteDataE;
    logic [31:0] ALUResultE;

    logic RegWriteE;
    logic [1:0] ResultSrcE;
    logic MemWriteE, JumpE, BranchE;
    logic [3:0] ALUControlE;
    logic [2:0] funct3E;
    logic branchTakenE;
    logic jumpRegE;

    IDEXregister idexreg(
        .clk(clk),
        .clr(FlushE | clr),
        // ID stage control signals
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .SrcAsrcD(SrcAsrcD),
        .funct3D(funct3D),
        .jumpRegD(jumpRegD),

        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .SrcAsrcE(SrcAsrcE),
        .funct3E(funct3E),
        .jumpRegE(jumpRegE),

        // datapath inputs & outputs
        .RD1(RD1), .RD2(RD2), .PCD(PCD),
        .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),

        .RD1E(RD1E), .RD2E(RD2E), .PCE(PCE),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E)
    );

    assign PCSrcE = (BranchE & branchTakenE) | JumpE;
    assign ResultSrcE_zero = ResultSrcE[0];

    // SrcA mux
    mux4 inputA_mux(
        .d0(RD1E),
        .d1(ResultW),
        .d2(ALUResultM),
        .d3(PCE),
        .s(ForwardAE),
        .y(SrcAE)
    );

    // SrcB mux
    mux4 inputB_mux(
        .d0(RD2E),
        .d1(ResultW),
        .d2(ALUResultM),
        .d3(ImmExtE),
        .s(ForwardBE),
        .y(SrcBE)
    );

    assign WriteDataE = SrcBE;;

    branch_unit bu(
        .SrcAE(SrcAE), .SrcBE(SrcBE),
        .funct3E(funct3E),
        .branchTakenE(branchTakenE)
    );

    logic [31:0] adder_base;
    assign adder_base = jumpRegE ? SrcAE : PCE;

    assign PCTargetE = adder_base + ImmExtE;

    alu alu(
        .d0(SrcAE), .d1(SrcBE), //  inputs
        .s(ALUControlE), // operation control signal
        .y(ALUResultE) // output
    );

    // --------------------------------------------------------------//
    // Memory write (MEM) stage
    logic [31:0] PCPlus4M;
    logic [2:0] funct3M;
    
    logic [1:0] ResultSrcM;

    logic [1:0] byteAddrM;
    assign byteAddrM = ALUResultM[1:0];

    logic [31:0] load_data;
    logic [31:0] ImmExtM;

    EXMEMregister exmemreg(
        .clk(clk), .clr(clr),
        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .funct3E(funct3E),

        // MEM stage control signals
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .funct3M(funct3M),

        // datapath inputs & outputs
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),

        .ALUResultM(ALUResultM), // output to Data Memory
        .WriteDataM(WriteDataM),
        .RdM(RdM),
        .ImmExtM(ImmExtM),
        .PCPlus4M(PCPlus4M)
    );

    always_comb begin
        byteEnable = 4'b0000;
        case (funct3M) // funct3 determines store type
            3'b000: case (byteAddrM)
                2'b00: byteEnable = 4'b0001; // enable byte 0
                2'b01: byteEnable = 4'b0010; // enable byte 1
                2'b10: byteEnable = 4'b0100; // enable byte 2
                2'b11: byteEnable = 4'b1000; // enable byte 3
                default: byteEnable = 4'b0000;
            endcase
            3'b001: byteEnable = (byteAddrM[1] == 0) // sh
                                    ? 4'b0011 // low half
                                    : 4'b1100; // high half
            3'b010: byteEnable = 4'b1111;
            default: byteEnable = 4'b0000;
        endcase
    end

    loadext loadext(
        .LoadTypeM(funct3M),
        .RD_data(RD_data),
        .byteAddrM(byteAddrM),
        .load_data(load_data)
    );

    // -------------------------------------------------------------//
    // Register file writeback (WB) stage
    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;
    logic [31:0] ImmExtW;
    logic [1:0] ResultSrcW;

    MEMWBregister wbreg(
        .clk(clk), .clr(clr),
        // MEM stage control signals
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),

        // WB stage control signals
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),

        // datapath inputs & outputs
        .ALUResultM(ALUResultM),
        .load_data(load_data),
        .RdM(RdM),
        .ImmExtM(ImmExtM),
        .PCPlus4M(PCPlus4M),

        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .ImmExtW(ImmExtW),
        .PCPlus4W(PCPlus4W)
    );

    mux4 ResultWmux(
        .d0(ALUResultW), .d1(ReadDataW),
        .d2(PCPlus4W), .d3(ImmExtW),
        .s(ResultSrcW),
        .y(ResultW)
    );

endmodule