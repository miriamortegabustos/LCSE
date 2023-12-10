LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;

ENTITY ALU IS 
PORT ( 
	Reset: 	 	in std_logic; -- asynnchronous, active low 
	Clk: 	 	in std_logic; -- Sys clock, 20MHz, rising_edge 
	Alu_op:  	in std_logic_vector(5 downto 0); -- u-instructions from CPU
	
	Databus: 	inout std_logic_vector(7 downto 0); -- System Databus
	
	Index_Reg: 	out std_logic_vector(7 downto 0); -- Index register 
	FlagZ: 		out std_logic; -- Zero flag 
	FlagC: 		out std_logic; -- Carry flag 
	FlagN: 		out std_logic; -- Nibble carry bit 
	FlagE: 		out std_logic); -- Error flag 
END ALU; 


ARCHITECTURE behavior OF ALU IS
--SYSTEM
SIGNAL acc_reg:          	 										std_logic_vector(7 downto 0);
SIGNAL reg_a_in, reg_a_out:  										std_logic_vector(7 downto 0);
SIGNAL reg_b_in, reg_b_out:  										std_logic_vector(7 downto 0);

--ADD
SIGNAL alu_add_out:     	 										std_logic_vector(8 downto 0); --9 BITS
SIGNAL reg_add_a, reg_add_b:										std_logic_vector(8 downto 0); --9 BITS
SIGNAL alu_add_nibb:     	 										std_logic_vector(4 downto 0); --5 BITS
SIGNAL reg_add_a_nibb, reg_add_b_nibb:								std_logic_vector(4 downto 0); --5 BITS
SIGNAL flag_Z_add_in,flag_C_add_in,flag_N_add_in,flag_E_add_in: 	std_logic;

--SUB
SIGNAL alu_sub_out:     	 										std_logic_vector(8 downto 0); --9 BITS
SIGNAL reg_sub_a, reg_sub_b:										std_logic_vector(8 downto 0); --9 BITS
SIGNAL alu_sub_nibb:     	 										std_logic_vector(4 downto 0); --5 BITS
SIGNAL reg_sub_a_nibb, reg_sub_b_nibb:								std_logic_vector(4 downto 0); --5 BITS
SIGNAL flag_Z_sub_in,flag_C_sub_in,flag_N_sub_in,flag_E_sub_in: 	std_logic;
 
--SHIFTL - GIRA HACIA LA IZQUIERDA EL CONTENIDO DEL ACUMULADOR, INTRODUCIENDO UN CERO
SIGNAL acc_shiftl:													std_logic_vector(7 downto 0); 
--SHIFTR - GIRA HACIA LA IZQUIERDA EL CONTENIDO DEL ACUMULADOR, INTRODUCIENDO UN CERO 
SIGNAL acc_shiftr:													std_logic_vector(7 downto 0); 

--AND	
SIGNAL alu_and_out:													std_logic_vector(7 downto 0);
SIGNAL flag_Z_and_in,flag_C_and_in,flag_N_and_in,flag_E_and_in: 	std_logic;

--OR
SIGNAL alu_or_out:													std_logic_vector(7 downto 0);
SIGNAL flag_Z_or_in,flag_C_or_in,flag_N_or_in,flag_E_or_in: 		std_logic;

--XOR
SIGNAL alu_xor_out:													std_logic_vector(7 downto 0);
SIGNAL flag_Z_xor_in,flag_C_xor_in,flag_N_xor_in,flag_E_xor_in: 	std_logic;

--CMPE 
SIGNAL alu_cmpe_out:												std_logic_vector(7 downto 0);
SIGNAL flag_Z_cmpe_in,flag_C_cmpe_in,flag_N_cmpe_in,flag_E_cmpe_in: std_logic;

--CMPL
--SIGNAL alu_cmpl_out:												std_logic_vector(7 downto 0);
SIGNAL flag_Z_cmpl_in,flag_C_cmpl_in,flag_N_cmpl_in,flag_E_cmpl_in: std_logic;

--CMPG
--SIGNAL alu_cmpg_out:												std_logic_vector(7 downto 0);
SIGNAL flag_Z_cmpg_in,flag_C_cmpg_in,flag_N_cmpg_in,flag_E_cmpg_in: std_logic;

--ASCII2BIN
SIGNAL alu_ascii2bin_out:											std_logic_vector(7 downto 0);
SIGNAL flag_Z_ascii2bin_in,flag_C_ascii2bin_in,
flag_N_ascii2bin_in,flag_E_ascii2bin_in: 							std_logic;

--BIN2ASCII
SIGNAL alu_bin2ascii_out:											std_logic_vector(7 downto 0);
SIGNAL flag_Z_bin2ascii_in,flag_C_bin2ascii_in,
flag_N_bin2ascii_in,flag_E_bin2ascii_in: 							std_logic;

