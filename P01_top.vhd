library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  generic ( NJ : integer := 2 ; NK : integer := 2 ; )
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
signal L01_AB, L01_AN, R01_AB, R01_AN, O01_AB, O01_AN, U01_AB, U01_AN:  STD_LOGIC;
signal L01_DAT,L01_ADR,R01_DAT,R01_ADR,O01_DAT,O01_ADR,U01_DAT,U01_ADR: STD_LOGIC_VECTOR (15 downto 0);
signal L10_AB, L10_AN, R10_AB, R10_AN, O10_AB, O10_AN, U10_AB, U10_AN:  STD_LOGIC;
signal L10_DAT,L10_ADR,R10_DAT,R10_ADR,O10_DAT,O10_ADR,U10_DAT,U10_ADR: STD_LOGIC_VECTOR (15 downto 0);
signal L11_AB, L11_AN, R11_AB, R11_AN, O11_AB, O11_AN, U11_AB, U11_AN:  STD_LOGIC;
signal L11_DAT,L11_ADR,R11_DAT,R11_ADR,O11_DAT,O11_ADR,U11_DAT,U11_ADR: STD_LOGIC_VECTOR (15 downto 0);

signal NN01,NN10,NN11: STD_LOGIC;

-- neu fuer generic
type CON1  is array (0 to NJ*NK-1) of STD_LOGIC;
type CON8  is array (0 to NJ*NK-1) of STD_LOGIC_VECTOR (7 downto 0);
type CON16 is array (0 to NJ*NK-1) of STD_LOGIC_VECTOR (15 downto 0);


signal L_AB, L_AN, R_AB, R_AN, O_AB, O_AN, U_AB, U_AN :  CON1  ;
signal L_DAT,L_ADR,R_DAT,R_ADR,O_DAT,O_ADR,U_DAT,U_ADR : CON16 ;
signal K_AB, K_AN, E_AB, E_AN : CON1 ;
signal K_BYTE, E_BYTE : CON8 ;
signal ADR, DAT_I, DAT_O : CON16 ;
signal WE : CON1 ;
signal PC, PD, A, B, C, D, SP : CON16 ;

begin
  -- component instantiation
DUT00: FortyForthProcessor
  port map (
--    CLK_I => CLK,DAT_I => x"0000",ADR_O => ADR,DAT_O => DAT,WE_O => WE,
--      EMIT_ABGESCHICKT => EMIT_ABGESCHICKT,EMIT_BYTE => EMIT_BYTE,EMIT_ANGEKOMMEN => EMIT_ANGEKOMMEN,-- EMIT --
--       KEY_ABGESCHICKT => KEY_ABGESCHICKT,  KEY_BYTE => KEY_BYTE,  KEY_ANGEKOMMEN => KEY_ANGEKOMMEN, -- KEY --
--     LINKS_ABGESCHICKT => L00_AB, LINKS_DAT => L00_DAT, LINKS_ADR => L00_ADR, LINKS_ANGEKOMMEN => L00_AN,-- LINKS --
--    RECHTS_ABGESCHICKT => R00_AB,RECHTS_DAT => R00_DAT,RECHTS_ADR => R00_ADR,RECHTS_ANGEKOMMEN => R00_AN,-- RECHTS --
--      OBEN_ABGESCHICKT => O00_AB,  OBEN_DAT => O00_DAT,  OBEN_ADR => O00_ADR,  OBEN_ANGEKOMMEN => O00_AN,-- OBEN --
--     UNTEN_ABGESCHICKT => U00_AB, UNTEN_DAT => U00_DAT, UNTEN_ADR => U00_ADR, UNTEN_ANGEKOMMEN => U00_AN,-- UNTEN --
--    PC_SIM => PC_SIM,PD_SIM => PD_SIM,A_SIM => A_SIM,B_SIM => B_SIM,C_SIM => C_SIM,D_SIM => D_SIM,SP_SIM => SP_SIM-- nur fuer Simulation
    CLK_I => CLK,DAT_I => DAT_I(0),ADR_O => ADR(0),DAT_O => DAT_O(0),WE_O => WE(0),
      EMIT_ABGESCHICKT => E_AB(0), EMIT_BYTE => E_BYTE(0), EMIT_ANGEKOMMEN => E_AN(0),-- EMIT --
       KEY_ABGESCHICKT => K_AB(0),  KEY_BYTE => K_BYTE(0),  KEY_ANGEKOMMEN => K_AN(0), -- KEY --
     LINKS_ABGESCHICKT => L_AB(0), LINKS_DAT => L_DAT(0), LINKS_ADR => L_ADR(0), LINKS_ANGEKOMMEN => L_AN(0),-- LINKS --
    RECHTS_ABGESCHICKT => R_AB(0),RECHTS_DAT => R_DAT(0),RECHTS_ADR => R_ADR(0),RECHTS_ANGEKOMMEN => R_AN(0),-- RECHTS --
      OBEN_ABGESCHICKT => O_AB(0),  OBEN_DAT => O_DAT(0),  OBEN_ADR => O_ADR(0),  OBEN_ANGEKOMMEN => O_AN(0),-- OBEN --
     UNTEN_ABGESCHICKT => U_AB(0), UNTEN_DAT => U_DAT(0), UNTEN_ADR => U_ADR(0), UNTEN_ANGEKOMMEN => U_AN(0),-- UNTEN --
    PC_SIM => PC(0),PD_SIM => PD(0),A_SIM => A(0),B_SIM => B(0),C_SIM => C(0),D_SIM => D(0),SP_SIM => SP(0) -- nur fuer Simulation
    );

