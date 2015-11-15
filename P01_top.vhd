library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  generic ( NJ : integer := 2 ; NK : integer := 2 );
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
LABEL_1: for L in 0 to NJ*NK-1 generate
DUTL: FortyForthProcessor
  port map (
    CLK_I => CLK,DAT_I => DAT_I(L),ADR_O => ADR(L),DAT_O => DAT_O(L),WE_O => WE(L),
      EMIT_ABGESCHICKT => E_AB(L), EMIT_BYTE => E_BYTE(L), EMIT_ANGEKOMMEN => E_AN(L),-- EMIT --
       KEY_ABGESCHICKT => K_AB(L),  KEY_BYTE => K_BYTE(L),  KEY_ANGEKOMMEN => K_AN(L), -- KEY --
     LINKS_ABGESCHICKT => L_AB(L), LINKS_DAT => L_DAT(L), LINKS_ADR => L_ADR(L), LINKS_ANGEKOMMEN => L_AN(L),-- LINKS --
    RECHTS_ABGESCHICKT => R_AB(L),RECHTS_DAT => R_DAT(L),RECHTS_ADR => R_ADR(L),RECHTS_ANGEKOMMEN => R_AN(L),-- RECHTS --
      OBEN_ABGESCHICKT => O_AB(L),  OBEN_DAT => O_DAT(L),  OBEN_ADR => O_ADR(L),  OBEN_ANGEKOMMEN => O_AN(L),-- OBEN --
     UNTEN_ABGESCHICKT => U_AB(L), UNTEN_DAT => U_DAT(L), UNTEN_ADR => U_ADR(L), UNTEN_ANGEKOMMEN => U_AN(L),-- UNTEN --
    PC_SIM => PC(L),PD_SIM => PD(L),A_SIM => A(L),B_SIM => B(L),C_SIM => C(L),D_SIM => D(L),SP_SIM => SP(L) -- nur fuer Simulation
    );
LABEL_2:  if L>0 generate E_AN(L) <= E_AB(L) ; end generate ;
  end generate ;

LABEL_3: for J in 0 to NJ-1 generate
LABEL_4:   for K in 0 to NK-1 generate
LABEL_5:     if K=0 generate
      L_AB(J*NK)<=R_AB(J*NK+NK-1); L_DAT(J*NK)<=R_DAT(J*NK+NK-1);
      R_AN(J*NK+NK-1)<=L_AN(J*NK); R_ADR(J*NK+NK-1)<=L_ADR(J*NK);
      end generate ;
LABEL_6:     if K>0 generate
      L_AB(J*NK+K)<=R_AB(J*NK+K-1); L_DAT(J*NK+K)<=R_DAT(J*NK+K-1);
      R_AN(J*NK+K-1)<=L_AN(J*NK+K); R_ADR(J*NK+K-1)<=L_ADR(J*NK+K);
      end generate ;
LABEL_7:     if J=0 generate
      O_AB(K)<=U_AB((NJ-1)*NK+K); O_DAT(K)<=U_DAT((NJ-1)*NK+K);
      U_AN((NJ-1)*NK+K)<=O_AN(K); U_ADR((NJ-1)*NK+K)<=O_ADR(K);
      end generate ;
LABEL_8:     if J>0 generate
      O_AB(J*NK+K)<=U_AB((J-1)*NJ+K); O_DAT(J*NK+K)<=U_DAT((J-1)*NJ+K);
      U_AN((J-1)*NJ+K)<=O_AN(J*NK+K); U_ADR((J-1)*NJ+K)<=O_ADR(J*NK+K);
      end generate ;
    end generate ;
  end generate ;

-- L_AB(1)<=R_AB(0); L_DAT(1)<=R_DAT(0); R_ADR(0)<=L_ADR(1); R_AN(0)<=L_AN(1);
-- L_AB(0)<=R_AB(1); L_DAT(0)<=R_DAT(1); R_ADR(1)<=L_ADR(0); R_AN(1)<=L_AN(0);
-- L_AB(3)<=R_AB(2); L_DAT(3)<=R_DAT(2); R_ADR(2)<=L_ADR(3); R_AN(2)<=L_AN(3);
-- L_AB(2)<=R_AB(3); L_DAT(2)<=R_DAT(3); R_ADR(3)<=L_ADR(2); R_AN(3)<=L_AN(2);

-- O_AB(2)<=U_AB(0); O_DAT(2)<=U_DAT(0); U_ADR(0)<=O_ADR(2); U_AN(0)<=O_AN(2);
-- O_AB(0)<=U_AB(2); O_DAT(0)<=U_DAT(2); U_ADR(2)<=O_ADR(0); U_AN(2)<=O_AN(0);
-- O_AB(3)<=U_AB(1); O_DAT(3)<=U_DAT(1); U_ADR(1)<=O_ADR(3); U_AN(1)<=O_AN(3);
-- O_AB(1)<=U_AB(3); O_DAT(1)<=U_DAT(3); U_ADR(3)<=O_ADR(1); U_AN(3)<=O_AN(1);

-- E_AN(1) <= E_AB(1) ;
-- E_AN(2) <= E_AB(2) ;
-- E_AN(3) <= E_AB(3) ;

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

--process begin wait until (CLK'event and CLK='1');
--LABEL_9:   for L in 0 to NJ*NK-1 generate
--LABEL_10:    if L<8 generate
--      if WE(L)='1' then
--        if ADR(L)=x"2D04" then LEDS(L)<=DAT(L)(L); end if; 
--        end if;
--      end generate;
--    end generate;
--  end process;

end Step_1;

