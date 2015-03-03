----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:40:28 12/27/2008 
-- Design Name: 
-- Module Name:    Platine95 - jetzt24Bit 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TopSpartan3fuerGitHub is
  Port ( --hierzu Platine95S3.ucf--
-- ==== Clock inputs (CLK) ====
CLK: in  STD_LOGIC;
-- ==== RS-232 Serial Ports  (RS232) ====
RXD: in  STD_LOGIC;
TXD: out STD_LOGIC;
-- SRAM
    AL:  out STD_LOGIC_VECTOR (17 downto 0):="000000000000000000";      -- Adressbus SRAM
    DL:  inout STD_LOGIC_VECTOR (31 downto 0):=x"00000000";    -- Datenbus SRAM
    WE,OE,CE1,UB1,LB1,CE2,UB2,LB2: out STD_LOGIC; -- Steuersignale SRAM (low-aktiv)
-- ==== PS2
PS2_CLK:  inout STD_LOGIC;
PS2_DATA: inout STD_LOGIC;

-- LED's+Buttons
    btn: in  STD_LOGIC_VECTOR (3 downto 0);  -- 4 Tasten
    swt: in  STD_LOGIC_VECTOR (7 downto 0);  -- 8 Schalter
    led: out STD_LOGIC_VECTOR (7 downto 0);  -- 8 Leuchtdioden
    an:  out STD_LOGIC_VECTOR (3 downto 0);  -- 4 Siebensegmentanzeigen
    ssg: out STD_LOGIC_VECTOR (7 downto 0);  -- zu je 7 Segmente (low-aktiv)
-- Port B
    MB1: inout STD_LOGIC_VECTOR (13 downto 0):="ZZZZZZZZZZ1Z1Z"; --"1ZZ1111Z1Z1Z1Z"   -- Port B, alle MB1-Anschlüsse
 

-- neu RPI:
A2_TXD: inout STD_LOGIC;
A2_RXD: in STD_LOGIC;

-- neu SPIS:
SPI_CLK: in STD_LOGIC;
SPI_MOSI: in STD_LOGIC;
SPI_MISO: out STD_LOGIC;
SPI_SCSN: in STD_LOGIC

);
end TopSpartan3fuerGitHub;

architecture Step_1_bis_5 of TopSpartan3fuerGitHub is

  component top
  port (
 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0);

    -- nur zur Simulation und Fehlersuche:
    A_SIM: out STD_LOGIC_VECTOR (15 downto 0)

    );
end component;



signal CLK_I: STD_LOGIC;
signal TAKTZAEHLER: STD_LOGIC_VECTOR (55 downto 0):="00000000000000000000000000000000000000000000000000000000";

begin

DUT: top
  port map (
    CLK      => CLK_I,
    LEDS     => open, --led,
	 
	 A_SIM(7 downto 0)    => led, 
	 A_SIM(15 downto 8)   => open
    );

process(CLK) begin if CLK'event and CLK='1' then
  TAKTZAEHLER<=TAKTZAEHLER+1;
  CLK_I<=TAKTZAEHLER(24);
  end if; end process;

TXD <= '1';

    AL <= "000000000000000000";
    DL <= x"00000000";
    WE <= '0';
	 OE <= '0';
	 CE1 <= '0';
	 UB1 <= '0';
	 LB1 <= '0';
	 CE2 <= '0';
	 UB2 <= '0';
	 LB2 <= '0';
PS2_CLK <= '0';
PS2_DATA <= '0';
    an <= "1111";
    ssg <= "11111111";
    MB1 <= "ZZZZZZZZZZ1Z1Z";
A2_TXD <= '0';
SPI_MISO <= '0';

end Step_1_bis_5;