DUT01: FortyForthProcessor
  port map (
--    CLK_I => CLK,DAT_I => x"0000",ADR_O => open,DAT_O => open,WE_O => open,
--      EMIT_ABGESCHICKT => NN01,EMIT_BYTE => open, EMIT_ANGEKOMMEN => NN01, -- EMIT --
--       KEY_ABGESCHICKT => '0',  KEY_BYTE => x"00", KEY_ANGEKOMMEN => open, -- KEY --
--    PC_SIM =>open,PD_SIM=>open,A_SIM=>open,B_SIM=>open,C_SIM=>open,D_SIM =>open,SP_SIM=>open-- nur fuer Simulation
    CLK_I => CLK,DAT_I => DAT_I(1),ADR_O => ADR(1),DAT_O => DAT_O(1),WE_O => WE(1),
      EMIT_ABGESCHICKT => E_AB(1), EMIT_BYTE => E_BYTE(1), EMIT_ANGEKOMMEN => E_AN(1),-- EMIT --
       KEY_ABGESCHICKT => K_AB(1),  KEY_BYTE => K_BYTE(1),  KEY_ANGEKOMMEN => K_AN(1), -- KEY --
     LINKS_ABGESCHICKT => L_AB(1), LINKS_DAT => L_DAT(1), LINKS_ADR => L_ADR(1), LINKS_ANGEKOMMEN => L_AN(1),-- LINKS --
    RECHTS_ABGESCHICKT => R_AB(1),RECHTS_DAT => R_DAT(1),RECHTS_ADR => R_ADR(1),RECHTS_ANGEKOMMEN => R_AN(1),-- RECHTS --
      OBEN_ABGESCHICKT => O_AB(1),  OBEN_DAT => O_DAT(1),  OBEN_ADR => O_ADR(1),  OBEN_ANGEKOMMEN => O_AN(1),-- OBEN --
     UNTEN_ABGESCHICKT => U_AB(1), UNTEN_DAT => U_DAT(1), UNTEN_ADR => U_ADR(1), UNTEN_ANGEKOMMEN => U_AN(1),-- UNTEN --
    PC_SIM => PC(1),PD_SIM => PD(1),A_SIM => A(1),B_SIM => B(1),C_SIM => C(1),D_SIM => D(1),SP_SIM => SP(1) -- nur fuer Simulation
    );

DUT10: FortyForthProcessor
  port map (
    CLK_I => CLK,DAT_I => DAT_I(2),ADR_O => ADR(2),DAT_O => DAT_O(2),WE_O => WE(2),
      EMIT_ABGESCHICKT => E_AB(2), EMIT_BYTE => E_BYTE(2), EMIT_ANGEKOMMEN => E_AN(2),-- EMIT --
       KEY_ABGESCHICKT => K_AB(2),  KEY_BYTE => K_BYTE(2),  KEY_ANGEKOMMEN => K_AN(2), -- KEY --
     LINKS_ABGESCHICKT => L_AB(2), LINKS_DAT => L_DAT(2), LINKS_ADR => L_ADR(2), LINKS_ANGEKOMMEN => L_AN(2),-- LINKS --
    RECHTS_ABGESCHICKT => R_AB(2),RECHTS_DAT => R_DAT(2),RECHTS_ADR => R_ADR(2),RECHTS_ANGEKOMMEN => R_AN(2),-- RECHTS --
      OBEN_ABGESCHICKT => O_AB(2),  OBEN_DAT => O_DAT(2),  OBEN_ADR => O_ADR(2),  OBEN_ANGEKOMMEN => O_AN(2),-- OBEN --
     UNTEN_ABGESCHICKT => U_AB(2), UNTEN_DAT => U_DAT(2), UNTEN_ADR => U_ADR(2), UNTEN_ANGEKOMMEN => U_AN(2),-- UNTEN --
    PC_SIM => PC(2),PD_SIM => PD(2),A_SIM => A(2),B_SIM => B(2),C_SIM => C(2),D_SIM => D(2),SP_SIM => SP(2) -- nur fuer Simulation
    );

