library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity testbench is

end testbench;

-------------------------------------------------------------------------------

architecture test_Step_9 of testbench is

component top
  Port ( 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0);

    -- EMIT --
    EMIT_ABGESCHICKT: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_ANGEKOMMEN: in STD_LOGIC;
            
    -- nur zur Simulation und Fehlersuche:
    PC_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    PD_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    A_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    B_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    C_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    D_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    SP_SIM: out integer
    );
  end component;      

signal CLK  : STD_LOGIC:='0';
signal LEDS : STD_LOGIC_VECTOR (7 downto 0);

signal PC_SIM: STD_LOGIC_VECTOR (15 downto 0);
signal PD_SIM: STD_LOGIC_VECTOR (15 downto 0);
signal A_SIM: STD_LOGIC_VECTOR (15 downto 0);
signal B_SIM: STD_LOGIC_VECTOR (15 downto 0);
signal C_SIM: STD_LOGIC_VECTOR (15 downto 0);
signal D_SIM: STD_LOGIC_VECTOR (15 downto 0);
signal SP_SIM: integer;
    -- EMIT --
signal EMIT_ABGESCHICKT: STD_LOGIC;
signal EMIT_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal EMIT_ANGEKOMMEN: STD_LOGIC:='0';

begin

  -- component instantiation
  DUT: top
    port map (
      CLK      => CLK,
      LEDS     => LEDS,

      -- EMIT --
      EMIT_ABGESCHICKT => EMIT_ABGESCHICKT,
      EMIT_BYTE => EMIT_BYTE,
      EMIT_ANGEKOMMEN => EMIT_ANGEKOMMEN,

      -- nur fuer Simulation
      PC_SIM => PC_SIM,
      PD_SIM => PD_SIM,
      A_SIM => A_SIM,
      B_SIM => B_SIM,
      C_SIM => C_SIM,
      D_SIM => D_SIM,    
      SP_SIM => SP_SIM
      );

  -- clock generation
  CLK <= not CLK after 10 ns;
  EMIT_ANGEKOMMEN<=EMIT_ABGESCHICKT after 800 ns;



end test_Step_9;


