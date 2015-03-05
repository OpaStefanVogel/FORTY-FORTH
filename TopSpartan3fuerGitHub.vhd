----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:40:28 12/27/2008 
-- Design Name: 
-- Module Name:    Platine95 - jetzt24Bit 
-- Project Name: 
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

-- Target Devices: 
-- Tool versions: 
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

architecture Step_9_und_10 of TopSpartan3fuerGitHub is

  component top
  port (
 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0);

    -- EMIT --
    EMIT_GESENDET: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_EMPFANGEN: in STD_LOGIC;

     -- KEY --
    KEY_GESENDET: in STD_LOGIC;
    KEY_BYTE: in STD_LOGIC_VECTOR (7 downto 0);
    KEY_EMPFANGEN: out STD_LOGIC

    );
end component;



signal CLK_I: STD_LOGIC;
signal TAKTZAEHLER: STD_LOGIC_VECTOR (55 downto 0):="00000000000000000000000000000000000000000000000000000000";

--RXD --
signal CLK_6_MHz,STRG,RxDI: STD_LOGIC;
signal dbInput: STD_LOGIC_VECTOR (7 downto 0);

--TXD --
signal P19SCHREIBBIT1,SCHREIBBIT2_X,SCHREIBBIT1_ZUR_AUSGABE: STD_LOGIC;
signal dbOutput,HIN_ZUR_AUSGABE: STD_LOGIC_VECTOR (7 downto 0);

begin

DUT: top
  port map (
    CLK      => CLK_I,
    LEDS     => led,
	 
    -- EMIT --
    EMIT_GESENDET   => SCHREIBBIT1_ZUR_AUSGABE,
    EMIT_BYTE       => HIN_ZUR_AUSGABE,
    EMIT_EMPFANGEN  => SCHREIBBIT2_X,

     -- KEY --
    KEY_GESENDET  => STRG,
    KEY_BYTE      => dbInput,
    KEY_EMPFANGEN => open


    );

process(CLK) begin if CLK'event and CLK='1' then
  TAKTZAEHLER<=TAKTZAEHLER+1;
  CLK_I<=TAKTZAEHLER(1); --0: 25 MHz, 1: 12,5 MHz, 2: 6,25 MHz...
  CLK_6_MHz<=TAKTZAEHLER(2);
  end if; end process;


process 
variable xcount1: STD_LOGIC_VECTOR (15 downto 0);
variable xcount2: STD_LOGIC_VECTOR (3 downto 0);
variable OutBit: STD_LOGIC_VECTOR (18 downto 9):="1111111111";
variable XOFFOutput: STD_LOGIC;
begin wait until (CLK_6_MHz'event and CLK_6_MHz='1');
  if xcount1<x"01B2" then xcount1:=xcount1+8; else --D9+D9=1B2
    -- ganz neu 01B2 bei 112500, 1458H bei 9600, 14585H bei 600
	 -- endlich mal merken, 1B2 entsteht aus 50000000/115200.
    xcount1:=x"0000";
    if xcount2<x"A" then 
      TxD<=OutBit(9);
      OutBit:='0'&OutBit(18 downto 10);
      xcount2:=xcount2+1;
      elsif xcount2=x"A" then
        TxD<='1'; --Stop-Bit
        if P19SCHREIBBIT1/=SCHREIBBIT2_X then
          OutBit:="1"&dbOutput&'0';
          SCHREIBBIT2_X<=P19SCHREIBBIT1;
          else OutBit:="1111111111"; 
            end if;
        xcount2:=xcount2+1;
        else xcount2:=x"0";
        end if;
    end if;
  end process;

process
begin wait until (CLK_I'event and CLK_I='0');
  dbOutput<=HIN_ZUR_AUSGABE;
  P19SCHREIBBIT1<=SCHREIBBIT1_ZUR_AUSGABE;
--  XOBIT_R<=XOBIT;
  end process;

process
variable scount: STD_LOGIC_VECTOR (31 downto 0):=x"00000000";
variable dbInput_L: STD_LOGIC_VECTOR (7 downto 0);
begin wait until (CLK_6_MHz'event and CLK_6_MHz='1');
  if (RxDI='0' and scount=x"00000000") then scount:=x"00000008"; else
    if scount=x"00001000" then scount:=x"00000000";
          dbInput<=dbInput_L;
--          STRG<=not STRG_MERK_RUHEND; 
          STRG<=not STRG; 
      else 
--        if scount>0 then scount:=scount+2; -- D0000, D000 statt 1100
        if scount/=0 then scount:=scount+8;
          end if; end if; end if;
-- 115200: 43x-28x=1B2, 1B2 von TXD
  if scount(11 downto 4)=x"28" then dbInput_L(0):=RxDI;
  elsif scount(11 downto 4)=x"43" then dbInput_L(1):=RxDI;
  elsif scount(11 downto 4)=x"5E" then dbInput_L(2):=RxDI;
  elsif scount(11 downto 4)=x"7A" then dbInput_L(3):=RxDI;
  elsif scount(11 downto 4)=x"95" then dbInput_L(4):=RxDI;
  elsif scount(11 downto 4)=x"B0" then dbInput_L(5):=RxDI;
  elsif scount(11 downto 4)=x"CB" then dbInput_L(6):=RxDI;
  elsif scount(11 downto 4)=x"E6" then dbInput_L(7):=RxDI;
    end if; 
  end process;

process
begin wait until (CLK_6_MHz'event and CLK_6_MHz='0');
--  STRG_MERK_RUHEND<=STRG_MERK;
  RXDI<=RXD;
  end process;



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

end Step_9_und_10;
