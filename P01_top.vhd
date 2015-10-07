library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
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
    CLK_SIM : out STD_LOGIC;
    PC_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    PD_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    SP_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    A_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    B_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    C_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    D_SIM: out STD_LOGIC_VECTOR (15 downto 0)
    );
  end top;

architecture Step_1 of top is

component FortyForthProcessor
  port (
    CLK_I: in STD_LOGIC;
    DAT_I: in STD_LOGIC_VECTOR (15 downto 0);
    ADR_O: out STD_LOGIC_VECTOR (15 downto 0);
    DAT_O: out STD_LOGIC_VECTOR (15 downto 0);
    WE_O: out STD_LOGIC;
        
    -- EMIT --
    EMIT_ABGESCHICKT: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_ANGEKOMMEN: in STD_LOGIC;

     -- KEY --
    KEY_ABGESCHICKT: in STD_LOGIC;
    KEY_BYTE: in STD_LOGIC_VECTOR (7 downto 0);
    KEY_ANGEKOMMEN: out STD_LOGIC;

    -- LINKS --
    LINKS_ABGESCHICKT: in STD_LOGIC;
    LINKS_DAT:  in STD_LOGIC_VECTOR (15 downto 0);
    LINKS_ADR: out STD_LOGIC_VECTOR (15 downto 0);
    LINKS_ANGEKOMMEN: out STD_LOGIC;
    
    -- RECHTS --
    RECHTS_ABGESCHICKT: out STD_LOGIC;
    RECHTS_DAT: out STD_LOGIC_VECTOR (15 downto 0);
    RECHTS_ADR:  in STD_LOGIC_VECTOR (15 downto 0);
    RECHTS_ANGEKOMMEN: in STD_LOGIC;
    
    -- OBEN --
    OBEN_ABGESCHICKT: in STD_LOGIC;
    OBEN_DAT:  in STD_LOGIC_VECTOR (15 downto 0);
    OBEN_ADR: out STD_LOGIC_VECTOR (15 downto 0);
    OBEN_ANGEKOMMEN: out STD_LOGIC;
    
    -- UNTEN --
    UNTEN_ABGESCHICKT: out STD_LOGIC;
    UNTEN_DAT: out STD_LOGIC_VECTOR (15 downto 0);
    UNTEN_ADR:  in STD_LOGIC_VECTOR (15 downto 0);
    UNTEN_ANGEKOMMEN: in STD_LOGIC;
    
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

signal WE      : STD_LOGIC;
signal ADR,DAT : STD_LOGIC_VECTOR (15 downto 0);

signal L00_AB, L00_AN, R00_AB, R00_AN, O00_AB, O00_AN, U00_AB, U00_AN:  STD_LOGIC;
signal L00_DAT,L00_ADR,R00_DAT,R00_ADR,O00_DAT,O00_ADR,U00_DAT,U00_ADR: STD_LOGIC_VECTOR (15 downto 0);

begin
  -- component instantiation
DUT00: FortyForthProcessor
  port map (
    CLK_I => CLK,DAT_I => x"0000",ADR_O => ADR,DAT_O => DAT,WE_O => WE,
      EMIT_ABGESCHICKT => EMIT_ABGESCHICKT,EMIT_BYTE => EMIT_BYTE,EMIT_ANGEKOMMEN => EMIT_ANGEKOMMEN,-- EMIT --
       KEY_ABGESCHICKT => KEY_ABGESCHICKT,  KEY_BYTE => KEY_BYTE,  KEY_ANGEKOMMEN => KEY_ANGEKOMMEN, -- KEY --
     LINKS_ABGESCHICKT => L00_AB, LINKS_DAT => L00_DAT, LINKS_ADR => L00_ADR, LINKS_ANGEKOMMEN => L00_AN,-- LINKS --
    RECHTS_ABGESCHICKT => R00_AB,RECHTS_DAT => R00_DAT,RECHTS_ADR => R00_ADR,RECHTS_ANGEKOMMEN => R00_AN,-- RECHTS --
      OBEN_ABGESCHICKT => O00_AB,  OBEN_DAT => O00_DAT,  OBEN_ADR => O00_ADR,  OBEN_ANGEKOMMEN => O00_AN,-- OBEN --
     UNTEN_ABGESCHICKT => U00_AB, UNTEN_DAT => U00_DAT, UNTEN_ADR => U00_ADR, UNTEN_ANGEKOMMEN => U00_AN,-- UNTEN --
    PC_SIM => PC_SIM,PD_SIM => PD_SIM,A_SIM => A_SIM,B_SIM => B_SIM,C_SIM => C_SIM,D_SIM => D_SIM,SP_SIM => SP_SIM-- nur fuer Simulation
    );


L00_AB<=R00_AB; L00_DAT<=R00_DAT; R00_ADR<=L00_ADR; R00_AN<=L00_AN;
O00_AB<=U00_AB; O00_DAT<=U00_DAT; U00_ADR<=O00_ADR; U00_AN<=O00_AN;


process begin wait until (CLK'event and CLK='1');
  if WE='1' then
    if ADR=x"2D04" then LEDS<=DAT(7 downto 0); 
      end if; 
    end if;
  end process;

end Step_1;

