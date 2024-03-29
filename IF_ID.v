module IF_ID
(
	PC_i, instr_i,
	PC_o, instr_o,
	// Control signal
	IF_ID_Write_i,
	IF_Flush_i,
	stall_i,
	clk_i,
	rst_i
);

// Data content
input		[31:0]	PC_i, instr_i;
output reg	[31:0]	PC_o, instr_o;

// Hazard control
input	IF_ID_Write_i, IF_Flush_i;

// General control
input	clk_i, rst_i;

// Memory stall
input	stall_i;

always @(posedge clk_i or negedge rst_i)
begin
	if (~rst_i)
	begin
		PC_o <= 32'b0;
		instr_o <= 32'b0;
	end
	else if (IF_Flush_i == 1'b1)
	begin
		PC_o <= 32'b0;
		instr_o <= 32'b0;
	end
	else if (IF_ID_Write_i && ~stall_i)
	begin
		PC_o <= PC_i;
		instr_o <= instr_i;
	end
	else if (stall_i)
	begin
		PC_o <= PC_o;
		instr_o <= instr_o;
	end
end

endmodule