-- MVACC2A Y MVACC2B 
SIGNAL bus_interno_acc2ab: 											std_logic_vector(7 downto 0);				

-- MVACC2ID
SIGNAL bus_interno_acc2id: 											std_logic_vector(7 downto 0);		

-- LDA 	CONSTANT->A
-- LDA	MEM->A
-- LDA	INDXD_MEM->A

-- LDB	CONSTANT->B
-- LDB	MEM->B
-- LDB	INDXD_MEM->B

-- LDID	CONSTANT->INDX
SIGNAL index_databus:												std_logic_vector(7 downto 0);

-- LDID	MEM->INDX
-- LDID	INDXD_MEM->INDX

-- LDACC CONSTANT->ACC
SIGNAL acc_databus:													std_logic_vector(7 downto 0);

-- LDACC MEM->ACC
-- LDACC INDXD_MEM->ACC

-- OEACC ACC -> MEM o INDXD_MEM

BEGIN
	
	PROCESS(reg_a_out,reg_b_out)		--PROCESS PARA COMPARADOR, ASCII2BIN Y BIN2ASCII
	BEGIN
	
		-- CMPL
		if(signed(reg_a_out) < signed(reg_b_out)) then
			flag_Z_cmpl_in <= '1';
		else
			flag_Z_cmpl_in <= '0';
		end if;
		
		-- CMPG
		if(signed(reg_a_out) > signed(reg_b_out)) then
			flag_Z_cmpg_in <= '1';
		else
			flag_Z_cmpg_in <= '0';
		end if;
		
		-- ASCII2BIN
		if(reg_a_out(7 downto 4) /= "0011")then
			alu_ascii2bin_out <= "11111111";
		else
			if(reg_a_out(3 downto 0) <= "1001" )then
				alu_ascii2bin_out <= "0000" & reg_a_out(3 downto 0);
			else
				alu_ascii2bin_out <= "11111111";
			end if;
		end if;
		
		-- BIN2ASCII
		if(reg_a_out > "00001000") then
			alu_bin2ascii_out <= "11111111";
		else
			alu_bin2ascii_out <= "0011" & reg_a_out(3 downto 0);
		end if;
		
	END PROCESS;
	

	--ADD
	reg_add_a <= '0'& reg_a_out;	
	reg_add_b <= '0'& reg_b_out;	
	alu_add_out <= std_logic_vector(unsigned(reg_add_a) + unsigned(reg_add_b));
	
	reg_add_a_nibb <= '0'& reg_a_out(3 downto 0);
	reg_add_b_nibb <= '0'& reg_b_out(3 downto 0);
	alu_add_nibb <= std_logic_vector(unsigned(reg_add_a_nibb) + unsigned(reg_add_b_nibb));
	
	flag_C_add_in <= alu_add_out(8);
	flag_Z_add_in <= not( (alu_add_out(8)) or (alu_add_out(7)) or (alu_add_out(6)) or (alu_add_out(5)) or (alu_add_out(4)) or (alu_add_out(3)) or (alu_add_out(2)) or (alu_add_out(1)) or (alu_add_out(0)) );
	flag_N_add_in <= alu_add_nibb(4);
	flag_E_add_in <= '0';
	
	--SUB
	reg_sub_a <= '0'& reg_a_out; 	
	reg_sub_b <= '0'& std_logic_vector((unsigned(not(reg_b_out)))+1);	
	alu_sub_out <= std_logic_vector(unsigned(reg_sub_a) + unsigned(reg_sub_b));

	reg_sub_a_nibb <= '0'& reg_a_out(3 downto 0);
	reg_sub_b_nibb <= '0'& std_logic_vector((unsigned(not(reg_b_out(3 downto 0))))+1);
	alu_sub_nibb <= std_logic_vector(unsigned(reg_sub_a_nibb) + unsigned(reg_sub_b_nibb));
	
	flag_C_sub_in <= alu_sub_out(8);
	flag_Z_sub_in <= not( (alu_sub_out(8)) or (alu_sub_out(7)) or (alu_sub_out(6)) or (alu_sub_out(5)) or (alu_sub_out(4)) or (alu_sub_out(3)) or (alu_sub_out(2)) or (alu_sub_out(1)) or (alu_sub_out(0)) );	
	flag_N_sub_in <= alu_sub_nibb(4);
	flag_E_sub_in <= '0';
	
	--SHIFTL - GIRA HACIA LA IZQUIERDA EL CONTENIDO DEL ACUMULADOR, INTRODUCIENDO UN CERO
	acc_shiftl <= acc_reg(6 downto 0) & '0';
	--SHIFTR - GIRA HACIA LA IZQUIERDA EL CONTENIDO DEL ACUMULADOR, INTRODUCIENDO UN CERO 
	acc_shiftr <= '0' & acc_reg(7 downto 1) ;
	
	--AND
	alu_and_out <= reg_a_out and reg_b_out;
	flag_Z_and_in <= not( (alu_and_out(7)) or (alu_and_out(6)) or (alu_and_out(5)) or (alu_and_out(4)) or (alu_and_out(3)) or (alu_and_out(2)) or (alu_and_out(1)) or (alu_and_out(0)) );	
	flag_N_and_in <= '0';
	flag_C_and_in <= '0';
	flag_E_and_in <= '0';
	
	--OR
	alu_or_out <= reg_a_out or reg_b_out;
	flag_Z_or_in <= not( (alu_or_out(7)) or (alu_or_out(6)) or (alu_or_out(5)) or (alu_or_out(4)) or (alu_or_out(3)) or (alu_or_out(2)) or (alu_or_out(1)) or (alu_or_out(0)) );	
	flag_N_or_in <= '0';
	flag_C_or_in <= '0';
	flag_E_or_in <= '0';
	
	--XOR
	alu_xor_out <= reg_a_out xor reg_b_out;
	flag_Z_xor_in <= not( (alu_xor_out(7)) or (alu_xor_out(6)) or (alu_xor_out(5)) or (alu_xor_out(4)) or (alu_xor_out(3)) or (alu_xor_out(2)) or (alu_xor_out(1)) or (alu_xor_out(0)) );	
	flag_N_xor_in <= '0';
	flag_C_xor_in <= '0';
	flag_E_xor_in <= '0';
	
	--CMPE
	alu_cmpe_out <= reg_a_out xor reg_b_out;
	flag_Z_cmpe_in <= not( (alu_cmpe_out(7)) or (alu_cmpe_out(6)) or (alu_cmpe_out(5)) or (alu_cmpe_out(4)) or (alu_cmpe_out(3)) or (alu_cmpe_out(2)) or (alu_cmpe_out(1)) or (alu_cmpe_out(0)) );
	flag_N_cmpe_in <= '0';
	flag_C_cmpe_in <= '0';
	flag_E_cmpe_in <= '0';
	
	--CMPL
	flag_N_cmpl_in <= '0';
	flag_C_cmpl_in <= '0';
	flag_E_cmpl_in <= '0';
	
	--CMPG
	flag_N_cmpg_in <= '0';
	flag_C_cmpg_in <= '0';
	flag_E_cmpg_in <= '0';
	
	--ASCII2BIN
	flag_E_ascii2bin_in <= alu_ascii2bin_out(7);
	flag_N_ascii2bin_in <= '0';
	flag_C_ascii2bin_in <= '0';
	flag_Z_ascii2bin_in <= '0';
	
	--BIN2ASCII
	flag_E_bin2ascii_in <= alu_bin2ascii_out(7);
	flag_N_bin2ascii_in <= '0';
	flag_C_bin2ascii_in <= '0';
	flag_Z_bin2ascii_in <= '0';
	
	--MVACC2A Y MVACC2B 
	bus_interno_acc2ab <= acc_reg;
	
	--MVACC2ID
	bus_interno_acc2id <= acc_reg;
		
	--LDA 	CONSTANT->A
	reg_a_in <= Databus;
	--LDA	MEM->A
	--LDA	INDXD_MEM->A

	--LDB	CONSTANT->B
	reg_b_in <= Databus;
	-- LDB	MEM->B
	-- LDB	INDXD_MEM->B

	--LDID	CONSTANT->INDX
	index_databus <= Databus;
	--LDID	MEM->INDX
	--LDID	INDXD_MEM->INDX

	--LDACC CONSTANT->ACC
	acc_databus <= Databus;
	--LDACC MEM->ACC
	--LDACC INDXD_MEM->ACC

	--OEACC ACC -> MEM o INDXD_MEM
	Databus <= acc_reg when( Alu_op = "100100") else (others => 'Z');
	
    
	PROCESS(Clk, Reset)
	BEGIN
		if Reset = '0' then 
			--Databus    <= "ZZZZZZZZ";
			Index_Reg  <= "00000000";
			FlagZ  <= '0';
			FlagC  <= '0';
			FlagN  <= '0';
			FlagE  <= '0';
			
			--TEST
			reg_a_out <= "10101110"; -- unsigned() - signed()
			reg_b_out <= "01100011"; -- unsigned() - signed()
			
		elsif rising_edge(Clk) then
			CASE Alu_op is
				WHEN "000000" =>	--ADD
					acc_reg <= alu_add_out(7 downto 0);
					FlagZ <= flag_Z_add_in;
					FlagC <= flag_C_add_in;
					FlagN <= flag_N_add_in;
					FlagE <= flag_E_add_in;
					
				WHEN "000001" => -- SUB
					acc_reg <= alu_sub_out(7 downto 0);					
					FlagZ <= flag_Z_sub_in;
					FlagC <= flag_C_sub_in;
					FlagN <= flag_N_sub_in;
					FlagE <= flag_E_sub_in;
			
				WHEN "000010" => --SHIFTL - GIRA HACIA LA IZQUIERDA EL CONTENIDO DEL ACUMULADOR, INTRODUCIENDO UN CERO
					acc_reg <= acc_shiftl; 
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				
				WHEN "000011" => --SHIFTR - GIRA HACIA LA IZQUIERDA EL CONTENIDO DEL ACUMULADOR, INTRODUCIENDO UN CERO 
					acc_reg <= acc_shiftr; 
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				
				WHEN "000100" => -- AND
					acc_reg <= alu_and_out;
					FlagZ <= flag_Z_and_in;
					FlagC <= flag_C_and_in;
					FlagN <= flag_N_and_in;
					FlagE <= flag_E_and_in;
				
				WHEN "000101" => -- OR
					acc_reg <= alu_or_out;
					FlagZ <= flag_Z_or_in;
					FlagC <= flag_C_or_in;
					FlagN <= flag_N_or_in;
					FlagE <= flag_E_or_in;
				
				WHEN "000110" => -- XOR
					acc_reg <= alu_xor_out;
					FlagZ <= flag_Z_or_in;
					FlagC <= flag_C_or_in;
					FlagN <= flag_N_or_in;
					FlagE <= flag_E_or_in;
				
				WHEN "000111" => -- CMPE
					FlagZ <= flag_Z_cmpe_in;
					FlagC <= flag_C_cmpe_in;
					FlagN <= flag_N_cmpe_in;
					FlagE <= flag_E_cmpe_in;
				
				WHEN "001001" => -- CMPL
					FlagZ <= flag_Z_cmpl_in;
					FlagC <= flag_C_cmpl_in;
					FlagN <= flag_N_cmpl_in;
					FlagE <= flag_E_cmpl_in;
				
				WHEN "001000" => -- CMPG
					FlagZ <= flag_Z_cmpg_in;
					FlagC <= flag_C_cmpg_in;
					FlagN <= flag_N_cmpg_in;
					FlagE <= flag_E_cmpg_in;
				
				WHEN "001010" => -- ASCII2BIN
					acc_reg <= alu_ascii2bin_out;
					FlagZ <= flag_Z_ascii2bin_in;
					FlagC <= flag_C_ascii2bin_in;
					FlagN <= flag_N_ascii2bin_in;
					FlagE <= flag_E_ascii2bin_in;
				
				WHEN "001011" => -- BIN2ASCII
					acc_reg <= alu_bin2ascii_out;
					FlagZ <= flag_Z_bin2ascii_in;
					FlagC <= flag_C_bin2ascii_in;
					FlagN <= flag_N_bin2ascii_in;
					FlagE <= flag_E_bin2ascii_in;
				
				WHEN "100001" => -- MVACC2A
					reg_a_out <= bus_interno_acc2ab;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
					
				WHEN "100010" => -- MVACC2B
					reg_b_out <= bus_interno_acc2ab;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
					
				WHEN "100011" => -- MVACC2ID
					Index_Reg <= bus_interno_acc2id;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
					
				WHEN "101001" => -- LDA 	CONSTANT->A
					reg_a_out <= reg_a_in;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "110001" => -- LDA		MEM->A
					reg_a_out <= reg_a_in;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "111001" => -- LDA		INDXD_MEM->A
					reg_a_out <= reg_a_in;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				
				WHEN "101010" => -- LDB		CONSTANT->B
					reg_b_out <= reg_b_in;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "110010" => -- LDB		MEM->B
					reg_b_out <= reg_b_in;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "111010" => -- LDB		INDXD_MEM->B
					reg_b_out <= reg_b_in;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
		
				WHEN "101011" => -- LDID	CONSTANT->INDX
					Index_Reg <= index_databus;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "110011" => -- LDID	MEM->INDX
					Index_Reg <= index_databus;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "111011" => -- LDID	INDXD_MEM->INDX
					Index_Reg <= index_databus;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				
				WHEN "101000" => -- LDACC	CONSTANT->ACC
					acc_reg <= acc_databus;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "110000" => -- LDACC	MEM->ACC
					acc_reg <= acc_databus;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN "111000" => -- LDACC	INDXD_MEM->ACC
					acc_reg <= acc_databus;
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				
				WHEN "100100" => -- OEACC 	ACC -> MEM o INDXD_MEM
					FlagZ <= '0';
					FlagC <= '0';
					FlagN <= '0';
					FlagE <= '0';
				WHEN others =>

				
			END CASE;		
		end if;
	END PROCESS;


END behavior;





