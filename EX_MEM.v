module EX_MEM
(
	RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i,
	RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o,
	ALU_result_i, RS2data_i,
	ALU_result_o, RS2data_o,
	RDaddr_i,
	RDaddr_o,
	clk_i,
	rst_i
);

// 1. hazard control signal
// 2. WB control signal
input		RegWrite_i, MemtoReg_i;
output reg	RegWrite_o, MemtoReg_o;
// 3. MEM control signal
input		MemRead_i, MemWrite_i;
output reg	MemRead_o, MemWrite_o;
// 4. data content
input		[31:0]	ALU_result_i, RS2data_i;
output reg	[31:0]	ALU_result_o, RS2data_o;
input		[4:0]	RDaddr_i;
output reg	[4:0]	RDaddr_o;
// general signal
input	clk_i, rst_i;

always @(posedge clk_i or posedge rst_i)
begin
	if (rst_i == 1'b1)
	begin
		RegWrite_o <= 1'b0;
		MemtoReg_o <= 1'b0;
		MemRead_o <= 1'b0;
		MemWrite_o <= 1'b0;
		ALU_result_o <= 32'b0;
		RS2data_o <= 32'b0;
		RDaddr_o <= 5'b0; 
	end 
	else begin
		RegWrite_o <= RegWrite_i;
		MemtoReg_o <= MemtoReg_i;
		MemRead_o <= MemRead_i;
		MemWrite_o <= MemWrite_i;
		ALU_result_o <= ALU_result_i;
		RS2data_o <= RS2data_i;
		RDaddr_o <= RDaddr_i;
	end
end

endmodule