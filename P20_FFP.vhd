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
    
    -- EMIT --
    EMIT_GESENDET: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_EMPFANGEN: in STD_LOGIC;
    
     -- EMIT --
    KEY_GESENDET: in STD_LOGIC;
    KEY_BYTE: in STD_LOGIC_VECTOR (7 downto 0);

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

architecture Step_9 of FortyForthProcessor is

type REG is array(0 to 3) of STD_LOGIC_VECTOR (15 downto 0);
type RAMTYPE is array(0 to 8*1024-1) of STD_LOGIC_VECTOR (15 downto 0);
-- Programmspeicher 0000H-1FFFH
signal ProgRAM: RAMTYPE:=(
--x"47D9",x"A003",x"449E",x"9001",x"A003",x"B300",x"8000",x"8FFA",x"0000",x"09E4",x"0000",x"0000",x"0000",x"0000",x"09D9",x"09CF", -- 0000-000F 
  x"4719",x"A003",x"449E",x"9001",x"A003",x"B300",x"8000",x"8FFA",x"0000",x"09E4",x"0000",x"0000",x"0000",x"0000",x"09D9",x"09CF", -- 0000-000F 
  x"4B0B",x"A003",x"4B0B",x"A003",x"5B60",x"A003",x"4478",x"A003",x"D000",x"A00A",x"0043",x"A00A",x"A009",x"0043",x"B501",x"A00A", -- 0010-001F 
  x"0001",x"A007",x"B501",x"03FF",x"A008",x"0000",x"42A7",x"9002",x"0400",x"42A0",x"B412",x"A009",x"A003",x"0044",x"A00A",x"0043", -- 0020-002F 
  x"A00A",x"42A7",x"9003",x"0000",x"0000",x"8007",x"0044",x"A00A",x"A00A",x"FFFF",x"0044",x"401E",x"A00C",x"A003",x"A003",x"A003", -- 0030-003F 
  x"3F00",x"0000",x"3000",x"FF22",x"FF22",x"FFFF",x"0000",x"0000",x"0010",x"FB00",x"FB00",x"FB08",x"FB0E",x"FB0D",x"0000",x"07F3", -- 0040-004F 
  x"0000",x"07D5",x"E000",x"E377",x"0058",x"0002",x"0000",x"2FEF",x"0000",x"E000",x"0001",x"472C",x"0029",x"45D1",x"B200",x"A003", -- 0050-005F 
  x"FFF8",x"E002",x"0001",x"472C",x"0000",x"0050",x"A009",x"A003",x"FFF8",x"E004",x"0001",x"473A",x"0001",x"0050",x"A009",x"A003", -- 0060-006F 
  x"FFF8",x"E006",x"0007",x"472C",x"0020",x"45D1",x"4641",x"4681",x"B300",x"468A",x"A003",x"FFF5",x"E00E",x"0006",x"4733",x"42E6", -- 0070-007F 
  x"B501",x"4299",x"42FA",x"A00A",x"A003",x"FFF6",x"E015",x"0004",x"473A",x"B501",x"3FFF",x"42C0",x"B502",x"C000",x"42AE",x"A00E", -- 0080-008F 
  x"9001",x"407E",x"4318",x"A003",x"FFF1",x"E01A",x"000B",x"4733",x"42E6",x"A00A",x"0050",x"A00A",x"9001",x"4089",x"A003",x"FFF5", -- 0090-009F 
  x"E026",x"0008",x"473A",x"46A0",x"4097",x"4318",x"4724",x"A003",x"FFF7",x"E02F",x"0002",x"4098",x"D001",x"FFFB",x"E032",x"0002", -- 00A0-00AF 
  x"4098",x"D002",x"FFFB",x"E035",x"0002",x"4098",x"D003",x"FFFB",x"E038",x"0004",x"4098",x"0040",x"FFFB",x"E03D",x"0009",x"4098", -- 00B0-00BF 
  x"0041",x"FFFB",x"E047",x"0003",x"4098",x"0042",x"FFFB",x"E04B",x"0004",x"4098",x"0048",x"FFFB",x"E050",x"0003",x"4098",x"0049", -- 00C0-00CF 
  x"FFFB",x"E054",x"0003",x"4098",x"004A",x"FFFB",x"E058",x"0003",x"4098",x"004B",x"FFFB",x"E05C",x"0003",x"4098",x"004C",x"FFFB", -- 00D0-00DF 
  x"E060",x"0003",x"4098",x"004D",x"FFFB",x"E064",x"0007",x"4098",x"004E",x"FFFB",x"E06C",x"0002",x"4098",x"004F",x"FFFB",x"E06F", -- 00E0-00EF 
  x"0004",x"4098",x"0050",x"FFFB",x"E074",x"0003",x"4098",x"0051",x"FFFB",x"E078",x"0004",x"4098",x"0052",x"FFFB",x"E07D",x"0005", -- 00F0-00FF 
  x"4098",x"0053",x"FFFB",x"E083",x"0006",x"4098",x"0054",x"FFFB",x"E08A",x"0003",x"4098",x"0055",x"FFFB",x"E08E",x"0005",x"4098", -- 0100-010F 
  x"0056",x"FFFB",x"E094",x"0009",x"4098",x"0057",x"FFFB",x"E09E",x"0007",x"4098",x"016A",x"FFFB",x"E0A6",x"0006",x"4098",x"A003", -- 0110-011F 
  x"FFFB",x"E0AD",x"0008",x"4733",x"42E6",x"0050",x"A00A",x"9003",x"A00A",x"4318",x"8001",x"4323",x"A003",x"FFF3",x"E0B6",x"0005", -- 0120-012F 
  x"473A",x"46A0",x"4123",x"4318",x"407F",x"A003",x"4318",x"4724",x"A003",x"FFF4",x"E0BC",x"0005",x"4124",x"A000",x"A003",x"FFFA", -- 0130-013F 
  x"E0C2",x"0002",x"4124",x"A001",x"A003",x"FFFA",x"E0C5",x"0002",x"4124",x"A002",x"A003",x"FFFA",x"E0C8",x"0002",x"4124",x"A00D", -- 0140-014F 
  x"A003",x"FFFA",x"E0CB",x"0002",x"4124",x"A00F",x"A003",x"FFFA",x"E0CE",x"0008",x"4124",x"A005",x"A003",x"FFFA",x"E0D7",x"0003", -- 0150-015F 
  x"4124",x"A00B",x"A003",x"FFFA",x"E0DB",x"0003",x"4124",x"A008",x"A003",x"FFFA",x"E0DF",x"0002",x"4124",x"A00E",x"A003",x"FFFA", -- 0160-016F 
  x"E0E2",x"0007",x"4124",x"A00C",x"A003",x"FFFA",x"E0EA",x"0001",x"4124",x"A007",x"A003",x"FFFA",x"E0EC",x"0001",x"4124",x"A009", -- 0170-017F 
  x"A003",x"FFFA",x"E0EE",x"0001",x"4124",x"A00A",x"A003",x"FFFA",x"E0F0",x"0004",x"4124",x"B412",x"A003",x"FFFA",x"E0F5",x"0004", -- 0180-018F 
  x"4124",x"B502",x"A003",x"FFFA",x"E0FA",x"0003",x"4124",x"B501",x"A003",x"FFFA",x"E0FE",x"0003",x"4124",x"B434",x"A003",x"FFFA", -- 0190-019F 
  x"E102",x"0004",x"4124",x"B300",x"A003",x"FFFA",x"E107",x"0005",x"4124",x"B43C",x"A003",x"FFFA",x"E10D",x"0005",x"4124",x"B60C", -- 01A0-01AF 
  x"A003",x"FFFA",x"E113",x"0004",x"4124",x"B603",x"A003",x"FFFA",x"E118",x"0005",x"4124",x"B200",x"A003",x"FFFA",x"E11E",x"0004", -- 01B0-01BF 
  x"4124",x"8000",x"A003",x"FFFA",x"E123",x"0002",x"473A",x"0053",x"A00A",x"A009",x"0001",x"0053",x"42DB",x"A003",x"FFF5",x"E126", -- 01C0-01CF 
  x"0002",x"473A",x"0053",x"A00A",x"4089",x"B501",x"4318",x"B412",x"B501",x"A00A",x"41C7",x"4299",x"B412",x"0001",x"42A0",x"B501", -- 01D0-01DF 
  x"A00D",x"9FF5",x"B200",x"0020",x"41C7",x"A003",x"FFE8",x"E129",x"0007",x"4733",x"45D1",x"0050",x"A00A",x"9003",x"41D2",x"42E6", -- 01E0-01EF 
  x"468A",x"A003",x"FFF4",x"E131",x"0005",x"473A",x"46A0",x"0001",x"0050",x"A009",x"4318",x"41E9",x"FFFF",x"0055",x"42DB",x"A003", -- 01F0-01FF 
  x"FFF2",x"E137",x"0001",x"0022",x"41EA",x"A003",x"FFFA",x"E139",x"0002",x"0022",x"41EA",x"4350",x"A003",x"FFF9",x"E13C",x"0004", -- 0200-020F 
  x"473A",x"004F",x"A00A",x"A003",x"FFF9",x"E141",x"0005",x"473A",x"0008",x"A003",x"FFFA",x"E147",x"0006",x"473A",x"0009",x"A003", -- 0210-021F 
  x"FFFA",x"E14E",x"0006",x"473A",x"1000",x"42C7",x"B412",x"0FFF",x"A008",x"A00E",x"A003",x"FFF5",x"E155",x"0005",x"473A",x"004F", -- 0220-022F 
  x"42DB",x"A003",x"FFF9",x"E15B",x"0007",x"473A",x"4211",x"4299",x"42A0",x"4218",x"4224",x"4318",x"A003",x"FFF5",x"E163",x"0008", -- 0230-023F 
  x"473A",x"4211",x"4299",x"42A0",x"421E",x"4224",x"4318",x"A003",x"FFF5",x"E16C",x"0005",x"472C",x"4211",x"A003",x"FFFA",x"E172", -- 0240-024F 
  x"0005",x"472C",x"4236",x"A003",x"FFFA",x"E178",x"0005",x"472C",x"4241",x"A003",x"FFFA",x"E17E",x"0002",x"472C",x"421E",x"0001", -- 0250-025F 
  x"422F",x"4211",x"A003",x"FFF7",x"E181",x"0006",x"472C",x"4211",x"B502",x"42A0",x"B434",x"4224",x"B412",x"0001",x"42A0",x"A009", -- 0260-026F 
  x"A003",x"FFF2",x"E188",x"0004",x"472C",x"0001",x"422F",x"4266",x"4218",x"4211",x"A003",x"FFF6",x"E18D",x"0005",x"472C",x"425D", -- 0270-027F 
  x"A003",x"FFFA",x"E193",x"0006",x"472C",x"B434",x"4251",x"4266",x"A003",x"FFF8",x"E19A",x"0002",x"473A",x"A00A",x"A003",x"FFFA", -- 0280-028F 
  x"E19D",x"0002",x"473A",x"A009",x"A003",x"FFFA",x"E1A0",x"0002",x"473A",x"0001",x"A007",x"A003",x"FFF9",x"E1A3",x"0001",x"473A", -- 0290-029F 
  x"A000",x"A007",x"A003",x"FFF9",x"E1A5",x"0001",x"473A",x"42A0",x"A00D",x"A003",x"FFF9",x"E1A7",x"0001",x"473A",x"407F",x"8000", -- 02A0-02AF 
  x"A007",x"B412",x"A00B",x"407F",x"8000",x"A007",x"0000",x"A001",x"B300",x"A00D",x"A00B",x"A003",x"FFEE",x"E1A9",x"0001",x"473A", -- 02B0-02BF 
  x"B412",x"42AE",x"A003",x"FFF9",x"E1AB",x"0001",x"473A",x"0000",x"B434",x"B434",x"A002",x"B412",x"B300",x"A003",x"FFF5",x"E1AD", -- 02C0-02CF 
  x"0003",x"473A",x"E1B1",x"0004",x"420B",x"8FFC",x"A003",x"FFF7",x"E1B6",x"0002",x"473A",x"B412",x"B502",x"A00A",x"A007",x"B412", -- 02D0-02DF 
  x"A009",x"A003",x"FFF5",x"E1B9",x"0002",x"473A",x"D002",x"A00A",x"4299",x"A00A",x"D002",x"A00A",x"A00A",x"D002",x"A00A",x"4299", -- 02E0-02EF 
  x"B501",x"D002",x"A009",x"A009",x"8000",x"A003",x"FFEC",x"E1BC",x"0002",x"473A",x"D002",x"A00A",x"A00A",x"B412",x"D002",x"A00A", -- 02F0-02FF 
  x"A009",x"FFFF",x"D002",x"A00A",x"A007",x"B501",x"D002",x"A009",x"A009",x"8000",x"A003",x"FFEB",x"E1BF",x"0001",x"473A",x"D002", -- 0300-030F 
  x"A00A",x"4299",x"A00A",x"A003",x"FFF7",x"E1C1",x"0001",x"473A",x"004F",x"A00A",x"A009",x"0001",x"004F",x"42DB",x"A003",x"FFF5", -- 0310-031F 
  x"E1C3",x"0007",x"473A",x"D003",x"A009",x"A003",x"FFF9",x"E1CB",x"0003",x"473A",x"0002",x"4323",x"A003",x"FFF9",x"E1CF",x"0004", -- 0320-032F 
  x"473A",x"015B",x"4323",x"A003",x"FFF9",x"E1D4",x"0005",x"473A",x"0000",x"B412",x"0010",x"A002",x"B412",x"A003",x"FFF6",x"E1DA", -- 0330-033F 
  x"0003",x"473A",x"B501",x"000A",x"42AE",x"9001",x"8002",x"0007",x"A007",x"0030",x"A007",x"A003",x"FFF2",x"E1DE",x"0004",x"473A", -- 0340-034F 
  x"B501",x"9009",x"B412",x"B501",x"428D",x"4331",x"4299",x"B412",x"0001",x"42A0",x"8FF5",x"B200",x"A003",x"FFEF",x"E1E3",x"0003", -- 0350-035F 
  x"473A",x"4338",x"4342",x"4331",x"4338",x"4342",x"4331",x"4338",x"4342",x"4331",x"4338",x"4342",x"4331",x"B300",x"A003",x"FFEE", -- 0360-036F 
  x"E1E7",x"0002",x"473A",x"4361",x"0020",x"4331",x"A003",x"FFF8",x"E1EA",x"0001",x"473A",x"4373",x"A003",x"FFFA",x"E1EC",x"0002", -- 0370-037F 
  x"473A",x"000A",x"4331",x"0056",x"A00A",x"9005",x"4211",x"437B",x"0053",x"A00A",x"437B",x"A003",x"FFF1",x"E1EF",x"000A",x"473A", -- 0380-038F 
  x"A003",x"FFFB",x"E1FA",x"0007",x"473A",x"4381",x"E202",x"0019",x"420B",x"0020",x"4331",x"0008",x"4331",x"432A",x"001B",x"42A7", -- 0390-039F 
  x"9FF8",x"A003",x"FFEF",x"E21C",x"0005",x"473A",x"B501",x"004E",x"A009",x"0000",x"0050",x"A009",x"4381",x"004A",x"A00A",x"004C", -- 03A0-03AF 
  x"A00A",x"004A",x"A00A",x"42A0",x"0001",x"42A0",x"4350",x"E222",x"0003",x"420B",x"E226",x"000A",x"4205",x"46B5",x"4381",x"E231", -- 03B0-03BF 
  x"0016",x"420B",x"437B",x"4395",x"4702",x"A003",x"FFDC",x"E248",x"0004",x"473A",x"D001",x"A00A",x"0055",x"A009",x"A003",x"FFF7", -- 03C0-03CF 
  x"E24D",x"0004",x"473A",x"D001",x"A00A",x"0055",x"A00A",x"42A0",x"9002",x"0009",x"43A6",x"A003",x"FFF3",x"E252",x"0005",x"473A", -- 03D0-03DF 
  x"42E6",x"B412",x"B501",x"A000",x"D002",x"A00A",x"A007",x"D002",x"A009",x"D002",x"A00A",x"0057",x"A00A",x"42FA",x"0057",x"A009", -- 03E0-03EF 
  x"42FA",x"42FA",x"A003",x"FFE9",x"E258",x"0009",x"473A",x"42E6",x"42E6",x"42E6",x"0057",x"A009",x"D002",x"A00A",x"A007",x"D002", -- 03F0-03FF 
  x"A009",x"42FA",x"A003",x"FFF0",x"E262",x"0002",x"473A",x"0057",x"A00A",x"A003",x"FFF9",x"E265",x"0002",x"473A",x"0057",x"A00A", -- 0400-040F 
  x"4299",x"A003",x"FFF8",x"E268",x"0002",x"473A",x"0057",x"A00A",x"0002",x"A007",x"A003",x"FFF7",x"E26B",x"0002",x"473A",x"0057", -- 0410-041F 
  x"A00A",x"0003",x"A007",x"A003",x"FFF7",x"E26E",x"0002",x"473A",x"0057",x"A00A",x"0004",x"A007",x"A003",x"FFF7",x"E271",x"0002", -- 0420-042F 
  x"473A",x"0057",x"A00A",x"0005",x"A007",x"A003",x"FFF7",x"E274",x"0002",x"473A",x"0057",x"A00A",x"0006",x"A007",x"A003",x"FFF7", -- 0430-043F 
  x"E277",x"0002",x"473A",x"0057",x"A00A",x"0007",x"A007",x"A003",x"FFF7",x"E27A",x"0001",x"472C",x"0020",x"45D1",x"4641",x"4681", -- 0440-044F 
  x"B300",x"4299",x"0050",x"A00A",x"9001",x"4089",x"A003",x"FFF1",x"E27C",x"0007",x"4098",x"0043",x"FFFB",x"E284",x"0007",x"4098", -- 0450-045F 
  x"0044",x"FFFB",x"E28C",x"0005",x"473A",x"B501",x"A00A",x"0001",x"A007",x"B501",x"03FF",x"A008",x"0000",x"42A7",x"9002",x"0400", -- 0460-046F 
  x"42A0",x"B412",x"A009",x"A003",x"FFED",x"E292",x"0007",x"473A",x"D000",x"A00A",x"B501",x"0008",x"42AE",x"9009",x"0008",x"A007", -- 0470-047F 
  x"A00A",x"B501",x"9002",x"B501",x"4323",x"B300",x"8012",x"0043",x"A00A",x"A009",x"0043",x"4465",x"0043",x"A00A",x"0044",x"A00A", -- 0480-048F 
  x"42A0",x"03FF",x"A008",x"0100",x"42C0",x"9003",x"0001",x"D000",x"A009",x"A003",x"FFDA",x"E29A",x"0008",x"473A",x"0044",x"A00A", -- 0490-049F 
  x"0043",x"A00A",x"42A7",x"9003",x"0000",x"0000",x"8013",x"0044",x"A00A",x"A00A",x"FFFF",x"0044",x"4465",x"0043",x"A00A",x"0044", -- 04A0-04AF 
  x"A00A",x"42A0",x"03FF",x"A008",x"0080",x"42AE",x"9003",x"0000",x"D000",x"A009",x"A003",x"FFDF",x"E2A3",x"0006",x"473A",x"0005", -- 04B0-04BF 
  x"43E0",x"4416",x"A009",x"440E",x"A009",x"440E",x"A00A",x"4428",x"A009",x"432A",x"B501",x"0014",x"42A7",x"9004",x"B300",x"440E", -- 04C0-04CF 
  x"A00A",x"428D",x"B501",x"007F",x"42A7",x"9002",x"B300",x"0008",x"B501",x"0008",x"42A7",x"9012",x"4428",x"A00A",x"440E",x"A00A", -- 04D0-04DF 
  x"42AE",x"900C",x"FFFF",x"440E",x"42DB",x"0001",x"4416",x"42DB",x"0008",x"4331",x"0020",x"4331",x"0008",x"4331",x"B501",x"0020", -- 04E0-04EF 
  x"42AE",x"9001",x"8012",x"FFFF",x"4416",x"42DB",x"4416",x"A00A",x"A00F",x"9002",x"0006",x"43A6",x"B501",x"4331",x"B501",x"440E", -- 04F0-04FF 
  x"A00A",x"4293",x"0001",x"440E",x"42DB",x"B501",x"0020",x"42AE",x"B502",x"0008",x"42A7",x"A00B",x"A008",x"B412",x"001B",x"42A7", -- 0500-050F 
  x"A00B",x"A008",x"4416",x"A00A",x"A00D",x"A00E",x"9FB2",x"0020",x"4331",x"4428",x"A00A",x"440E",x"A00A",x"4428",x"A00A",x"42A0", -- 0510-051F 
  x"B603",x"A007",x"0000",x"B412",x"4293",x"43F7",x"A003",x"FF94",x"E2AA",x"0005",x"473A",x"B501",x"0030",x"42AE",x"A00B",x"B502", -- 0520-052F 
  x"003A",x"42AE",x"A008",x"B502",x"0041",x"42AE",x"A00B",x"A00E",x"B501",x"9015",x"B412",x"0030",x"42A0",x"B501",x"000A",x"42AE", -- 0530-053F 
  x"A00B",x"9002",x"0007",x"42A0",x"B501",x"0048",x"A00A",x"42AE",x"A00B",x"9004",x"B300",x"B300",x"0000",x"0000",x"B412",x"A003", -- 0540-054F 
  x"FFD7",x"E2B0",x"0006",x"473A",x"0007",x"43E0",x"440E",x"A009",x"4407",x"A009",x"0000",x"440E",x"A00A",x"9063",x"B501",x"4416", -- 0550-055F 
  x"A009",x"0001",x"4431",x"A009",x"FFFF",x"443A",x"A009",x"4407",x"A00A",x"4416",x"A00A",x"A007",x"428D",x"002B",x"42A7",x"9009", -- 0560-056F 
  x"4416",x"A00A",x"4299",x"4416",x"A009",x"0000",x"443A",x"A009",x"8016",x"4407",x"A00A",x"4416",x"A00A",x"A007",x"428D",x"002D", -- 0570-057F 
  x"42A7",x"900D",x"4416",x"A00A",x"4299",x"4416",x"A009",x"0000",x"443A",x"A009",x"4431",x"A00A",x"A000",x"4431",x"A009",x"443A", -- 0580-058F 
  x"A00A",x"9FD2",x"4416",x"A00A",x"440E",x"A00A",x"42AE",x"9029",x"4407",x"A00A",x"4416",x"A00A",x"A007",x"428D",x"B501",x"9015", -- 0590-059F 
  x"452B",x"A00B",x"9007",x"B300",x"440E",x"A00A",x"A000",x"440E",x"A009",x"800A",x"B412",x"0048",x"A00A",x"42C7",x"A007",x"4416", -- 05A0-05AF 
  x"A00A",x"4299",x"4416",x"A009",x"8005",x"B300",x"4416",x"A00A",x"440E",x"A009",x"4416",x"A00A",x"440E",x"A00A",x"42AE",x"A00B", -- 05B0-05BF 
  x"9FD7",x"4431",x"A00A",x"A00F",x"9001",x"A000",x"4416",x"A00A",x"440E",x"A00A",x"42A0",x"43F7",x"A003",x"FF83",x"E2B7",x"0004", -- 05C0-05CF 
  x"473A",x"42FA",x"004C",x"A00A",x"004B",x"A009",x"004C",x"A00A",x"428D",x"430F",x"42A7",x"004C",x"A00A",x"004D",x"A00A",x"42AE", -- 05D0-05DF 
  x"A008",x"9004",x"0001",x"004C",x"42DB",x"8FF0",x"004C",x"A00A",x"004B",x"A009",x"004C",x"A00A",x"428D",x"430F",x"42A7",x"A00B", -- 05E0-05EF 
  x"004C",x"A00A",x"004D",x"A00A",x"42AE",x"A008",x"9004",x"0001",x"004C",x"42DB",x"8FEF",x"004B",x"A00A",x"004C",x"A00A",x"B502", -- 05F0-05FF 
  x"42A0",x"B501",x"9003",x"0001",x"004C",x"42DB",x"42E6",x"B300",x"A003",x"FFC4",x"E2BC",x"0002",x"473A",x"42FA",x"B502",x"430F", -- 0600-060F 
  x"42A0",x"9007",x"42E6",x"B300",x"B300",x"B300",x"B300",x"0000",x"8023",x"42E6",x"B300",x"B412",x"0000",x"B603",x"42A0",x"9016", -- 0610-061F 
  x"42FA",x"42FA",x"B502",x"428D",x"B502",x"428D",x"42A0",x"9004",x"B300",x"B300",x"0000",x"0000",x"B501",x"9004",x"4299",x"B412", -- 0620-062F 
  x"4299",x"B412",x"42E6",x"42E6",x"4299",x"8FE7",x"B200",x"B300",x"9002",x"FFFF",x"8001",x"0000",x"A003",x"FFCC",x"E2BF",x"0004", -- 0630-063F 
  x"473A",x"42FA",x"42FA",x"0000",x"0051",x"A00A",x"0041",x"A00A",x"9003",x"B501",x"A00A",x"A007",x"B501",x"4299",x"B501",x"A00A", -- 0640-064F 
  x"B412",x"4299",x"A00A",x"42E6",x"42E6",x"B603",x"42FA",x"42FA",x"460D",x"9003",x"B412",x"A00D",x"B412",x"B502",x"A00D",x"B502", -- 0650-065F 
  x"A00A",x"A00D",x"A00B",x"A008",x"B502",x"B501",x"A00A",x"A007",x"0051",x"A00A",x"42A7",x"A00B",x"A008",x"9004",x"B501",x"A00A", -- 0660-066F 
  x"A007",x"8FDA",x"42E6",x"B300",x"42E6",x"B434",x"A00D",x"9004",x"B300",x"B300",x"0000",x"0000",x"A003",x"FFC0",x"E2C4",x"0004", -- 0670-067F 
  x"473A",x"B412",x"0003",x"A007",x"B412",x"A003",x"FFF7",x"E2C9",x"0008",x"473A",x"0040",x"A00A",x"9003",x"407F",x"4000",x"8007", -- 0680-068F 
  x"004F",x"A00A",x"4299",x"42A0",x"0FFF",x"A008",x"3000",x"0000",x"A007",x"A007",x"4318",x"A003",x"FFEA",x"E2D2",x"0006",x"473A", -- 0690-069F 
  x"43CA",x"004F",x"A00A",x"0051",x"A00A",x"B502",x"42A0",x"4318",x"0051",x"A009",x"0020",x"45D1",x"41D2",x"0001",x"0041",x"A009", -- 06A0-06AF 
  x"A003",x"FFEB",x"E2D9",x"0009",x"473A",x"004A",x"A00A",x"42FA",x"004B",x"A00A",x"42FA",x"004C",x"A00A",x"42FA",x"004D",x"A00A", -- 06B0-06BF 
  x"42FA",x"B502",x"A007",x"004D",x"A009",x"B501",x"004A",x"A009",x"B501",x"004B",x"A009",x"004C",x"A009",x"0020",x"45D1",x"B501", -- 06C0-06CF 
  x"901F",x"B603",x"4641",x"B501",x"9009",x"42FA",x"42FA",x"B200",x"42E6",x"42E6",x"4681",x"B300",x"4323",x"8011",x"B200",x"B603", -- 06D0-06DF 
  x"4554",x"9005",x"B200",x"B300",x"0003",x"43A6",x"8008",x"B434",x"B300",x"B412",x"B300",x"0050",x"A00A",x"9001",x"4089",x"8FDD", -- 06E0-06EF 
  x"B200",x"42E6",x"004D",x"A009",x"42E6",x"004C",x"A009",x"42E6",x"004B",x"A009",x"42E6",x"004A",x"A009",x"A003",x"FFB3",x"E2E3", -- 06F0-06FF 
  x"0004",x"473A",x"0042",x"A00A",x"D002",x"A009",x"0050",x"A00A",x"A00D",x"9003",x"E2E8",x"0002",x"420B",x"4381",x"0049",x"A00A", -- 0700-070F 
  x"0100",x"44BF",x"46B5",x"8FF2",x"A003",x"FFE9",x"E2EB",x"0005",x"473A",x"E2F1",x"000B",x"420B",x"4381",x"4381",x"4702",x"A003", -- 0710-071F 
  x"FFF5",x"E2FD",x"0006",x"473A",x"0000",x"0041",x"A009",x"A003",x"FFF8",x"E304",x"000C",x"473A",x"42E6",x"42FA",x"A003",x"FFF9", -- 0720-072F 
  x"E311",x"000A",x"473A",x"42E6",x"468A",x"A003",x"FFF9",x"E31C",x"0003",x"473A",x"42E6",x"0050",x"A00A",x"9002",x"468A",x"8001", -- 0730-073F 
  x"42FA",x"A003",x"FFF4",x"E320",x"000A",x"473A",x"46A0",x"0001",x"0050",x"A009",x"472B",x"A003",x"FFF6",x"E32B",x"0008",x"473A", -- 0740-074F 
  x"46A0",x"0001",x"0050",x"A009",x"4732",x"A003",x"FFF6",x"E334",x"0001",x"473A",x"46A0",x"0001",x"0050",x"A009",x"4739",x"A003", -- 0750-075F 
  x"FFF6",x"E336",x"0001",x"472C",x"0000",x"0050",x"A009",x"43D3",x"407F",x"A003",x"4318",x"4724",x"A003",x"FFF3",x"E338",x"0005", -- 0760-076F 
  x"473A",x"4211",x"A003",x"FFFA",x"E33E",x"0003",x"473A",x"4771",x"A00A",x"9005",x"4338",x"B300",x"4338",x"B300",x"8006",x"4338", -- 0770-077F 
  x"4342",x"4331",x"4338",x"4342",x"4331",x"4338",x"4342",x"4331",x"4338",x"4342",x"4331",x"B300",x"A003",x"FFE6",x"E342",x"0003", -- 0780-078F 
  x"473A",x"E346",x"0001",x"420B",x"0022",x"4331",x"4777",x"0022",x"4331",x"E348",x"0001",x"420B",x"A003",x"FFF0",x"E34A",x"0005", -- 0790-079F 
  x"473A",x"4771",x"A009",x"E350",x"0008",x"4205",x"46B5",x"407F",x"4000",x"A007",x"0000",x"A009",x"4381",x"E359",x"0002",x"420B", -- 07A0-07AF 
  x"0000",x"B603",x"A007",x"A00A",x"4791",x"4299",x"B501",x"0010",x"42A7",x"9FF7",x"B300",x"E35C",x"0004",x"420B",x"B501",x"4361", -- 07B0-07BF 
  x"E361",x"0001",x"420B",x"B501",x"000F",x"A007",x"437B",x"0010",x"A007",x"B603",x"42A7",x"9FE0",x"B200",x"A003",x"FFCF",x"E363", -- 07C0-07CF 
  x"0001",x"473A",x"A00A",x"437B",x"A003",x"FFF9",x"E365",x"0005",x"473A",x"0000",x"0001",x"A007",x"B501",x"2D04",x"A009",x"B501", -- 07D0-07DF 
  x"0100",x"42A7",x"9FF7",x"B300",x"D004",x"A00A",x"2D04",x"A009",x"449E",x"B412",x"B300",x"9FF8",x"E36B",x"000B",x"420B",x"4381", -- 07E0-07EF 
  x"4381",x"4702",x"A003",x"0000",x"0002",x"473A",x"449E",x"B412",x"B300",x"A00D",x"9FFB",x"A003",x"FFF6",x"E371",x"0002",x"473A", -- 07F0-07FF ok
  others=>x"0000");

