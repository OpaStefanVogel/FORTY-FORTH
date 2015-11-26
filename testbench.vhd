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

architecture test_Step_12 of testbench is

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
signal XOFF_BIT: STD_LOGIC:='0';
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

read_input: process
        type char_file is file of character;
        file c_file_handle: char_file;
        variable C: character;
        variable char_count: integer := 0;
   begin
     wait for 30000 ns;
     if char_count=0 then  file_open(c_file_handle, "../../../../test_input_file.txt", READ_MODE); end if;
     if not endfile(c_file_handle) and XOFF_BIT='0' then
       read (c_file_handle, C) ;    
       KEY_BYTE <= CONV_STD_LOGIC_VECTOR(character'pos(C),8) ;
       KEY_ABGESCHICKT<=not KEY_ABGESCHICKT;
       char_count := char_count + 1;
       end if;
   end process;

write_output: process -- zusaetzliche Ausgabe von EMIT_BYTE in Datei "test_file.txt"
  type char_file is file of character;
  file c_file_handle: char_file;
  variable D: string(1 to 1):= "V";
  variable char_count: integer := 0;
  begin
    wait until EMIT_ABGESCHICKT'event;
    if char_count=0 then 
      file_open(c_file_handle, "../../../../test_output_file.txt", WRITE_MODE);
      write (output, "----------------------------------------");
      D(1):=character'val(10);
      write (output, D);
      write (output, "|  ");
      else
        if EMIT_BYTE=x"13" then XOFF_BIT<='1';
          elsif EMIT_BYTE=x"11" then XOFF_BIT<='0';
            else
            write (c_file_handle, character'val(CONV_INTEGER(EMIT_BYTE)));
            D(1):=character'val(CONV_INTEGER(EMIT_BYTE));
            write (output, D);
            if EMIT_BYTE=x"0A" then write (output, "|  "); end if;
            end if;
        end if;
    char_count := char_count + 1;  -- Keep track of the number of
  end process;

end test_Step_12;
