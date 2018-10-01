-- 8-bit CPU datapath
-- Nicholas DiGiovacchino
library ieee;
use ieee.std_logic_1164.all;
library lpm;
use lpm.lpm_components.all;

entity lab_7 is
port (clk, pause, clear: in std_logic;
		seg_a1, seg_a2, seg_pc1, seg_pc2, seg_ir, seg_test2, seg_test1: out std_logic_vector(0 to 6);

end lab_7;
architecture structural of lab_7 is

component exp7_useq is
  generic (uROM_width: integer := 28;
           uROM_file: string := "uromcontent.mif");
  port (opcode: in std_logic_vector(7 downto 0);
		  uop: out std_logic_vector(1 to (uROM_width-9));
        enable, clear: in std_logic;
        clock: in std_logic);
end component;

component decoder is
port (c: in std_logic_vector(3 downto 0);
		segments: out std_logic_vector(0 to 6));
end component;

signal pc_out, pc_mux_out, dr_out, dr_mux_out, ir_out, a_out, ram_out, mar_out, mar_mux_out, amux_out, r_out, alu_out, alumux_out: std_logic_vector(7 downto 0);
signal pc_inc, pc_clr, pc_load, dr_load, mar_load, ir_load, r_load, a_load, aluop, z_load, upc_enable, cout: std_logic;
signal pc_sel, dr_sel, pcload_mux_out, mar_sel, z_sel, zmux_out, z_out, ram_we: std_logic_vector (0 to 0);
signal pc_mux_data, dr_mux_data, mar_mux_data: std_logic_2d (1 downto 0, 7 downto 0);
signal pcload_mux_data, zmux_data: std_logic_2d (1 downto 0, 0 downto 0);
signal amux_sel, alumux_sel: std_logic_vector(1 downto 0);
signal amux_data, alumux_data: std_logic_2d (2 downto 0, 7 downto 0);
signal uop: std_logic_vector(1 to 19);


begin
	Delay: lpm_counter
		generic map (lpm_width=>25)
		port map(clock=>clk, cout=>cout);

	two_time: for i in 0 to 7 generate
		pc_mux_data(0, i) <= ram_out(i);
		pc_mux_data(1, i) <= dr_out(i);
		
		dr_mux_data(0, i) <= ram_out(i);
		dr_mux_data(1, i) <= a_out(i);
		
		mar_mux_data(0, i) <= pc_out(i);
		mar_mux_data(1, i) <= dr_out(i);
		
		amux_data(0, i) <= ram_out(i);
		amux_data(1, i) <= alu_out(i);
		amux_data(2, i) <= dr_out(i);
		
		alumux_data(0, i) <= r_out(i);
		alumux_data(1, i) <= dr_out(i);
		alumux_data(2, i) <= ram_out(i);
	end generate;
	
	pcload_mux_data(0, 0) <= pc_load;
	pcload_mux_data(1, 0) <= z_out(0);
	zmux_data(0,0) <= (a_out(0) or a_out(1) or a_out(2) or a_out(3) or a_out(4) or a_out(5) or a_out(6) or a_out(7));
	zmux_data(1,0) <= (not(a_out(0) or a_out(1) or a_out(2) or a_out(3) or a_out(4) or a_out(5) or a_out(6) or a_out(7)));

	upc_enable <= cout and not pause;
	mar_load <= uop(1) and upc_enable;
	ir_load <= uop(2) and upc_enable;
	dr_load <= uop(3) and upc_enable;
	pc_inc <= uop(4) and upc_enable;
	pc_clr <= uop(5) and upc_enable;
	pc_load <= uop(6) and upc_enable;
	pc_sel(0) <= uop(7) and upc_enable;
	z_load <= uop(8) and upc_enable;
	mar_sel(0) <= uop(9) and upc_enable;
	z_sel(0) <= uop(10) and upc_enable;
	ram_we(0) <= uop(11) and upc_enable;
	aluop <= uop(12) and upc_enable;
	a_load <= uop(13) and upc_enable;
	r_load <= uop(14) and upc_enable;
	alumux_sel(0) <= uop(15) and upc_enable;
	alumux_sel(1) <= uop(16) and upc_enable;
	amux_sel(0) <= uop(17) and upc_enable;
	amux_sel(1) <= uop(18) and upc_enable;
	dr_sel(0) <= uop(19) and upc_enable;
	
	
	USEQ: exp7_useq
		port map (clock=>clk, opcode=>ir_out, enable=>upc_enable, clear=>clear, uop=>uop);

	PC: lpm_counter
		generic map (lpm_width=>8)
		port map (q=>pc_out, clock=>clk, cnt_en=>pc_inc, sclr=>pc_clr, sload=>pcload_mux_out(0), data(7 downto 0)=>pc_mux_out(7 downto 0) );
	PCMUX: lpm_mux
		generic map (lpm_width=>8, lpm_size=>2, lpm_widths=>1)
		port map (result=>pc_mux_out, data=>pc_mux_data, sel=>pc_sel);
	DR: lpm_ff
		generic map (lpm_width=>8)
		port map (data=>dr_mux_out, q=>dr_out, clock=>clk, enable=>dr_load);  
	DRMUX: lpm_mux
		generic map (lpm_width=>8, lpm_size=>2, lpm_widths=>1)
		port map (result=>dr_mux_out, data=>dr_mux_data, sel=>dr_sel);
	PCLOADMUX: lpm_mux
		generic map (lpm_width=>1, lpm_size=>2, lpm_widths=>1)
		port map (result=>pcload_mux_out, data=>pcload_mux_data, sel=>pc_sel);
	MAR: lpm_ff
		generic map (lpm_width=>8)
		port map (data=>mar_mux_out, q=>mar_out, clock=>clk, enable=>mar_load);  	
	MARMUX: lpm_mux
		generic map (lpm_width=>8, lpm_size=>2, lpm_widths=>1)
		port map (result=>mar_mux_out, data=>mar_mux_data, sel=>mar_sel);	
	IR: lpm_ff
		generic map (lpm_width=>8)
		port map (data=>dr_out, q=>ir_out, clock=>clk, enable=>ir_load);  	
	REGA: lpm_ff
		generic map (lpm_width=>8)
		port map (data=>amux_out, q=>a_out, clock=>clk, enable=>a_load);        
	REGR: lpm_ff
		generic map (lpm_width=>8)
		port map (data=>a_out, q=>r_out, clock=>clk, enable=>r_load);
	AMUX: lpm_mux
		generic map (lpm_width=>8, lpm_size=>3, lpm_widths=>2)
		port map (result=>amux_out, data=>amux_data, sel=>amux_sel);		
	ALU: lpm_add_sub
		generic map (lpm_width=>8)
		port map (dataa=>a_out, datab=>alumux_out, result=>alu_out, add_sub=>aluop);
	ALUMUX: lpm_mux
		generic map (lpm_width=>8, lpm_size=>3, lpm_widths=>2)
		port map (result=>alumux_out, data=>alumux_data, sel=>alumux_sel);
	ZMUX: lpm_mux
		generic map (lpm_width=>1, lpm_size=>2, lpm_widths=>1)
		port map (result=>zmux_out, data=>zmux_data, sel=>z_sel);	
	ZFF: lpm_ff
		generic map (lpm_width=>1)
		port map (data=>zmux_out, q=>z_out, clock=>clk, enable=>z_load);
	RAM: lpm_ram_dq
		generic map (lpm_widthad=>8, lpm_width=>8, lpm_file=>"exp7_ram_1_5.mif")
		port map (data=>dr_out, address=>mar_out, q=>ram_out, we=>ram_we(0));
		
	displayA1: decoder port map(c=>a_out(3 downto 0), segments=>seg_a1);
	displayA2: decoder port map(c=>a_out(7 downto 4), segments=>seg_a2);
	displayPC1: decoder port map(c=>pc_out(3 downto 0), segments=>seg_pc1);
	displayPC2: decoder port map(c=>pc_out(7 downto 4), segments=>seg_pc2);
	displaytest1: decoder port map(c=>ram_out(3 downto 0), segments=>seg_test1);
	displaytest2: decoder port map(c=>ram_out(7 downto 4), segments=>seg_test2);
end structural;