DUT11: FortyForthProcessor
  port map (
    CLK_I => CLK,DAT_I => DAT_I(3),ADR_O => ADR(3),DAT_O => DAT_O(3),WE_O => WE(3),
      EMIT_ABGESCHICKT => E_AB(3), EMIT_BYTE => E_BYTE(3), EMIT_ANGEKOMMEN => E_AN(3),-- EMIT --
       KEY_ABGESCHICKT => K_AB(3),  KEY_BYTE => K_BYTE(3),  KEY_ANGEKOMMEN => K_AN(3), -- KEY --
     LINKS_ABGESCHICKT => L_AB(3), LINKS_DAT => L_DAT(3), LINKS_ADR => L_ADR(3), LINKS_ANGEKOMMEN => L_AN(3),-- LINKS --
    RECHTS_ABGESCHICKT => R_AB(3),RECHTS_DAT => R_DAT(3),RECHTS_ADR => R_ADR(3),RECHTS_ANGEKOMMEN => R_AN(3),-- RECHTS --
      OBEN_ABGESCHICKT => O_AB(3),  OBEN_DAT => O_DAT(3),  OBEN_ADR => O_ADR(3),  OBEN_ANGEKOMMEN => O_AN(3),-- OBEN --
     UNTEN_ABGESCHICKT => U_AB(3), UNTEN_DAT => U_DAT(3), UNTEN_ADR => U_ADR(3), UNTEN_ANGEKOMMEN => U_AN(3),-- UNTEN --
    PC_SIM => PC(3),PD_SIM => PD(3),A_SIM => A(3),B_SIM => B(3),C_SIM => C(3),D_SIM => D(3),SP_SIM => SP(3) -- nur fuer Simulation
    );


--L01_AB<=R00_AB; L01_DAT<=R00_DAT; R00_ADR<=L01_ADR; R00_AN<=L01_AN;
--L00_AB<=R01_AB; L00_DAT<=R01_DAT; R01_ADR<=L00_ADR; R01_AN<=L00_AN;
--L11_AB<=R10_AB; L11_DAT<=R10_DAT; R10_ADR<=L11_ADR; R10_AN<=L11_AN;
--L10_AB<=R11_AB; L10_DAT<=R11_DAT; R11_ADR<=L10_ADR; R11_AN<=L10_AN;

--O10_AB<=U00_AB; O10_DAT<=U00_DAT; U00_ADR<=O10_ADR; U00_AN<=O10_AN;
--O00_AB<=U10_AB; O00_DAT<=U10_DAT; U10_ADR<=O00_ADR; U10_AN<=O00_AN;
--O11_AB<=U01_AB; O11_DAT<=U01_DAT; U01_ADR<=O11_ADR; U01_AN<=O11_AN;
--O01_AB<=U11_AB; O01_DAT<=U11_DAT; U11_ADR<=O01_ADR; U11_AN<=O01_AN;

L_AB(1)<=R_AB(0); L_DAT(1)<=R_DAT(0); R_ADR(0)<=L_ADR(1); R_AN(0)<=L_AN(1);
L_AB(0)<=R_AB(1); L_DAT(0)<=R_DAT(1); R_ADR(1)<=L_ADR(0); R_AN(1)<=L_AN(0);
L_AB(3)<=R_AB(2); L_DAT(3)<=R_DAT(2); R_ADR(2)<=L_ADR(3); R_AN(2)<=L_AN(3);
L_AB(2)<=R_AB(3); L_DAT(2)<=R_DAT(3); R_ADR(3)<=L_ADR(2); R_AN(3)<=L_AN(2);

O_AB(2)<=U_AB(0); O_DAT(2)<=U_DAT(0); U_ADR(0)<=O_ADR(2); U_AN(0)<=O_AN(2);
O_AB(0)<=U_AB(2); O_DAT(0)<=U_DAT(2); U_ADR(2)<=O_ADR(0); U_AN(2)<=O_AN(0);
O_AB(3)<=U_AB(1); O_DAT(3)<=U_DAT(1); U_ADR(1)<=O_ADR(3); U_AN(1)<=O_AN(3);
O_AB(1)<=U_AB(3); O_DAT(1)<=U_DAT(3); U_ADR(3)<=O_ADR(1); U_AN(3)<=O_AN(1);

E_AN(1) <= E_AB(1) ;
E_AN(2) <= E_AB(2) ;
E_AN(3) <= E_AB(3) ;

EMIT_ABGESCHICKT <= E_AB(0) ;
EMIT_BYTE <= E_BYTE(0) ;
E_AN(0) <= EMIT_ANGEKOMMEN ;

K_AB(0) <= KEY_ABGESCHICKT ;
K_BYTE(0) <= KEY_BYTE ;
KEY_ANGEKOMMEN <= K_AN(0) ;

PC_SIM <= PC(0) ;
PD_SIM <= PD(0) ;
A_SIM <= A(0) ;
B_SIM <= B(0) ;
C_SIM <= C(0) ;
D_SIM <= D(0) ;
SP_SIM <= SP(0) ;

process begin wait until (CLK'event and CLK='1');
  if WE(0)='1' then
    if ADR(0)=x"2D04" then LEDS(0)<=DAT(0)(0); end if; 
    end if;
  if WE(1)='1' then
    if ADR(1)=x"2D04" then LEDS(1)<=DAT(1)(1); end if; 
    end if;
  if WE(2)='1' then
    if ADR(2)=x"2D04" then LEDS(2)<=DAT(2)(2); end if; 
    end if;
  if WE(3)='1' then
    if ADR(3)=x"2D04" then LEDS(3)<=DAT(3)(3); end if; 
    end if;
  end process;

end Step_1;

