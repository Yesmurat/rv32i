module maindec (input logic [6:0] op,
                input logic [2:0] funct3,
                input logic [6:0] funct7,
                output logic [1:0] ResultSrcD,
                output logic MemWriteD,
                output logic BranchD, ALUSrcD,
                output logic RegWriteD, JumpD,
                output logic [2:0] ImmSrcD,
                output logic [1:0] ALUOp,
                output logic SrcAsrcD,
                output logic jumpRegD);

    logic [13:0] controls;

    assign {RegWriteD, ImmSrcD, ALUSrcD, MemWriteD,
            ResultSrcD, BranchD, ALUOp, JumpD, SrcAsrcD, jumpRegD} = controls;

    always_comb begin
        case (op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_SrcAsrcD_jumpRegD
            7'b0000011: controls = 14'b1_000_1_0_01_0_00_0_1_1; // I-type (loads)
            7'b0100011: controls = 14'b0_001_1_1_00_0_00_0_1_1; // S-type
            7'b0110011: controls = 14'b1_000_0_0_00_0_10_0_1_1; // R-type
            7'b0010011: controls = 14'b1_000_1_0_00_0_10_0_1_1; // I-type
            7'b1100011: controls = 14'b0_010_0_0_00_1_01_0_1_1; // B-type
            7'b0110111: controls = 14'b1_100_1_0_11_0_00_0_x_1; // lui
            7'b0010111: controls = 14'b1_100_1_0_00_0_00_0_0_1; // auipc
            7'b1101111: controls = 14'b1_011_0_0_10_0_00_1_1_1; // jal
            7'b1100111: controls = 14'b1_000_0_0_10_0_00_1_1_0; // jalr
            default:    controls = 14'b0_000_0_0_00_0_00_0_0_0; // undefined
        endcase
    end
    
endmodule