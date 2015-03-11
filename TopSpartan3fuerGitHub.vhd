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
    CLK: in  STD_LOGIC; -- 50 MHz 
    -- ==== RS-232 Serial Ports  (RS232) ====
    RXD: in  STD_LOGIC;
    TXD: out STD_LOGIC:='1';
    -- ==== LED's ====
    led: out STD_LOGIC_VECTOR (7 downto 0)
    );	 
  end TopSpartan3fuerGitHub;

architecture Step_10 of TopSpartan3fuerGitHub is

  component top
  port (
 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0);

    -- EMIT --
    EMIT_ABGESCHICKT: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_ANGEKOMMEN: in STD_LOGIC

    );
end component;



signal CLK_I: STD_LOGIC;
signal TAKTZAEHLER: STD_LOGIC_VECTOR (55 downto 0):="00000000000000000000000000000000000000000000000000000000";

--RXD --
signal CLK_6_MHz,KEY_ABGESCHICKT,RxD_RUHEND: STD_LOGIC;
signal KEY_ABGESCHICKT_LOCAL: STD_LOGIC;
signal KEY_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal scount: STD_LOGIC_VECTOR (31 downto 0):=x"FFFF0000"; --wartet paar ms
signal KEY_BYTE_LOCAL: STD_LOGIC_VECTOR (7 downto 0);

--TXD --
signal EMIT_ABGESCHICKT_RUHEND,EMIT_ANGEKOMMEN,EMIT_ABGESCHICKT: STD_LOGIC;
signal EMIT_ANGEKOMMEN_LOCAL: STD_LOGIC;
signal EMIT_BYTE_RUHEND,EMIT_BYTE: STD_LOGIC_VECTOR (7 downto 0);
signal xcount1: STD_LOGIC_VECTOR (15 downto 0):=x"0000";
signal xcount2: STD_LOGIC_VECTOR (3 downto 0):="0000";
signal OutBit: STD_LOGIC_VECTOR (18 downto 9):="1111111111";

begin

DUT: top
  port map (
    CLK      => CLK_I,
    LEDS     => led,
	 
    -- EMIT --
    EMIT_ABGESCHICKT   => EMIT_ABGESCHICKT,
    EMIT_BYTE       => EMIT_BYTE,
    EMIT_ANGEKOMMEN  => EMIT_ANGEKOMMEN

    );

process(CLK) begin if CLK'event and CLK='1' then
  TAKTZAEHLER<=TAKTZAEHLER+1;
  CLK_I<=TAKTZAEHLER(1); --0: 25 MHz, 1: 12,5 MHz, 2: 6,25 MHz...
  CLK_6_MHz<=TAKTZAEHLER(2);
  end if; end process;


process 
begin wait until (CLK_6_MHz'event and CLK_6_MHz='1');
  if xcount1<x"01B2" then xcount1<=xcount1+8; else 
    -- ganz neu 01B2 bei 112500, 1458H bei 9600, 14585H bei 600
	 -- endlich mal merken, 1B2 entsteht aus 50000000/115200.
    xcount1<=x"0000";
    if xcount2<x"A" then 
      TxD<=OutBit(9);
      OutBit<='0'&OutBit(18 downto 10);
      xcount2<=xcount2+1;
      elsif xcount2=x"A" then
        TxD<='1'; --Stop-Bit
        if EMIT_ABGESCHICKT_RUHEND/=EMIT_ANGEKOMMEN then
          OutBit<="1"&EMIT_BYTE_RUHEND&'0';
          EMIT_ANGEKOMMEN_LOCAL<=EMIT_ABGESCHICKT_RUHEND;
          else OutBit<="1111111111"; end if;
        xcount2<=x"B";
        else xcount2<=x"0"; end if;
    end if;
    EMIT_ANGEKOMMEN<=EMIT_ANGEKOMMEN_LOCAL;
  end process;

process
begin wait until (CLK_I'event and CLK_I='0');
  EMIT_BYTE_RUHEND<=EMIT_BYTE;
  EMIT_ABGESCHICKT_RUHEND<=EMIT_ABGESCHICKT;
  end process;

process
begin wait until (CLK_6_MHz'event and CLK_6_MHz='1');
  if (RxD_RUHEND='0' and scount=x"00000000") then scount<=x"00000008"; else
    if scount=x"00001000" then scount<=x"00000000";
      KEY_BYTE<=KEY_BYTE_LOCAL;
      KEY_ABGESCHICKT_LOCAL<=not KEY_ABGESCHICKT; 
      else 
        if scount/=0 then scount<=scount+8; -- +1 bei 50 MHz
          end if; end if; end if;
  if scount(11 downto 4)=x"28" then KEY_BYTE_LOCAL(0)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"43" then KEY_BYTE_LOCAL(1)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"5E" then KEY_BYTE_LOCAL(2)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"7A" then KEY_BYTE_LOCAL(3)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"95" then KEY_BYTE_LOCAL(4)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"B0" then KEY_BYTE_LOCAL(5)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"CB" then KEY_BYTE_LOCAL(6)<=RxD_RUHEND;
    elsif scount(11 downto 4)=x"E6" then KEY_BYTE_LOCAL(7)<=RxD_RUHEND;
      end if; 
  KEY_ABGESCHICKT <= KEY_ABGESCHICKT_LOCAL; 
  end process;

process
begin wait until (CLK_6_MHz'event and CLK_6_MHz='0');
  RXD_RUHEND<=RXD;
  end process;

end Step_10;
