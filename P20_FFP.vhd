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

architecture Step_3 of FortyForthProcessor is

type REG is array(0 to 3) of STD_LOGIC_VECTOR (15 downto 0);
type RAMTYPE is array(0 to 15) of STD_LOGIC_VECTOR (15 downto 0);

signal ProgRAM: RAMTYPE:=(
  x"0001",x"0002",x"0003",x"0004",x"0005",         -- BEGIN 1 2 3 4 5
  x"2D04",x"A009",x"2D04",x"A009",x"2D04",x"A009", -- 2D04 ! 2D04 ! 2D04 !
  x"2D04",x"A009",x"2D04",x"A009",x"8FF0",         -- 2D04 ! 2D04 ! AGAIN
  others=>x"0000");

--diese Funktion wertet von SP nur die beiden niedrigsten Bits aus
  function P(SP : integer) return integer is begin
    return CONV_INTEGER(CONV_UNSIGNED(SP,2));
    end;

-- alles Signale um die Stapel-RAM's zu machen.
signal HOLE_VOM_STAPEL,STORE_ZUM_STAPEL,ADRESSE_ZUM_STAPEL: REG;
signal WE_ZUM_STAPEL: STD_LOGIC_VECTOR (3 downto 0);
type STAPELTYPE is array(0 to 31) of STD_LOGIC_VECTOR (15 downto 0);
signal stap1,stap2,stap3,stap0: STAPELTYPE;

begin

process
variable PC,PD,ADR,DAT,DIST: STD_LOGIC_VECTOR (15 downto 0):=x"0000";
variable WE: STD_LOGIC;
variable SP: integer:=0;
variable R: REG;
-- Stapeleintraege benennen
variable A,B,C,D: STD_LOGIC_VECTOR (15 downto 0);
variable T: integer range 0 to 4;
variable W: STD_LOGIC_VECTOR (3 downto 0);

begin wait until (CLK_I'event and CLK_I='0');
  PD:=ProgRAM(CONV_INTEGER(PC(3 downto 0)));
  PC:=PC+1; 
  WE:='0';
  DIST:=PD(11)&PD(11)&PD(11)&PD(11)&PD(11 downto 0);
  -- oberste 4 Stapeleintraege entnehmen
  R:=HOLE_VOM_STAPEL;
  A:=R(P(SP-1));
  B:=R(P(SP-2));
  C:=R(P(SP-3));
  D:=R(P(SP-4));
  T:=0;

  if PD(15 downto 12)=x"8" then PC:=PC+DIST;               -- JR
    elsif PD=x"B501" then SP:=SP+1; T:=1;                  -- DUP
    elsif PD=x"A007" then A:=A+B; SP:=SP-1;T:=1;           -- +
    elsif PD=x"A009" then ADR:=A;DAT:=B;WE:='1';SP:=SP-2;  -- !
    else A:=PD; SP:=SP+1; T:=1; end if;                    -- LIT
    
  -- oberste T Stapeleintraege zurückspeichern
  W:="0000";
  if T/=0 then R(P(SP-1)):=A; W(P(SP-1)):='1'; 
    if T/=1 then R(P(SP-2)):=B; W(P(SP-2)):='1'; 
      if T/=2 then R(P(SP-3)):=C; W(P(SP-3)):='1'; 
        if T/=3 then R(P(SP-4)):=D; W(P(SP-4)):='1'; 
          end if; end if; end if; end if;
  -- Ausgabeadresse zum StapRAM zusammenbasteln
  ADRESSE_ZUM_STAPEL(0)<=CONV_STD_LOGIC_VECTOR(SP-1,16) and x"FFFD";
  ADRESSE_ZUM_STAPEL(1)<=CONV_STD_LOGIC_VECTOR(SP-2,16) and x"FFFD";
  ADRESSE_ZUM_STAPEL(2)<=CONV_STD_LOGIC_VECTOR(SP-3,16) or x"0002";
  ADRESSE_ZUM_STAPEL(3)<=CONV_STD_LOGIC_VECTOR(SP-4,16) or x"0002";
  STORE_ZUM_STAPEL(0)<=R(0);
  STORE_ZUM_STAPEL(1)<=R(1);
  STORE_ZUM_STAPEL(2)<=R(2);
  STORE_ZUM_STAPEL(3)<=R(3);
  WE_ZUM_STAPEL<=W;
  -- ADR_O, DAT_O, WE_O
  if WE='1' then ADR_O<=ADR; else ADR_O<=R(P(SP-1)); end if;
  DAT_O<=DAT;
  WE_O<=WE;
  end process;

--StapelRAM: 
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(0)='1' then 
    stap0(CONV_INTEGER(ADRESSE_ZUM_STAPEL(0)(5 downto 2)))<=STORE_ZUM_STAPEL(0); 
    HOLE_VOM_STAPEL(0)<=STORE_ZUM_STAPEL(0); 
     else
      HOLE_VOM_STAPEL(0)<=stap0(CONV_INTEGER(ADRESSE_ZUM_STAPEL(0)(5 downto 2)));
    end if;
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(1)='1' then 
    stap1(CONV_INTEGER(ADRESSE_ZUM_STAPEL(1)(5 downto 2)))<=STORE_ZUM_STAPEL(1); 
    HOLE_VOM_STAPEL(1)<=STORE_ZUM_STAPEL(1); 
     else
      HOLE_VOM_STAPEL(1)<=stap1(CONV_INTEGER(ADRESSE_ZUM_STAPEL(1)(5 downto 2)));
    end if;
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(2)='1' then 
    stap2(CONV_INTEGER(ADRESSE_ZUM_STAPEL(2)(5 downto 2)))<=STORE_ZUM_STAPEL(2); 
    HOLE_VOM_STAPEL(2)<=STORE_ZUM_STAPEL(2); 
     else
      HOLE_VOM_STAPEL(2)<=stap2(CONV_INTEGER(ADRESSE_ZUM_STAPEL(2)(5 downto 2)));
    end if;
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(3)='1' then 
    stap3(CONV_INTEGER(ADRESSE_ZUM_STAPEL(3)(5 downto 2)))<=STORE_ZUM_STAPEL(3); 
    HOLE_VOM_STAPEL(3)<=STORE_ZUM_STAPEL(3); 
     else
      HOLE_VOM_STAPEL(3)<=stap3(CONV_INTEGER(ADRESSE_ZUM_STAPEL(3)(5 downto 2)));
    end if;
  end process;

end Step_3;
