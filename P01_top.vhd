library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  Port ( 
    CLK: in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR (7 downto 0);
            
    -- nur zur Simulation und Fehlersuche:
    CLK_SIM : out STD_LOGIC;
    PC_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    PD_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    SP_SIM: out integer;
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
        
    -- nur zur Simulation und Fehlersuche:
    PC_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    PD_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    SP_SIM: out integer;
    A_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    B_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    C_SIM: out STD_LOGIC_VECTOR (15 downto 0);
    D_SIM: out STD_LOGIC_VECTOR (15 downto 0)
    );
  end component;

signal WE      : STD_LOGIC;
signal ADR,DAT : STD_LOGIC_VECTOR (15 downto 0);

begin
  -- component instantiation
DUT0: FortyForthProcessor
  port map (
    CLK_I => CLK,
    DAT_I => x"0000",
    ADR_O => ADR,
    DAT_O => DAT,
    WE_O => WE,
    
      -- nur fuer Simulation
    PC_SIM => PC_SIM,
    PD_SIM => PD_SIM,
    SP_SIM => SP_SIM,
    A_SIM => A_SIM,
    B_SIM => B_SIM,
    C_SIM => C_SIM,
    D_SIM => D_SIM      
    );

process begin wait until (CLK'event and CLK='1');
  if WE='1' then
    if ADR=x"2D04" then LEDS<=DAT(7 downto 0); 
      end if; 
    end if;
  end process;

end Step_1;

