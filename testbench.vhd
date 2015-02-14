library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity testbench is

end testbench;

-------------------------------------------------------------------------------

architecture test_Step_1 of testbench is

component top
  Port ( 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0)
    );
  end component;      

signal CLK  : STD_LOGIC:='0';
signal LEDS : STD_LOGIC_VECTOR (7 downto 0);

begin

  -- component instantiation
  DUT: top
    port map (
      CLK      => CLK,
      LEDS      => LEDS
      );

  -- clock generation
  CLK <= not CLK after 10 ns;

end test_Step_1;


