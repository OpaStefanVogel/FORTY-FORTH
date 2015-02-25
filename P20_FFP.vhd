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
    WE_O: out STD_LOGIC;
    
    -- nur zur Simulation und Fehlersuche:
    PC_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    PD_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    SP_SIM: out integer;
    A_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    B_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    C_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    D_SIM: out STD_LOGIC_VECTOR (15 downto 0)
    );
end FortyForthProcessor;

architecture Step_7 of FortyForthProcessor is

type REG is array(0 to 3) of STD_LOGIC_VECTOR (15 downto 0);
type RAMTYPE is array(0 to 8*1024-1) of STD_LOGIC_VECTOR (15 downto 0);
  signal ProgRAM: RAMTYPE:=(
  x"1234", -- BEGIN 1234
  x"0100", -- 0100
  x"A009", -- !
  x"0100", -- 0100 
  x"A00A", -- @
  x"B300", -- DROP
  x"3210", -- BEGIN 3210
  x"0100", -- 0100
  x"A009", -- !
  x"0100", -- 0100 
  x"A00A", -- @
  x"B300", -- DROP
  x"8FF1", -- AGAIN
  others=>x"0000");
type RBBTYPE is array(0 to 8*1024-1) of STD_LOGIC_VECTOR (7 downto 0);
signal ramE000bisFFFF: RBBTYPE:=(
  others=>x"00");
type RXTYPE is array(0 to 1024-1) of STD_LOGIC_VECTOR (15 downto 0);
shared variable ram2C00bis2FFF: RXTYPE:=(
  others=>x"0000");

--diese Funktion wertet von SP nur die beiden niedrigsten Bits aus
  function P(SP : integer) return integer is begin
    return CONV_INTEGER(CONV_UNSIGNED(SP,2));
    end;

-- alles Signale um die Stapel-RAM's zu machen.
signal HOLE_VOM_STAPEL,STORE_ZUM_STAPEL,ADRESSE_ZUM_STAPEL: REG;
signal WE_ZUM_STAPEL: STD_LOGIC_VECTOR (3 downto 0);
type STAPELTYPE is array(0 to 31) of STD_LOGIC_VECTOR (15 downto 0);
signal stap1,stap2,stap3,stap0: STAPELTYPE:=(others=>x"0000");
-- Rueckkehrstapel
signal RPC,RPCC: STD_LOGIC_VECTOR (15 downto 0);
signal RP: STD_LOGIC_VECTOR (15 downto 0):=x"3000";
signal RW: STD_LOGIC;
signal stapR: STAPELTYPE:=(others=>x"0000");
-- kompletten Speicher anschliessen
signal PC_ZUM_ProgRAM,PD_VOM_ProgRAM: STD_LOGIC_VECTOR (15 downto 0);
signal FETCH_VOM_ProgRAM,STORE_ZUM_RAM,EXFET,ADRESSE_ZUM_RAM: STD_LOGIC_VECTOR (15 downto 0);
signal WE_ZUM_RAM,WE_ZUM_ProgRAM: STD_LOGIC;


begin

process
variable PC,PD,ADR,DAT,DIST: STD_LOGIC_VECTOR (15 downto 0):=x"0000";
variable WE: STD_LOGIC;
variable SP: integer:=0;
variable R: REG:=(others=>x"0000");
-- Stapeleintraege benennen
variable A,B,C,D: STD_LOGIC_VECTOR (15 downto 0):=x"0000";
variable T: integer range 0 to 4;
variable W: STD_LOGIC_VECTOR (3 downto 0);
-- fuer Umstapeln 
variable STAK: STD_LOGIC_VECTOR (7 downto 0);
-- fuer Rechenoperationen mit Uebertrag
variable U: STD_LOGIC_VECTOR (31 downto 0);

