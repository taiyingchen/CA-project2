module MEM_WB
(
	RegWrite_i,
	MemtoReg_i,
	RegWrite_o,
	MemtoReg_o,
	dataMem_data_i,
	ALU_result_i,
	dataMem_data_o,
	ALU_result_o,
	RDaddr_i,
	RDaddr_o,
	clk_i,
	rst_i
);

// 1. WB control signal
input		RegWrite_i, MemtoReg_i;
output reg	RegWrite_o, MemtoReg_o;
// 2. data content
input		[31:0]	dataMem_data_i, ALU_result_i;
output reg	[31:0]	dataMem_data_o, ALU_result_o;
input		[4:0]	RDaddr_i;
output reg	[4:0]	RDaddr_o;
// general signal

always @(posedge clk_i or posedge rst_i)
begin
	if (rst_i == 1'b1)
	begin
		RegWrite_o <= 1'b0;
		MemtoReg_o <= 1'b0;
		dataMem_data_o <= 32'b0;
		ALU_result_o <= 32'b0;
		RDaddr_o <= 5'b0;
	end
	else begin
		RegWrite_o <= RegWrite_i;
		MemtoReg_o <= MemtoReg_i;
		dataMem_data_o <= dataMem_data_i;
		ALU_result_o <= ALU_result_i;
		RDaddr_o <= RDaddr_i;
	end
end
	
endmodule