-- Textspeicher
type ByteRAMTYPE is array(0 to 8*1024-1) of STD_LOGIC_VECTOR (7 downto 0);
signal ByteRAM: ByteRAMTYPE:=(
  x"28",x"20",x"5B",x"20",x"5D",x"20",x"43",x"4F",x"4D",x"50",x"49",x"4C",x"45",x"20",x"28",x"4C", -- E000-E00F 
  x"49",x"54",x"2C",x"29",x"20",x"4C",x"49",x"54",x"2C",x"20",x"28",x"43",x"4F",x"4E",x"53",x"54", -- E010-E01F 
  x"41",x"4E",x"54",x"3A",x"29",x"20",x"43",x"4F",x"4E",x"53",x"54",x"41",x"4E",x"54",x"20",x"53", -- E020-E02F 
  x"50",x"20",x"52",x"50",x"20",x"50",x"43",x"20",x"52",x"42",x"49",x"54",x"20",x"53",x"4D",x"55", -- E030-E03F 
  x"44",x"47",x"45",x"42",x"49",x"54",x"20",x"52",x"50",x"30",x"20",x"42",x"41",x"53",x"45",x"20", -- E040-E04F 
  x"54",x"49",x"42",x"20",x"49",x"4E",x"31",x"20",x"49",x"4E",x"32",x"20",x"49",x"4E",x"33",x"20", -- E050-E05F 
  x"49",x"4E",x"34",x"20",x"45",x"52",x"52",x"4F",x"52",x"4E",x"52",x"20",x"44",x"50",x"20",x"53", -- E060-E06F 
  x"54",x"41",x"54",x"20",x"4C",x"46",x"41",x"20",x"42",x"41",x"4E",x"46",x"20",x"42",x"5A",x"45", -- E070-E07F 
  x"49",x"47",x"20",x"44",x"50",x"4D",x"45",x"52",x"4B",x"20",x"43",x"53",x"50",x"20",x"43",x"52", -- E080-E08F 
  x"42",x"49",x"54",x"20",x"4C",x"4F",x"43",x"41",x"4C",x"41",x"44",x"44",x"52",x"20",x"56",x"45", -- E090-E09F 
  x"52",x"53",x"49",x"4F",x"4E",x"20",x"52",x"45",x"54",x"55",x"52",x"4E",x"20",x"28",x"4D",x"43", -- E0A0-E0AF 
  x"4F",x"44",x"45",x"3A",x"29",x"20",x"4D",x"43",x"4F",x"44",x"45",x"20",x"4D",x"49",x"4E",x"55", -- E0B0-E0BF 
  x"53",x"20",x"55",x"2B",x"20",x"55",x"2A",x"20",x"30",x"3D",x"20",x"30",x"3C",x"20",x"45",x"4D", -- E0C0-E0CF 
  x"49",x"54",x"43",x"4F",x"44",x"45",x"20",x"4E",x"4F",x"54",x"20",x"41",x"4E",x"44",x"20",x"4F", -- E0D0-E0DF 
  x"52",x"20",x"4B",x"45",x"59",x"43",x"4F",x"44",x"45",x"20",x"2B",x"20",x"21",x"20",x"40",x"20", -- E0E0-E0EF 
  x"53",x"57",x"41",x"50",x"20",x"4F",x"56",x"45",x"52",x"20",x"44",x"55",x"50",x"20",x"52",x"4F", -- E0F0-E0FF 
  x"54",x"20",x"44",x"52",x"4F",x"50",x"20",x"32",x"53",x"57",x"41",x"50",x"20",x"32",x"4F",x"56", -- E100-E10F 
  x"45",x"52",x"20",x"32",x"44",x"55",x"50",x"20",x"32",x"44",x"52",x"4F",x"50",x"20",x"4E",x"4F", -- E110-E11F 
  x"4F",x"50",x"20",x"42",x"2C",x"20",x"5A",x"2C",x"20",x"28",x"57",x"4F",x"52",x"44",x"3A",x"29", -- E120-E12F 
  x"20",x"57",x"4F",x"52",x"44",x"3A",x"20",x"22",x"20",x"2E",x"22",x"20",x"48",x"45",x"52",x"45", -- E130-E13F 
  x"20",x"4A",x"52",x"42",x"49",x"54",x"20",x"4A",x"52",x"30",x"42",x"49",x"54",x"20",x"58",x"53", -- E140-E14F 
  x"45",x"54",x"42",x"54",x"20",x"41",x"4C",x"4C",x"4F",x"54",x"20",x"42",x"52",x"41",x"4E",x"43", -- E150-E15F 
  x"48",x"2C",x"20",x"30",x"42",x"52",x"41",x"4E",x"43",x"48",x"2C",x"20",x"42",x"45",x"47",x"49", -- E160-E16F 
  x"4E",x"20",x"41",x"47",x"41",x"49",x"4E",x"20",x"55",x"4E",x"54",x"49",x"4C",x"20",x"49",x"46", -- E170-E17F 
  x"20",x"45",x"4E",x"44",x"5F",x"49",x"46",x"20",x"45",x"4C",x"53",x"45",x"20",x"57",x"48",x"49", -- E180-E18F 
  x"4C",x"45",x"20",x"52",x"45",x"50",x"45",x"41",x"54",x"20",x"43",x"40",x"20",x"43",x"21",x"20", -- E190-E19F 
  x"31",x"2B",x"20",x"2D",x"20",x"3D",x"20",x"3C",x"20",x"3E",x"20",x"2A",x"20",x"42",x"59",x"45", -- E1A0-E1AF 
  x"20",x"42",x"59",x"45",x"20",x"20",x"2B",x"21",x"20",x"52",x"3E",x"20",x"3E",x"52",x"20",x"52", -- E1B0-E1BF 
  x"20",x"2C",x"20",x"45",x"58",x"45",x"43",x"55",x"54",x"45",x"20",x"4B",x"45",x"59",x"20",x"45", -- E1C0-E1CF 
  x"4D",x"49",x"54",x"20",x"53",x"48",x"4C",x"31",x"36",x"20",x"44",x"49",x"47",x"20",x"54",x"59", -- E1D0-E1DF 
  x"50",x"45",x"20",x"48",x"47",x"2E",x"20",x"48",x"2E",x"20",x"2E",x"20",x"43",x"52",x"20",x"46", -- E1E0-E1EF 
  x"45",x"48",x"4C",x"45",x"52",x"54",x"45",x"58",x"54",x"20",x"44",x"49",x"53",x"41",x"42",x"4C", -- E1F0-E1FF 
  x"45",x"20",x"77",x"65",x"69",x"74",x"65",x"72",x"20",x"6E",x"61",x"63",x"68",x"20",x"54",x"61", -- E200-E20F 
  x"73",x"74",x"65",x"20",x"45",x"53",x"43",x"41",x"50",x"45",x"20",x"20",x"45",x"52",x"52",x"4F", -- E210-E21F 
  x"52",x"20",x"3F",x"3F",x"3F",x"20",x"46",x"45",x"48",x"4C",x"45",x"52",x"54",x"45",x"58",x"54", -- E220-E22F 
  x"20",x"45",x"52",x"52",x"4F",x"52",x"20",x"2D",x"20",x"46",x"65",x"68",x"6C",x"65",x"72",x"20", -- E230-E23F 
  x"4E",x"75",x"6D",x"6D",x"65",x"72",x"20",x"20",x"43",x"53",x"50",x"21",x"20",x"43",x"53",x"50", -- E240-E24F 
  x"3F",x"20",x"4C",x"4F",x"43",x"41",x"4C",x"20",x"45",x"4E",x"44",x"5F",x"4C",x"4F",x"43",x"41", -- E250-E25F 
  x"4C",x"20",x"4C",x"30",x"20",x"4C",x"31",x"20",x"4C",x"32",x"20",x"4C",x"33",x"20",x"4C",x"34", -- E260-E26F 
  x"20",x"4C",x"35",x"20",x"4C",x"36",x"20",x"4C",x"37",x"20",x"27",x"20",x"49",x"52",x"41",x"4D", -- E270-E27F 
  x"41",x"44",x"52",x"20",x"4A",x"52",x"41",x"4D",x"41",x"44",x"52",x"20",x"49",x"4E",x"43",x"52", -- E280-E28F 
  x"34",x"20",x"4B",x"45",x"59",x"5F",x"49",x"4E",x"54",x"20",x"4B",x"45",x"59",x"43",x"4F",x"44", -- E290-E29F 
  x"45",x"32",x"20",x"45",x"58",x"50",x"45",x"43",x"54",x"20",x"44",x"49",x"47",x"49",x"54",x"20", -- E2A0-E2AF 
  x"4E",x"55",x"4D",x"42",x"45",x"52",x"20",x"57",x"4F",x"52",x"44",x"20",x"5A",x"3D",x"20",x"46", -- E2B0-E2BF 
  x"49",x"4E",x"44",x"20",x"4C",x"43",x"46",x"41",x"20",x"43",x"4F",x"4D",x"50",x"49",x"4C",x"45", -- E2C0-E2CF 
  x"2C",x"20",x"43",x"52",x"45",x"41",x"54",x"45",x"20",x"49",x"4E",x"54",x"45",x"52",x"50",x"52", -- E2D0-E2DF 
  x"45",x"54",x"20",x"51",x"55",x"49",x"54",x"20",x"6F",x"6B",x"20",x"53",x"54",x"41",x"52",x"54", -- E2E0-E2EF 
  x"20",x"46",x"4F",x"52",x"54",x"59",x"2D",x"46",x"4F",x"52",x"54",x"48",x"20",x"53",x"4D",x"55", -- E2F0-E2FF 
  x"44",x"47",x"45",x"20",x"28",x"49",x"4D",x"4D",x"45",x"44",x"49",x"41",x"54",x"45",x"3A",x"29", -- E300-E30F 
  x"20",x"28",x"43",x"4F",x"4D",x"50",x"49",x"4C",x"45",x"3A",x"29",x"20",x"28",x"3A",x"29",x"20", -- E310-E31F 
  x"49",x"4D",x"4D",x"45",x"44",x"49",x"41",x"54",x"45",x"3A",x"20",x"43",x"4F",x"4D",x"50",x"49", -- E320-E32F 
  x"4C",x"45",x"3A",x"20",x"3A",x"20",x"3B",x"20",x"44",x"55",x"42",x"49",x"54",x"20",x"4C",x"47", -- E330-E33F 
  x"2E",x"20",x"4E",x"47",x"2E",x"20",x"78",x"20",x"2C",x"20",x"44",x"55",x"4D",x"50",x"5A",x"20", -- E340-E34F 
  x"27",x"20",x"53",x"54",x"41",x"52",x"54",x"20",x"20",x"20",x"20",x"20",x"20",x"2D",x"2D",x"20", -- E350-E35F 
  x"20",x"2D",x"20",x"3F",x"20",x"53",x"54",x"41",x"52",x"54",x"20",x"46",x"4F",x"52",x"54",x"59", -- E360-E36F 
  x"2D",x"46",x"4F",x"52",x"54",x"48",x"20",x"52",x"54",x"20",x"46",x"4F",x"52",x"54",x"59",x"2D", -- E370-E37F 
  x"46",x"4F",x"52",x"54",x"48",x"20",x"4C",x"4F",x"4F",x"50",x"20",x"52",x"41",x"4D",x"50",x"31", -- E380-E38F 
  x"20",x"56",x"41",x"52",x"49",x"41",x"42",x"4C",x"45",x"20",x"52",x"41",x"4D",x"50",x"33",x"20", -- E390-E39F 
  x"52",x"41",x"4D",x"42",x"55",x"46",x"20",x"44",x"55",x"4D",x"50",x"20",x"56",x"4C",x"49",x"53", -- E3A0-E3AF 
  x"54",x"20",x"57",x"4C",x"49",x"53",x"54",x"20",x"52",x"45",x"54",x"55",x"52",x"4E",x"20",x"52", -- E3B0-E3BF 
  x"45",x"50",x"4C",x"41",x"43",x"45",x"3A",x"20",x"46",x"4F",x"52",x"47",x"45",x"54",x"20",x"6E", -- E3C0-E3CF 
  x"69",x"63",x"68",x"74",x"20",x"67",x"65",x"66",x"75",x"6E",x"64",x"65",x"6E",x"20",x"20",x"4D", -- E3D0-E3DF 
  x"4F",x"56",x"45",x"20",x"46",x"49",x"4C",x"4C",x"20",x"4C",x"44",x"55",x"4D",x"50",x"20",x"46", -- E3E0-E3EF 
  x"45",x"48",x"4C",x"45",x"52",x"54",x"45",x"58",x"54",x"20",x"44",x"69",x"76",x"69",x"73",x"69", -- E3F0-E3FF
  others=>x"00");

