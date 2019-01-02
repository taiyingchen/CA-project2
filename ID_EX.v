module ID_EX
(
	// Data content
	ALUSrc_i, ALUOp_i, RS1data_i, RS2data_i, signExtend_i,
	ALUSrc_o, ALUOp_o, RS1data_o, RS2data_o, signExtend_o,
	// Register content
	RS1addr_i, RS2addr_i, RDaddr_i,
	RS1addr_o, RS2addr_o, RDaddr_o,
	// Function code
	funct3_i, funct7_i,
	funct3_o, funct7_o,
	// Control signal
	ID_Flush_lwstall_i,
	RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i,
	RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o,
	stall_i,
	clk_i,
	rst_i
);

// 1. hazard control signal (sync rising edge)
// if either ID_Flush_lwstall_i or ID_Flush_Branch equals 1,
// then clear all WB, MEM and EX control signal to 0 on rising edge
// do not need to clear addr, data or reg content
input	ID_Flush_lwstall_i;
// 2. WB control signal
input	RegWrite_i, MemtoReg_i;
output reg	RegWrite_o, MemtoReg_o;
// 3. MEM control signal
input	MemRead_i, MemWrite_i;
output reg	MemRead_o, MemWrite_o;
// 4. EX control signal
input	ALUSrc_i;
input	[1:0]	ALUOp_i;
output reg	ALUSrc_o;
output reg	[1:0]	ALUOp_o;
// 5. addr content
// 6. data content
input	[31:0]	RS1data_i, RS2data_i, signExtend_i;
output reg	[31:0]	RS1data_o, RS2data_o, signExtend_o;
// 7. reg content
input	[4:0]	RS1addr_i, RS2addr_i, RDaddr_i;
output reg	[4:0]	RS1addr_o, RS2addr_o, RDaddr_o;
// general signal
input	[2:0]	funct3_i;
input	[6:0]	funct7_i;
output reg	[2:0]	funct3_o;
output reg	[6:0]	funct7_o;
input	clk_i, rst_i;

// Memory stall
input	stall_i;

always @(posedge clk_i or posedge rst_i)
begin
	if (rst_i == 1'b1)
	begin
		RegWrite_o = 1'b0;
		MemtoReg_o = 1'b0;
		MemRead_o = 1'b0;
		MemWrite_o = 1'b0;
		ALUSrc_o = 1'b0;
		ALUOp_o = 2'b0;
		RS1data_o = 32'b0;
		RS2data_o = 32'b0;
		signExtend_o = 32'b0;
		RS1addr_o = 5'b0;
		RS2addr_o = 5'b0;
		RDaddr_o = 5'b0;
		funct3_o = 3'b0;
		funct7_o = 7'b0;			
	end
	else if (ID_Flush_lwstall_i == 1'b1)
	begin
		RegWrite_o = 1'b0;
		MemtoReg_o = 1'b0;
		MemRead_o = 1'b0;
		MemWrite_o = 1'b0;
		ALUSrc_o = 1'b0;
		ALUOp_o = 2'b0;
		funct3_o = 3'b0;
		funct7_o = 7'b0;
	end
	else if (stall_i)
	begin
		RegWrite_o = RegWrite_o;
		MemtoReg_o = MemtoReg_o;
		MemRead_o = MemRead_o;
		MemWrite_o = MemWrite_o;
		ALUSrc_o = ALUSrc_o;
		ALUOp_o = ALUOp_o;
		RS1data_o = RS1data_o;
		RS2data_o = RS2data_o;
		signExtend_o = signExtend_o;
		RS1addr_o = RS1addr_o;
		RS2addr_o = RS2addr_o;
		RDaddr_o = RDaddr_o;
		funct3_o = funct3_o;
		funct7_o = funct7_o;
	end
	else begin
		RegWrite_o = RegWrite_i;
		MemtoReg_o = MemtoReg_i;
		MemRead_o = MemRead_i;
		MemWrite_o = MemWrite_i;
		ALUSrc_o = ALUSrc_i;
		ALUOp_o = ALUOp_i;
		RS1data_o = RS1data_i;
		RS2data_o = RS2data_i;
		signExtend_o = signExtend_i;
		RS1addr_o = RS1addr_i;
		RS2addr_o = RS2addr_i;
		RDaddr_o = RDaddr_i;
		funct3_o = funct3_i;
		funct7_o = funct7_i;
	end	
end	
	
endmodule