begin wait until (CLK_I'event and CLK_I='0');           -- Simulation --
  PD:=PD_VOM_ProgRAM;                                   PC_SIM<=PC;
  PC:=PC+1;                                             PD_SIM<=PD;
  WE:='0';                                              SP_SIM<=SP;
  DIST:=PD(11)&PD(11)&PD(11)&PD(11)&PD(11 downto 0);
  -- oberste 4 Stapeleintraege entnehmen
  R:=HOLE_VOM_STAPEL;                                   -- Simulation --
  A:=R(P(SP-1));                                        A_SIM<=A;
  B:=R(P(SP-2));                                        B_SIM<=B;
  C:=R(P(SP-3));                                        C_SIM<=C;
  D:=R(P(SP-4));                                        D_SIM<=D;
  T:=0;
  -- Rueckkehrstapel
  RW<='0';

  if PD(15 downto 13)="010" then                 -- 4000-5FFF Unterprogrammaufruf
    RPC<=PC;PC:=PD and x"3FFF";RP<=RP-1;RW<='1';
    elsif PD(15 downto 12)=x"8" then PC:=PC+DIST;-- 8000-8FFF relativer Sprung
    elsif PD(15 downto 12)=x"9" then             -- 9000-9FFF bedingter relativer Sprung
      if A=x"0000" then PC:=PC+DIST; end if; SP:=SP-1;
    elsif PD=x"A003" then PC:=RPCC;RP<=RP+1;     -- ; Rückkehr aus Unterprogramm
    elsif PD=x"A00D" then -- 0= Vergleich ob gleich Null
      if A=x"0000" then A:=x"FFFF"; 
        else A:=x"0000"; end if;
      T:=1;
    elsif PD=x"A00F" then -- 0< Vergleich ob kleiner Null
      if A>=x"8000" then A:=x"FFFF";
        else A:=x"0000"; end if;
      T:=1;
    elsif PD=x"A000" then -- MINUS Vorzeichen wechseln
      A:=(not A)+1;
      T:=1;
    elsif PD=x"A00B" then -- NOT Bitweises Komplement
      A:=not A;
      T:=1;
    elsif PD=x"A008" then -- AND Bitweises Und
      A:=B and A; 
      T:=1;
      SP:=SP-1;
    elsif PD=x"A00E" then -- OR Bitweises Oder
      A:=B or A; 
      T:=1;
      SP:=SP-1;
    elsif PD=x"A007" then -- + Addition
      A:=B+A; 
      T:=1;
      SP:=SP-1;
    elsif PD=x"A001" then -- U+ Addition mit Übertrag
      U:=(x"0000"&C)+(x"0000"&B)+(x"0000"&A);
      B:=U(31 downto 16);
      A:=U(15 downto 0);
      T:=2;
      SP:=SP-1;
    elsif PD=x"A002" then -- U* Multiplikation mit Übertrag
      U:=(x"0000"&C)+B*A;
      B:=U(31 downto 16);
      A:=U(15 downto 0);
      T:=2;
      SP:=SP-1;
    elsif PD=x"A009" then -- STORE Speicheradresse beschreiben
      case A is
        when x"D001" => SP:=CONV_INTEGER(B);
        when x"D002" => RP<=B;
        when "1101000000000011" => PC:=B;
        when others => ADR:=A;DAT:=B;WE:='1' ;
        end case;
      T:=0;
      SP:=SP-2;
    elsif PD=x"A00A" then -- FETCH Speicheradresse lesen
      case A is
        when x"D001" => A:=CONV_STD_LOGIC_VECTOR(SP,16);
        when x"D002" => A:=RP;
        when x"D003" => A:=PC;
        when others => A:=EXFET;
        end case;
      T:=1;
    elsif PD(15 downto 12)=x"B" then           -- B000-BFFF Umstapeln
      STAK:="00000000";
      if PD(7)='1' then STAK:=STAK(5 downto 0)&"11"; T:=T+1; end if;
      if PD(6)='1' then STAK:=STAK(5 downto 0)&"10"; T:=T+1; end if;
      if PD(5)='1' then STAK:=STAK(5 downto 0)&"01"; T:=T+1; end if;
      if PD(4)='1' then STAK:=STAK(5 downto 0)&"00"; T:=T+1; end if;
      if PD(3)='1' then STAK:=STAK(5 downto 0)&"11"; T:=T+1; end if;
      if PD(2)='1' then STAK:=STAK(5 downto 0)&"10"; T:=T+1; end if;
      if PD(1)='1' then STAK:=STAK(5 downto 0)&"01"; T:=T+1; end if;
      if PD(0)='1' then STAK:=STAK(5 downto 0)&"00"; T:=T+1; end if;
      A:=R(P(SP-1-CONV_INTEGER(STAK(1 downto 0))));
      B:=R(P(SP-1-CONV_INTEGER(STAK(3 downto 2))));
      C:=R(P(SP-1-CONV_INTEGER(STAK(5 downto 4))));
      D:=R(P(SP-1-CONV_INTEGER(STAK(7 downto 6))));
      SP:=SP+CONV_INTEGER(PD(11 downto 8))-4;
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
  if WE='1' then ADRESSE_ZUM_RAM<=ADR; else ADRESSE_ZUM_RAM<=R(P(SP-1)); end if;
  STORE_ZUM_RAM<=DAT;
  WE_ZUM_RAM<=WE;
  -- PC 
  PC_ZUM_ProgRAM<=PC;
  end process;

ADR_O<=ADRESSE_ZUM_RAM;
DAT_O<=STORE_ZUM_RAM;
WE_O<=WE_ZUM_RAM;

EXFET<=FETCH_VOM_ProgRAM when ADRESSE_ZUM_RAM(15 downto 13)="000" else
--       FETCH_VOM_RAM(7) when ADRESSE_ZUM_RAM(15 downto 10)="001011" else
--       x"00"&FETCH_VOM_RAM(13)(7 downto 0) when ADRESSE_ZUM_RAM(15 downto 13)="111" else
       DAT_I;

WE_ZUM_ProgRAM<=WE_ZUM_RAM when ADRESSE_ZUM_RAM(15 downto 13)="000" else '0';
--WE_ZUM_RAM(07)<=WSTORE_ZUM_RAM when ADRESSE_ZUM_RAM(15 downto 10)="001011" else '0';
--WE_ZUM_RAM(13)<=WSTORE_ZUM_RAM when ADRESSE_ZUM_RAM(15 downto 13)="111" else '0';


process 
begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_ProgRAM='1' then 
    ProgRAM(CONV_INTEGER(ADRESSE_ZUM_RAM(10 downto 0)))<=STORE_ZUM_RAM; 
    FETCH_VOM_ProgRAM<=STORE_ZUM_RAM; 
	 else
      FETCH_VOM_ProgRAM<=ProgRAM(CONV_INTEGER(ADRESSE_ZUM_RAM(10 downto 0)));
      end if;
  PD_VOM_ProgRAM<=ProgRAM(CONV_INTEGER(PC_ZUM_ProgRAM(10 downto 0)));
  end process;

--process 
--begin wait until (CLK_I'event and CLK_I='1');
--  if WE_ZUM_RAM(13)='1' then 
--    ramE000bisFFFF(CONV_INTEGER(ADRESSE_ZUM_RAM(12 downto 0)))<=STORE_ZUM_RAM(7 downto 0); 
--    FETCH_VOM_RAM(13)<=STORE_ZUM_RAM; 
--	 else
--      FETCH_VOM_RAM(13)<=x"00"&ramE000bisFFFF(CONV_INTEGER(ADRESSE_ZUM_RAM(12 downto 0)));
--      end if;
--  end process;

--Rueckkehrstapel:
--process 
--begin wait until (CLK_I'event and CLK_I='1');
--  if WE_ZUM_RAM(7)='1' then 
--    ram2C00bis2FFF(CONV_INTEGER(ADRESSE_ZUM_RAM(9 downto 0))):=STORE_ZUM_RAM; 
--    end if;
--  FETCH_VOM_RAM(7)<=ram2C00bis2FFF(CONV_INTEGER(ADRESSE_ZUM_RAM(9 downto 0)));
--  end process;
--process 
--begin wait until (CLK_I'event and CLK_I='1');
--  if RW_ZUM_RAM='1' then 
--    ram2C00bis2FFF(CONV_INTEGER(RP_ZUM_RAM(9 downto 0))):=RPC_ZUM_RAM; 
--    end if;
--  RPCC_VOM_RAM<=ram2C00bis2FFF(CONV_INTEGER(RP_ZUM_RAM(9 downto 0)));
--  end process;

process begin wait until (CLK_I'event and CLK_I='1');
  if RW='1' then
    stapR(CONV_INTEGER(RP(4 downto 0)))<=RPC;
    RPCC<=RPC;
     else
      RPCC<=stapR(CONV_INTEGER(RP(4 downto 0)));
    end if;
  end process;

--StapelRAM:
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(0)='1' then
    stap0(CONV_INTEGER(ADRESSE_ZUM_STAPEL(0)(6 downto 2)))<=STORE_ZUM_STAPEL(0);
    HOLE_VOM_STAPEL(0)<=STORE_ZUM_STAPEL(0);
     else
      HOLE_VOM_STAPEL(0)<=stap0(CONV_INTEGER(ADRESSE_ZUM_STAPEL(0)(6 downto 2)));
    end if;
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(1)='1' then
    stap1(CONV_INTEGER(ADRESSE_ZUM_STAPEL(1)(6 downto 2)))<=STORE_ZUM_STAPEL(1);
    HOLE_VOM_STAPEL(1)<=STORE_ZUM_STAPEL(1);
     else
      HOLE_VOM_STAPEL(1)<=stap1(CONV_INTEGER(ADRESSE_ZUM_STAPEL(1)(6 downto 2)));
    end if;
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(2)='1' then
    stap2(CONV_INTEGER(ADRESSE_ZUM_STAPEL(2)(6 downto 2)))<=STORE_ZUM_STAPEL(2);
    HOLE_VOM_STAPEL(2)<=STORE_ZUM_STAPEL(2);
     else
      HOLE_VOM_STAPEL(2)<=stap2(CONV_INTEGER(ADRESSE_ZUM_STAPEL(2)(6 downto 2)));
    end if;
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_STAPEL(3)='1' then
    stap3(CONV_INTEGER(ADRESSE_ZUM_STAPEL(3)(6 downto 2)))<=STORE_ZUM_STAPEL(3);
    HOLE_VOM_STAPEL(3)<=STORE_ZUM_STAPEL(3);
     else
      HOLE_VOM_STAPEL(3)<=stap3(CONV_INTEGER(ADRESSE_ZUM_STAPEL(3)(6 downto 2)));
    end if;
  end process;

end Step_7;
