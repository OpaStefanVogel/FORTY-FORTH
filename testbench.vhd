library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity testbench is

end testbench;

-------------------------------------------------------------------------------

architecture test_Step_11 of testbench is

component top
  Port ( 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0);

    -- EMIT --
    EMIT_ABGESCHICKT: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_ANGEKOMMEN: in STD_LOGIC;
            
    -- KEY --
    KEY_ABGESCHICKT: in STD_LOGIC;
    KEY_BYTE: in STD_LOGIC_VECTOR (7 downto 0);
    KEY_ANGEKOMMEN: out STD_LOGIC;

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
-- KEY --
signal KEY_ABGESCHICKT: STD_LOGIC:='0';
signal KEY_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal KEY_ANGEKOMMEN: STD_LOGIC:='0';

type TEXTTYPE is array(0 to 8*1024) of STD_LOGIC_VECTOR (7 downto 0);
-- Programmspeicher 0000H-1FFFH
signal TEXT: TEXTTYPE:=(
  -- Anfang abwarten
  x"00",x"00",x"00",x"00",
  -- 56 89 * .
  x"35",x"36",x"20",x"38",x"39",x"20",x"2A",x"20",x"2E",x"0A",
  -- 111111111111111 DUP * .
  x"31",x"31",x"31",x"31",x"31",x"31",x"31",x"31",
  x"31",x"31",x"31",x"31",x"31",x"31",x"31",x"20",
  x"44",x"55",x"50",x"20",x"2A",x"20",x"2E",x"0A",
  -- DEZ
  x"44",x"45",x"5A",x"0A",
  -- nochmal 56 89 * .
  x"35",x"36",x"20",x"38",x"39",x"20",x"2A",x"20",x"2E",x"0A",
  -- DEMOMATRIX INVERTIEREN
  x"5B",x"20",x"0A",
  x"5B",x"20",x"31",x"20",x"31",x"20",x"31",x"20",x"31",x"20",x"5D",x"0A",
  x"5B",x"20",x"32",x"20",x"34",x"20",x"38",x"20",x"31",x"36",x"20",x"5D",x"0A",
  x"5B",x"20",x"33",x"20",x"39",x"20",x"32",x"37",x"20",x"38",x"31",x"20",x"5D",x"0A",
  x"5B",x"20",x"34",x"20",x"31",x"36",x"20",x"36",x"34",x"20",x"32",x"35",x"36",x"20",x"5D",x"0A",
  x"5D",x"20",x"0A",
  x"34",x"20",x"49",x"4E",x"56",x"45",x"52",x"54",x"49",x"45",x"52",x"45",x"4E",x"0A",
  x"4F",x"56",x"45",x"52",x"20",x"4F",x"2E",x"0A",
  x"44",x"55",x"50",x"20",x"2E",x"0A",
  others=>x"00");


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

      -- KEY --
      KEY_ABGESCHICKT => KEY_ABGESCHICKT,
      KEY_BYTE => KEY_BYTE,
      KEY_ANGEKOMMEN => KEY_ANGEKOMMEN,

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



  -- simuliert eine Tastatureingabe
  process
  variable I: integer:=0;
  begin
    wait for 30000 ns;
      if TEXT(I)>x"00" then
        KEY_BYTE<=TEXT(I);
        KEY_ABGESCHICKT<=not KEY_ABGESCHICKT;
      end if;
      I:=I+1;
  end process;

end test_Step_11;


