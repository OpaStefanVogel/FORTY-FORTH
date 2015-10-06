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

signal L0_ABGESCHICKT,R0_ANGEKOMMEN: STD_LOGIC;
signal L0_ADR,R0_DAT: STD_LOGIC_VECTOR (15 downto 0);
signal O0_ABGESCHICKT,U0_ANGEKOMMEN: STD_LOGIC;
signal O0_ADR,U0_DAT: STD_LOGIC_VECTOR (15 downto 0);

begin
  -- component instantiation
DUT0: FortyForthProcessor
  port map (
    CLK_I => CLK,
    DAT_I => x"0000",
    ADR_O => ADR,
    DAT_O => DAT,
    WE_O => WE,
    
    -- EMIT --
    EMIT_ABGESCHICKT => EMIT_ABGESCHICKT,
    EMIT_BYTE => EMIT_BYTE,
    EMIT_ANGEKOMMEN => EMIT_ANGEKOMMEN,

     -- KEY --
    KEY_ABGESCHICKT => KEY_ABGESCHICKT,
    KEY_BYTE => KEY_BYTE,
    KEY_ANGEKOMMEN => KEY_ANGEKOMMEN,

    -- LINKS --
    LINKS_ABGESCHICKT => L0_ABGESCHICKT,
    LINKS_DAT => R0_DAT,
    LINKS_ADR => L0_ADR,
    LINKS_ANGEKOMMEN => R0_ANGEKOMMEN,
    
    -- RECHTS --
    RECHTS_ABGESCHICKT => L0_ABGESCHICKT,
    RECHTS_DAT => R0_DAT,
    RECHTS_ADR => L0_ADR,
    RECHTS_ANGEKOMMEN => R0_ANGEKOMMEN,
    
    -- OBEN --
    OBEN_ABGESCHICKT => O0_ABGESCHICKT,
    OBEN_DAT => U0_DAT,
    OBEN_ADR => O0_ADR,
    OBEN_ANGEKOMMEN => U0_ANGEKOMMEN,
    
    -- UNTEN --
    UNTEN_ABGESCHICKT => O0_ABGESCHICKT,
    UNTEN_DAT => U0_DAT,
    UNTEN_ADR => O0_ADR,
    UNTEN_ANGEKOMMEN => U0_ANGEKOMMEN,
    
    -- nur fuer Simulation
    PC_SIM => PC_SIM,
    PD_SIM => PD_SIM,
    A_SIM => A_SIM,
    B_SIM => B_SIM,
    C_SIM => C_SIM,
    D_SIM => D_SIM,  
    SP_SIM => SP_SIM
    );

process begin wait until (CLK'event and CLK='1');
  if WE='1' then
    if ADR=x"2D04" then LEDS<=DAT(7 downto 0); 
      end if; 
    end if;
  end process;

end Step_1;

