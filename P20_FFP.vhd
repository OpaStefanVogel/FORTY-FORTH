library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FortyForthProcessor is
  Port (
    CLK_I: in STD_LOGIC;
    DAT_I: in STD_LOGIC_VECTOR (15 downto 0);
    ADR_O: out STD_LOGIC_VECTOR (15 downto 0);
    DAT_O: out STD_LOGIC_VECTOR (15 downto 0);
    WE_O: out STD_LOGIC
    );
end FortyForthProcessor;

architecture Step_1 of FortyForthProcessor is

type REG is array(0 to 3) of STD_LOGIC_VECTOR (15 downto 0);
type RAMTYPE is array(0 to 15) of STD_LOGIC_VECTOR (15 downto 0);

signal ProgRAM: RAMTYPE:=(
  x"0000",-- 0
  x"0001",-- 1      <----------------<
  x"A007",-- +                       |
  x"B501",-- DUP                     |
  x"2D04",-- 2D04                    |
  x"A009",-- !                       |
  x"8FFA",-- JR = jump relative to --^
  others=>x"0000");


begin

process
variable PC,PD,ADR,DAT,DIST: STD_LOGIC_VECTOR (15 downto 0):=x"0000";
variable WE: STD_LOGIC;
variable SP: integer:=0;
variable R: REG;

begin wait until (CLK_I'event and CLK_I='0');
  PD:=ProgRAM(CONV_INTEGER(PC(3 downto 0)));
  PC:=PC+1; 
  WE:='0';
  DIST:=PD(11)&PD(11)&PD(11)&PD(11)&PD(11 downto 0);
  
  if PD(15 downto 12)=x"8" then PC:=PC+DIST;                          -- JR
    elsif PD=x"B501" then R(SP):=R(SP-1); SP:=SP+1;                   -- DUP
    elsif PD=x"A007" then R(SP-2):=R(SP-2)+R(SP-1); SP:=SP-1;         -- +
    elsif PD=x"A009" then ADR:=R(SP-1);DAT:=R(SP-2);WE:='1';SP:=SP-2; -- !
    else R(SP):=PD; SP:=SP+1; end if;                                 -- LIT
    
  if WE='1' then ADR_O<=ADR; else ADR_O<=R(SP-1); end if;
  DAT_O<=DAT;
  WE_O<=WE;
  end process;

end Step_1;