-- Rückkehrstapel
type stapRAMTYPE is array(0 to 1024-1) of STD_LOGIC_VECTOR (15 downto 0);
shared variable stapR: stapRAMTYPE:=(
  others=>x"0000");

--diese Funktion übernimmt von SP nur die beiden niedrigsten Bits
  function P(SP : integer) return integer is begin
--    return CONV_INTEGER(CONV_UNSIGNED(SP,2));
    return SP mod 4;
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
-- kompletten Speicher anschliessen
signal PC_ZUM_ProgRAM,PD_VOM_ProgRAM: STD_LOGIC_VECTOR (15 downto 0);
signal STORE_ZUM_RAM,EXFET,ADRESSE_ZUM_RAM: STD_LOGIC_VECTOR (15 downto 0);
signal FETCH_VOM_ProgRAM,FETCH_VOM_ByteRAM,FETCH_VOM_stapR: STD_LOGIC_VECTOR (15 downto 0);
signal WE_ZUM_RAM,WE_ZUM_ProgRAM,WE_ZUM_ByteRAM,WE_ZUM_stapR: STD_LOGIC;
-- fuer EMIT-Ausgabe
signal EMIT_GESENDET_LOCAL,EMIT_EMPFANGEN_RUHEND,XOFF_INPUT_L: STD_LOGIC:='0';
signal KEY_EMPFANGEN_LOCAL,KEY_GESENDET_RUHEND: STD_LOGIC:='0';
signal KEY_BYTE_RUHEND: STD_LOGIC_VECTOR (7 downto 0);


