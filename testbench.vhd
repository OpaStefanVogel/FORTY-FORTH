library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library std;
use std.textio.all;

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
    SP_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    A_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    B_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    C_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    D_SIM: out STD_LOGIC_VECTOR (15 downto 0)
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
signal SP_SIM: STD_LOGIC_VECTOR (15 downto 0);
    -- EMIT --
signal EMIT_ABGESCHICKT: STD_LOGIC;
signal EMIT_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal EMIT_ANGEKOMMEN: STD_LOGIC:='0';
-- KEY --
signal KEY_ABGESCHICKT: STD_LOGIC:='0';
signal KEY_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal KEY_ANGEKOMMEN: STD_LOGIC:='0';

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
      SP_SIM => SP_SIM,
      A_SIM => A_SIM,
      B_SIM => B_SIM,
      C_SIM => C_SIM,
      D_SIM => D_SIM  
      );

  -- clock generation
  CLK <= not CLK after 10 ns;
  EMIT_ANGEKOMMEN<=EMIT_ABGESCHICKT after 800 ns; -- simuliert Dauer der seriellen Ausgabe

--  -- simuliert eine Tastatureingabe, jedoch ersetzt durch nächsten process
--  process
--  variable I: integer:=1;
--  variable c: STD_LOGIC_VECTOR ( 7 downto 0 ) ;
--  constant Enter:string(1 to 1) := "" & character'val(10) ;
--  constant DEMO: string(1 to 139) := 
--    "56 89 * ." & Enter &
--    "111111111111111 DUP * . " & Enter & 
--    "DECIMAL" & Enter & 
--    "56 89 * ." & Enter & 
--    "[" & Enter & 
--    "[ 1 1 1 1 ]" & Enter & 
--    "[ 2 4 8 16 ]" & Enter & 
--    "[ 3 9 27 81 ]" & Enter & 
--    "[ 4 16 64 256 ]" & Enter & 
--    "]" & Enter & 
--    "4 INVERTIEREN" & Enter & 
--    "OVER ." & Enter & 
--    "DUP ." & Enter ;

--  begin
--    wait for 30000 ns;
--    if I <= DEMO'length then
--      c := CONV_STD_LOGIC_VECTOR(character'pos ( DEMO ( I ) ),8) ;
--      KEY_BYTE <= c ;
--      KEY_ABGESCHICKT<=not KEY_ABGESCHICKT;
--      end if;
--    I:=I+1;
--  end process;

read_input: process -- ersetzt vorhergehenden Ausgabe-process
        type char_file is file of character;
        file c_file_handle: char_file;
        variable C: character;
        variable char_count: integer := 0;
   begin
     wait for 30000 ns;
     if char_count=0 then  file_open(c_file_handle, "../../../../test_input_file.txt", READ_MODE); end if;
     if not endfile(c_file_handle) then
       read (c_file_handle, C) ;    
       KEY_BYTE <= CONV_STD_LOGIC_VECTOR(character'pos(C),8) ;
       KEY_ABGESCHICKT<=not KEY_ABGESCHICKT;
       char_count := char_count + 1;
       end if;
   end process;

write_output: process -- zusaetzliche Ausgabe von EMIT_BYTE in Datei "test_file.txt"
        type char_file is file of character;
        file c_file_handle: char_file;
        variable C: character := 'V';
        variable char_count: integer := 0;
   begin
     wait until EMIT_ABGESCHICKT'event;
     if char_count=0 then  file_open(c_file_handle, "../../../../test_output_file.txt", WRITE_MODE); end if;
     write (c_file_handle, character'val(CONV_INTEGER(EMIT_BYTE))) ;    
     char_count := char_count + 1;  -- Keep track of the number of
   end process;

end test_Step_11;
