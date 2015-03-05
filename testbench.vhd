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
    EMIT_GESENDET: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_EMPFANGEN: in STD_LOGIC;
            
    -- KEY --
    KEY_GESENDET: in STD_LOGIC;
    KEY_BYTE: in STD_LOGIC_VECTOR (7 downto 0);
    KEY_EMPFANGEN: out STD_LOGIC;

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
signal EMIT_GESENDET: STD_LOGIC;
signal EMIT_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal EMIT_EMPFANGEN: STD_LOGIC:='0';
-- KEY --
signal KEY_GESENDET: STD_LOGIC:='0';
signal KEY_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal KEY_EMPFANGEN: STD_LOGIC:='0';

begin

  -- component instantiation
  DUT: top
    port map (
      CLK      => CLK,
      LEDS     => LEDS,

      -- EMIT --
      EMIT_GESENDET => EMIT_GESENDET,
      EMIT_BYTE => EMIT_BYTE,
      EMIT_EMPFANGEN => EMIT_EMPFANGEN,

      -- KEY --
      KEY_GESENDET => KEY_GESENDET,
      KEY_BYTE => KEY_BYTE,
      KEY_EMPFANGEN => KEY_EMPFANGEN,

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
  EMIT_EMPFANGEN<=EMIT_GESENDET after 800 ns;



  -- simuliert eine Tastatureingabe
  process begin
    wait for 100000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"35";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"36";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"20";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"38";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"39";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"20";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"2A";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"20";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"2E";
    wait for 30000 ns;
    KEY_GESENDET<=not KEY_GESENDET;
    KEY_BYTE<=x"0A";
    wait for 1000 ms;
  end process;

end test_Step_9;