begin

process begin wait until (CLK_I'event and CLK_I='1'); --ruhende Eingangsdaten für FortyForthprocessor
  EMIT_EMPFANGEN_RUHEND<=EMIT_EMPFANGEN;
  KEY_BYTE_RUHEND<=KEY_BYTE;
  KEY_GESENDET_RUHEND<=KEY_GESENDET;
  end process;
  

process -- FortyForthProcessor
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

begin wait until (CLK_I'event and CLK_I='0'); PC_SIM<=PC;--Simulation
  -- ob ein KEY aingetroffen ist --
  if KEY_EMPFANGEN_LOCAL/=KEY_GESENDET_RUHEND then 
    KEY_EMPFANGEN_LOCAL<=KEY_GESENDET_RUHEND;
    PD:=x"4016";
    PC:=PC;
    else
      PD:=PD_VOM_ProgRAM;
      PC:=PC+1;
      end if;                                           -- Simulation --
  WE:='0';                                              PD_SIM<=PD;
  DIST:=PD(11)&PD(11)&PD(11)&PD(11)&PD(11 downto 0);    SP_SIM<=SP;
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
    elsif PD=x"A005" then -- EMIT Zeichen ausgeben
      if (EMIT_GESENDET_LOCAL=EMIT_EMPFANGEN_RUHEND) and XOFF_INPUT_L='0' then
        EMIT_BYTE<=A(7 downto 0);
        EMIT_GESENDET_LOCAL<=not EMIT_EMPFANGEN_RUHEND;
        T:=0;
        SP:=SP-1;
        else PC:=PC-1; end if; -- warten
    elsif PD=x"A009" then -- STORE Speicheradresse beschreiben
      case A is
        when x"D001" => SP:=CONV_INTEGER(B);
        when x"D002" => RP<=B;
        when x"D003" => PC:=B;
        when others => ADR:=A;DAT:=B;WE:='1' ;
        end case;
      T:=0;
      SP:=SP-2;
    elsif PD=x"A00A" then -- FETCH Speicheradresse lesen
      case A is
        when x"D000" => A:=x"00"&KEY_BYTE_RUHEND;
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
  -- ADR, DAT, WE, PC
  if WE='1' then ADRESSE_ZUM_RAM<=ADR; else ADRESSE_ZUM_RAM<=R(P(SP-1)); end if;
  STORE_ZUM_RAM<=DAT;
  WE_ZUM_RAM<=WE;
  PC_ZUM_ProgRAM<=PC;
  end process;

ADR_O<=ADRESSE_ZUM_RAM;
DAT_O<=STORE_ZUM_RAM;
WE_O<=WE_ZUM_RAM;
EMIT_GESENDET<=EMIT_GESENDET_LOCAL;

-- hier werden die Lesedaten der unterschiedlichen Speicher zusammengefuehrt
EXFET<=FETCH_VOM_ProgRAM when ADRESSE_ZUM_RAM(15 downto 13)="000" else
       FETCH_VOM_stapR when ADRESSE_ZUM_RAM(15 downto 10)="001011" else
       x"00"&FETCH_VOM_ByteRAM(7 downto 0) when ADRESSE_ZUM_RAM(15 downto 13)="111" else
       DAT_I;

-- hier wird WE auf die unterschiedlichen Speicher aufgeteilt
WE_ZUM_ProgRAM<=WE_ZUM_RAM when ADRESSE_ZUM_RAM(15 downto 13)="000" else '0';
WE_ZUM_stapR  <=WE_ZUM_RAM when ADRESSE_ZUM_RAM(15 downto 10)="001011" else '0';
WE_ZUM_ByteRAM<=WE_ZUM_RAM when ADRESSE_ZUM_RAM(15 downto 13)="111" else '0';


process -- Programmspeicher 0000H-1FFFH,
begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_ProgRAM='1' then 
    ProgRAM(CONV_INTEGER(ADRESSE_ZUM_RAM(12 downto 0)))<=STORE_ZUM_RAM; 
    FETCH_VOM_ProgRAM<=STORE_ZUM_RAM; 
	  else
      FETCH_VOM_ProgRAM<=ProgRAM(CONV_INTEGER(ADRESSE_ZUM_RAM(12 downto 0)));
      end if;
  PD_VOM_ProgRAM<=ProgRAM(CONV_INTEGER(PC_ZUM_ProgRAM(12 downto 0)));
  end process;

process -- Textspeicher E000H-FFFFH
begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_ByteRAM='1' then 
    ByteRAM(CONV_INTEGER(ADRESSE_ZUM_RAM(12 downto 0)))<=STORE_ZUM_RAM(7 downto 0); 
    FETCH_VOM_ByteRAM<=STORE_ZUM_RAM; 
	 else
      FETCH_VOM_ByteRAM<=x"00"&ByteRAM(CONV_INTEGER(ADRESSE_ZUM_RAM(12 downto 0)));
      end if;
  end process;

process --Rueckkehrstapel, TRUE_DUAL_PORT
begin wait until (CLK_I'event and CLK_I='1');
  if WE_ZUM_StapR='1' then 
    stapR(CONV_INTEGER(ADRESSE_ZUM_RAM(7 downto 0))):=STORE_ZUM_RAM; 
    end if;
  FETCH_VOM_stapR<=stapR(CONV_INTEGER(ADRESSE_ZUM_RAM(7 downto 0)));
  end process;
process begin wait until (CLK_I'event and CLK_I='1');
  if RW='1' then
    stapR(CONV_INTEGER(RP(7 downto 0))):=RPC;
    RPCC<=RPC;
     else
      RPCC<=stapR(CONV_INTEGER(RP(7 downto 0)));
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

end Step_9;
