library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
entity MainTop is
  Port ( CLK_33MHz 	: in std_logic;
			
			-- Flash Interface
			Flash_A		: inout std_logic_vector(24 downto 0);  --out std_logic_vector(24 downto 0);
			Flash_D		: inout std_logic_vector(15 downto 0);
			Flash_CE_Q	: inout std_logic;
			Flash_OE_Q	: inout std_logic;
			Flash_WE_Q	: inout std_logic;
			Flash_RST_Q	: inout std_logic;
			Flash_BYTE_Q: inout std_logic
			);
end MainTop;

architecture Behavioral of MainTop is

		
	
   component BSCAN_SPARTAN3
   port (CAPTURE : out STD_ULOGIC;
         DRCK1 : out STD_ULOGIC;
         DRCK2 : out STD_ULOGIC;
         RESET : out STD_ULOGIC;
         SEL1 : out STD_ULOGIC;
         SEL2 : out STD_ULOGIC;
         SHIFT : out STD_ULOGIC;
         TDI : out STD_ULOGIC;
         UPDATE : out STD_ULOGIC;
         TDO1 : in STD_ULOGIC;
         TDO2 : in STD_ULOGIC);
        end component;

        signal CAPTURE: STD_ULOGIC;
        signal DRCK1: STD_ULOGIC;
        signal DRCK2: STD_ULOGIC;
        signal RESET: STD_ULOGIC;
        signal SEL1: STD_ULOGIC;
        signal SEL2: STD_ULOGIC;
        signal SHIFT: STD_ULOGIC;
        signal TDI: STD_ULOGIC;
        signal UPDATE: STD_ULOGIC;
        signal TDO1: STD_ULOGIC;
        signal TDO2: STD_ULOGIC;
		  
			signal bscan_shift_register : std_logic_vector( 62-1 downto 0 );
			signal bscan_shift_register_sample : std_logic_vector( 62-1 downto 0 );
			
			signal bscan_extest	:	std_logic := '0';


		
	signal Flash_D_ddr	:	std_logic_vector(16-1 downto 0) := "0000000000000000";
	signal Flash_D_port	:	std_logic_vector(16-1 downto 0);
begin	

 

				
							  
		
   BSCAN_SPARTAN3_inst : BSCAN_SPARTAN3
   port map (
      CAPTURE => CAPTURE, -- CAPTURE output from TAP controller
      DRCK1 => DRCK1,     -- Data register output for USER1 functions
      DRCK2 => DRCK2,     -- Data register output for USER2 functions
      RESET => RESET,     -- Reset output from TAP controller
      SEL1 => SEL1,       -- USER1 active output
      SEL2 => SEL2,       -- USER2 active output
      SHIFT => SHIFT,     -- SHIFT output from TAP controller
      TDI => TDI,         -- TDI output from TAP controller
      UPDATE => UPDATE,   -- UPDATE output from TAP controller
      TDO1 => TDO1,       -- Data input for USER1 function
      TDO2 => TDO2        -- Data input for USER2 function
   );
	


	TDO1 <= bscan_shift_register(0);
	TDO2 <= bscan_shift_register_sample(0);


	process(DRCK1,UPDATE,SEL1)
	begin
		if SEL1='1' then	
					if UPDATE='1' then						
						Flash_A			<= bscan_shift_register(24 downto  0);   
						Flash_D_port	<= bscan_shift_register(40 downto 25); 
						Flash_D_ddr		<= bscan_shift_register(56 downto 41);
						Flash_CE_Q		<= bscan_shift_register(57);
						Flash_OE_Q		<= bscan_shift_register(58);
						Flash_WE_Q		<= bscan_shift_register(59);
						Flash_RST_Q		<= bscan_shift_register(60);
						Flash_BYTE_Q	<= bscan_shift_register(61);						
					elsif CAPTURE='1' then					
						bscan_shift_register(24 downto  0)	<= Flash_A;
						bscan_shift_register(40 downto 25)	<= Flash_D; 
						bscan_shift_register(56 downto 41)	<= Flash_D_ddr; 
						bscan_shift_register(57) <= Flash_CE_Q;
						bscan_shift_register(58) <= Flash_OE_Q;
						bscan_shift_register(59) <= Flash_WE_Q;
						bscan_shift_register(60) <= Flash_RST_Q;
						bscan_shift_register(61) <= Flash_BYTE_Q;	
					elsif rising_edge(DRCK1) then
						bscan_shift_register <= TDI & bscan_shift_register(62-1 downto 1);
					end if;
		 end if;
	end process;
	
	process(DRCK2,UPDATE,SEL2)
	begin
		if SEL2='1' then
					if UPDATE='1' then						
							-- gibts hier nicht!
					elsif CAPTURE='1' then
						bscan_shift_register_sample(24 downto  0)	<= Flash_A;
						bscan_shift_register_sample(40 downto 25)	<= Flash_D; 
						bscan_shift_register_sample(56 downto 41)	<= Flash_D_ddr; 
						bscan_shift_register_sample(57) <= Flash_CE_Q;
						bscan_shift_register_sample(58) <= Flash_OE_Q;
						bscan_shift_register_sample(59) <= Flash_WE_Q;
						bscan_shift_register_sample(60) <= Flash_RST_Q;
						bscan_shift_register_sample(61) <= Flash_BYTE_Q;
					elsif rising_edge(DRCK2) then
						bscan_shift_register_sample <= bscan_shift_register_sample(0) & 
																 bscan_shift_register_sample(62-1 downto 1);
					end if;
		 end if;
	end process;
	

	Flash_D( 0) <= Flash_D_port( 0)	when Flash_D_ddr( 0) = '1' else 'Z';
	Flash_D( 1) <= Flash_D_port( 1)	when Flash_D_ddr( 1) = '1' else 'Z';
	Flash_D( 2) <= Flash_D_port( 2)	when Flash_D_ddr( 2) = '1' else 'Z';
	Flash_D( 3) <= Flash_D_port( 3)	when Flash_D_ddr( 3) = '1' else 'Z';
	Flash_D( 4) <= Flash_D_port( 4)	when Flash_D_ddr( 4) = '1' else 'Z';
	Flash_D( 5) <= Flash_D_port( 5)	when Flash_D_ddr( 5) = '1' else 'Z';
	Flash_D( 6) <= Flash_D_port( 6)	when Flash_D_ddr( 6) = '1' else 'Z';
	Flash_D( 7) <= Flash_D_port( 7)	when Flash_D_ddr( 7) = '1' else 'Z';
	Flash_D( 8) <= Flash_D_port( 8)	when Flash_D_ddr( 8) = '1' else 'Z';
	Flash_D( 9) <= Flash_D_port( 9)	when Flash_D_ddr( 9) = '1' else 'Z';
	Flash_D(10) <= Flash_D_port(10)	when Flash_D_ddr(10) = '1' else 'Z';
	Flash_D(11) <= Flash_D_port(11)	when Flash_D_ddr(11) = '1' else 'Z';
	Flash_D(12) <= Flash_D_port(12)	when Flash_D_ddr(12) = '1' else 'Z';
	Flash_D(13) <= Flash_D_port(13)	when Flash_D_ddr(13) = '1' else 'Z';
	Flash_D(14) <= Flash_D_port(14)	when Flash_D_ddr(14) = '1' else 'Z';
	Flash_D(15) <= Flash_D_port(15)	when Flash_D_ddr(15) = '1' else 'Z';

  
End Behavioral;
