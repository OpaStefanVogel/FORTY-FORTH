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
    EMIT_ABGESCHICKT: out STD_LOGIC;
    EMIT_BYTE: out STD_LOGIC_VECTOR (7 downto 0);
    EMIT_ANGEKOMMEN: in STD_LOGIC;
    
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
x"4010",x"0000",x"0000",x"0000",x"0000",x"0000",x"8000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000", -- 0000-000F 
x"473E",x"A003",x"44B4",x"9001",x"A003",x"B300",x"8000",x"8FFA",x"0000",x"1164",x"0000",x"0000",x"0000",x"0000",x"1159",x"114F", -- 0010-001F 
x"528B",x"A003",x"528B",x"A003",x"4000",x"A003",x"4485",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003", -- 0020-002F 
x"4000",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003",x"4000",x"A003", -- 0030-003F 
x"3F00",x"0000",x"3000",x"FC99",x"FC99",x"0000",x"0000",x"0000",x"0010",x"FB00",x"FB00",x"FB09",x"FB0F",x"FB0E",x"0000",x"07F1", -- 0040-004F 
x"0000",x"07C2",x"E000",x"E369",x"0058",x"0001",x"0000",x"2FEF",x"0000",x"E000",x"0001",x"4751",x"0029",x"45EC",x"B200",x"A003", -- 0050-005F 
x"FFF8",x"E002",x"0001",x"4751",x"0000",x"0050",x"A009",x"A003",x"FFF8",x"E004",x"0001",x"475F",x"0001",x"0050",x"A009",x"A003", -- 0060-006F 
x"FFF8",x"E006",x"0007",x"4751",x"0020",x"45EC",x"4666",x"46A6",x"B300",x"46AF",x"A003",x"FFF5",x"E00E",x"0006",x"4758",x"42E6", -- 0070-007F 
x"B501",x"4299",x"42F9",x"A00A",x"A003",x"FFF6",x"E015",x"0004",x"475F",x"B501",x"3FFF",x"42C0",x"B502",x"C000",x"42AE",x"A00E", -- 0080-008F 
x"9001",x"407E",x"4319",x"A003",x"FFF1",x"E01A",x"000B",x"4758",x"42E6",x"A00A",x"0050",x"A00A",x"9001",x"4089",x"A003",x"FFF5", -- 0090-009F 
x"E026",x"0008",x"475F",x"46C5",x"4097",x"4319",x"4749",x"A003",x"FFF7",x"E02F",x"0002",x"4098",x"D001",x"FFFB",x"E032",x"0002", -- 00A0-00AF 
x"4098",x"D002",x"FFFB",x"E035",x"0002",x"4098",x"D003",x"FFFB",x"E038",x"0004",x"4098",x"0040",x"FFFB",x"E03D",x"0009",x"4098", -- 00B0-00BF 
x"0041",x"FFFB",x"E047",x"0003",x"4098",x"0042",x"FFFB",x"E04B",x"0004",x"4098",x"0048",x"FFFB",x"E050",x"0003",x"4098",x"0049", -- 00C0-00CF 
x"FFFB",x"E054",x"0003",x"4098",x"004A",x"FFFB",x"E058",x"0003",x"4098",x"004B",x"FFFB",x"E05C",x"0003",x"4098",x"004C",x"FFFB", -- 00D0-00DF 
x"E060",x"0003",x"4098",x"004D",x"FFFB",x"E064",x"0007",x"4098",x"004E",x"FFFB",x"E06C",x"0002",x"4098",x"004F",x"FFFB",x"E06F", -- 00E0-00EF 
x"0004",x"4098",x"0050",x"FFFB",x"E074",x"0003",x"4098",x"0051",x"FFFB",x"E078",x"0004",x"4098",x"0052",x"FFFB",x"E07D",x"0005", -- 00F0-00FF 
x"4098",x"0053",x"FFFB",x"E083",x"0006",x"4098",x"0054",x"FFFB",x"E08A",x"0003",x"4098",x"0055",x"FFFB",x"E08E",x"0005",x"4098", -- 0100-010F 
x"0056",x"FFFB",x"E094",x"0009",x"4098",x"0057",x"FFFB",x"E09E",x"0007",x"4098",x"018A",x"FFFB",x"E0A6",x"0006",x"4098",x"A003", -- 0110-011F 
x"FFFB",x"E0AD",x"0008",x"4758",x"42E6",x"0050",x"A00A",x"9003",x"A00A",x"4319",x"8001",x"4324",x"A003",x"FFF3",x"E0B6",x"0005", -- 0120-012F 
x"475F",x"46C5",x"4123",x"4319",x"407F",x"A003",x"4319",x"4749",x"A003",x"FFF4",x"E0BC",x"0005",x"4124",x"A000",x"A003",x"FFFA", -- 0130-013F 
x"E0C2",x"0002",x"4124",x"A001",x"A003",x"FFFA",x"E0C5",x"0002",x"4124",x"A002",x"A003",x"FFFA",x"E0C8",x"0002",x"4124",x"A00D", -- 0140-014F 
x"A003",x"FFFA",x"E0CB",x"0003",x"4124",x"A00F",x"A003",x"FFFA",x"E0CF",x"0008",x"4124",x"A005",x"A003",x"FFFA",x"E0D8",x"0003", -- 0150-015F 
x"4124",x"A00B",x"A003",x"FFFA",x"E0DC",x"0003",x"4124",x"A008",x"A003",x"FFFA",x"E0E0",x"0002",x"4124",x"A00E",x"A003",x"FFFA", -- 0160-016F 
x"E0E3",x"0007",x"4124",x"A00C",x"A003",x"FFFA",x"E0EB",x"0001",x"4124",x"A007",x"A003",x"FFFA",x"E0ED",x"0001",x"4124",x"A009", -- 0170-017F 
x"A003",x"FFFA",x"E0EF",x"0001",x"4124",x"A00A",x"A003",x"FFFA",x"E0F1",x"0004",x"4124",x"B412",x"A003",x"FFFA",x"E0F6",x"0004", -- 0180-018F 
x"4124",x"B502",x"A003",x"FFFA",x"E0FB",x"0003",x"4124",x"B501",x"A003",x"FFFA",x"E0FF",x"0003",x"4124",x"B434",x"A003",x"FFFA", -- 0190-019F 
x"E103",x"0004",x"4124",x"B300",x"A003",x"FFFA",x"E108",x"0005",x"4124",x"B43C",x"A003",x"FFFA",x"E10E",x"0005",x"4124",x"B60C", -- 01A0-01AF 
x"A003",x"FFFA",x"E114",x"0004",x"4124",x"B603",x"A003",x"FFFA",x"E119",x"0005",x"4124",x"B200",x"A003",x"FFFA",x"E11F",x"0004", -- 01B0-01BF 
x"4124",x"8000",x"A003",x"FFFA",x"E124",x"0002",x"475F",x"0053",x"A00A",x"A009",x"0001",x"0053",x"42DB",x"A003",x"FFF5",x"E127", -- 01C0-01CF 
x"0002",x"475F",x"0053",x"A00A",x"4089",x"B501",x"4319",x"B412",x"B501",x"A00A",x"41C7",x"4299",x"B412",x"0001",x"42A0",x"B501", -- 01D0-01DF 
x"A00D",x"9FF5",x"B200",x"0020",x"41C7",x"A003",x"FFE8",x"E12A",x"0007",x"4758",x"45EC",x"0050",x"A00A",x"9003",x"41D2",x"42E6", -- 01E0-01EF 
x"46AF",x"A003",x"FFF4",x"E132",x"0005",x"475F",x"46C5",x"0001",x"0050",x"A009",x"4319",x"41E9",x"FFFF",x"0055",x"42DB",x"A003", -- 01F0-01FF 
x"FFF2",x"E138",x"0001",x"0022",x"41EA",x"A003",x"FFFA",x"E13A",x"0002",x"0022",x"41EA",x"4351",x"A003",x"FFF9",x"E13D",x"0004", -- 0200-020F 
x"475F",x"004F",x"A00A",x"A003",x"FFF9",x"E142",x"0005",x"475F",x"0008",x"A003",x"FFFA",x"E148",x"0006",x"475F",x"0009",x"A003", -- 0210-021F 
x"FFFA",x"E14F",x"0006",x"475F",x"1000",x"42C7",x"B412",x"0FFF",x"A008",x"A00E",x"A003",x"FFF5",x"E156",x"0005",x"475F",x"004F", -- 0220-022F 
x"42DB",x"A003",x"FFF9",x"E15C",x"0007",x"475F",x"4211",x"4299",x"42A0",x"4218",x"4224",x"4319",x"A003",x"FFF5",x"E164",x"0008", -- 0230-023F 
x"475F",x"4211",x"4299",x"42A0",x"421E",x"4224",x"4319",x"A003",x"FFF5",x"E16D",x"0005",x"4751",x"4211",x"A003",x"FFFA",x"E173", -- 0240-024F 
x"0005",x"4751",x"4236",x"A003",x"FFFA",x"E179",x"0005",x"4751",x"4241",x"A003",x"FFFA",x"E17F",x"0002",x"4751",x"421E",x"0001", -- 0250-025F 
x"422F",x"4211",x"A003",x"FFF7",x"E182",x"0006",x"4751",x"4211",x"B502",x"42A0",x"B434",x"4224",x"B412",x"0001",x"42A0",x"A009", -- 0260-026F 
x"A003",x"FFF2",x"E189",x"0004",x"4751",x"0001",x"422F",x"4266",x"4218",x"4211",x"A003",x"FFF6",x"E18E",x"0005",x"4751",x"425D", -- 0270-027F 
x"A003",x"FFFA",x"E194",x"0006",x"4751",x"B434",x"4251",x"4266",x"A003",x"FFF8",x"E19B",x"0002",x"475F",x"A00A",x"A003",x"FFFA", -- 0280-028F 
x"E19E",x"0002",x"475F",x"A009",x"A003",x"FFFA",x"E1A1",x"0002",x"475F",x"0001",x"A007",x"A003",x"FFF9",x"E1A4",x"0001",x"475F", -- 0290-029F 
x"A000",x"A007",x"A003",x"FFF9",x"E1A6",x"0001",x"475F",x"42A0",x"A00D",x"A003",x"FFF9",x"E1A8",x"0002",x"475F",x"407F",x"8000", -- 02A0-02AF 
x"A007",x"B412",x"A00B",x"407F",x"8000",x"A007",x"0000",x"A001",x"B300",x"A00D",x"A00B",x"A003",x"FFEE",x"E1AB",x"0001",x"475F", -- 02B0-02BF 
x"B412",x"42AE",x"A003",x"FFF9",x"E1AD",x"0001",x"475F",x"0000",x"B434",x"B434",x"A002",x"B412",x"B300",x"A003",x"FFF5",x"E1AF", -- 02C0-02CF 
x"0003",x"475F",x"E1B3",x"0004",x"420B",x"8FFC",x"A003",x"FFF7",x"E1B8",x"0002",x"475F",x"B412",x"B502",x"A00A",x"A007",x"B412", -- 02D0-02DF 
x"A009",x"A003",x"FFF5",x"E1BB",x"0002",x"475F",x"D002",x"A00A",x"4299",x"A00A",x"D002",x"A00A",x"4299",x"D002",x"B603",x"A00A", -- 02E0-02EF 
x"A00A",x"B412",x"A009",x"A009",x"A003",x"FFED",x"E1BE",x"0002",x"475F",x"D002",x"A00A",x"B501",x"FFFF",x"A007",x"D002",x"B603", -- 02F0-02FF 
x"A00A",x"A00A",x"B412",x"B501",x"FFFF",x"A007",x"D002",x"A009",x"A009",x"A009",x"A009",x"A003",x"FFE9",x"E1C1",x"0001",x"475F", -- 0300-030F 
x"D002",x"A00A",x"4299",x"A00A",x"A003",x"FFF7",x"E1C3",x"0001",x"475F",x"004F",x"A00A",x"A009",x"0001",x"004F",x"42DB",x"A003", -- 0310-031F 
x"FFF5",x"E1C5",x"0007",x"475F",x"D003",x"A009",x"A003",x"FFF9",x"E1CD",x"0003",x"475F",x"0012",x"4324",x"A003",x"FFF9",x"E1D1", -- 0320-032F 
x"0004",x"475F",x"015B",x"4324",x"A003",x"FFF9",x"E1D6",x"0005",x"475F",x"0000",x"B412",x"0010",x"A002",x"B412",x"A003",x"FFF6", -- 0330-033F 
x"E1DC",x"0003",x"475F",x"B501",x"000A",x"42AE",x"9001",x"8002",x"0007",x"A007",x"0030",x"A007",x"A003",x"FFF2",x"E1E0",x"0004", -- 0340-034F 
x"475F",x"B501",x"9009",x"B412",x"B501",x"428D",x"4332",x"4299",x"B412",x"0001",x"42A0",x"8FF5",x"B200",x"A003",x"FFEF",x"E1E5", -- 0350-035F 
x"0003",x"475F",x"4339",x"4343",x"4332",x"4339",x"4343",x"4332",x"4339",x"4343",x"4332",x"4339",x"4343",x"4332",x"B300",x"A003", -- 0360-036F 
x"FFEE",x"E1E9",x"0002",x"475F",x"4362",x"0020",x"4332",x"A003",x"FFF8",x"E1EC",x"0001",x"475F",x"4374",x"A003",x"FFFA",x"E1EE", -- 0370-037F 
x"0001",x"475F",x"A00A",x"437C",x"A003",x"FFF9",x"E1F0",x"0002",x"475F",x"000A",x"4332",x"0056",x"A00A",x"9005",x"4211",x"437C", -- 0380-038F 
x"0053",x"A00A",x"437C",x"A003",x"FFF1",x"E1F3",x"000A",x"475F",x"A003",x"FFFB",x"E1FE",x"0007",x"475F",x"4389",x"E206",x"0019", -- 0390-039F 
x"420B",x"0020",x"4332",x"0008",x"4332",x"432B",x"001B",x"42A7",x"9FF8",x"A003",x"FFEF",x"E220",x"0005",x"475F",x"B501",x"004E", -- 03A0-03AF 
x"A009",x"0000",x"0050",x"A009",x"4389",x"004A",x"A00A",x"004C",x"A00A",x"004A",x"A00A",x"42A0",x"0001",x"42A0",x"4351",x"E226", -- 03B0-03BF 
x"0003",x"420B",x"E22A",x"000A",x"4205",x"46DA",x"4389",x"E235",x"0016",x"420B",x"437C",x"439D",x"4727",x"A003",x"FFDC",x"E24C", -- 03C0-03CF 
x"0004",x"475F",x"D001",x"A00A",x"0055",x"A009",x"A003",x"FFF7",x"E251",x"0004",x"475F",x"D001",x"A00A",x"0055",x"A00A",x"42A0", -- 03D0-03DF 
x"9002",x"0009",x"43AE",x"A003",x"FFF3",x"E256",x"0005",x"475F",x"42E6",x"B412",x"B501",x"A000",x"D002",x"A00A",x"A007",x"D002", -- 03E0-03EF 
x"A009",x"D002",x"A00A",x"0057",x"A00A",x"42F9",x"0057",x"A009",x"42F9",x"42F9",x"A003",x"FFE9",x"E25C",x"0009",x"475F",x"42E6", -- 03F0-03FF 
x"42E6",x"42E6",x"0057",x"A009",x"D002",x"A00A",x"A007",x"D002",x"A009",x"42F9",x"A003",x"FFF0",x"E266",x"0002",x"475F",x"0057", -- 0400-040F 
x"A00A",x"A003",x"FFF9",x"E269",x"0002",x"475F",x"0057",x"A00A",x"4299",x"A003",x"FFF8",x"E26C",x"0002",x"475F",x"0057",x"A00A", -- 0410-041F 
x"0002",x"A007",x"A003",x"FFF7",x"E26F",x"0002",x"475F",x"0057",x"A00A",x"0003",x"A007",x"A003",x"FFF7",x"E272",x"0002",x"475F", -- 0420-042F 
x"0057",x"A00A",x"0004",x"A007",x"A003",x"FFF7",x"E275",x"0002",x"475F",x"0057",x"A00A",x"0005",x"A007",x"A003",x"FFF7",x"E278", -- 0430-043F 
x"0002",x"475F",x"0057",x"A00A",x"0006",x"A007",x"A003",x"FFF7",x"E27B",x"0002",x"475F",x"0057",x"A00A",x"0007",x"A007",x"A003", -- 0440-044F 
x"FFF7",x"E27E",x"0001",x"4751",x"0020",x"45EC",x"4666",x"46A6",x"B300",x"4299",x"0050",x"A00A",x"9001",x"4089",x"A003",x"FFF1", -- 0450-045F 
x"E280",x"0007",x"4098",x"0043",x"FFFB",x"E288",x"0007",x"4098",x"0044",x"FFFB",x"E290",x"0004",x"4098",x"0045",x"FFFB",x"E295", -- 0460-046F 
x"0005",x"475F",x"B501",x"A00A",x"0001",x"A007",x"B501",x"03FF",x"A008",x"0000",x"42A7",x"9002",x"0400",x"42A0",x"B412",x"A009", -- 0470-047F 
x"A003",x"FFED",x"E29B",x"0007",x"475F",x"D000",x"A00A",x"B501",x"0008",x"42AE",x"9009",x"0018",x"A007",x"A00A",x"B501",x"9002", -- 0480-048F 
x"B501",x"4324",x"B300",x"8018",x"0043",x"A00A",x"A009",x"0043",x"4472",x"0043",x"A00A",x"0044",x"A00A",x"42A0",x"03FF",x"A008", -- 0490-049F 
x"0100",x"42C0",x"9009",x"0045",x"A00A",x"A00D",x"9005",x"FFFF",x"0045",x"A009",x"0013",x"4332",x"0000",x"D000",x"A009",x"A003", -- 04A0-04AF 
x"FFD1",x"E2A3",x"0008",x"475F",x"0044",x"A00A",x"0043",x"A00A",x"42A7",x"9003",x"0000",x"0000",x"8018",x"0044",x"A00A",x"A00A", -- 04B0-04BF 
x"FFFF",x"0044",x"4472",x"0043",x"A00A",x"0044",x"A00A",x"42A0",x"03FF",x"A008",x"0080",x"42AE",x"9008",x"0045",x"A00A",x"9005", -- 04C0-04CF 
x"0000",x"0045",x"A009",x"0011",x"4332",x"A003",x"FFDA",x"E2AC",x"0006",x"475F",x"0005",x"43E8",x"441E",x"A009",x"4416",x"A009", -- 04D0-04DF 
x"4416",x"A00A",x"4430",x"A009",x"432B",x"B501",x"0014",x"42A7",x"9004",x"B300",x"4416",x"A00A",x"428D",x"B501",x"007F",x"42A7", -- 04E0-04EF 
x"9002",x"B300",x"0008",x"B501",x"0008",x"42A7",x"9012",x"4430",x"A00A",x"4416",x"A00A",x"42AE",x"900C",x"FFFF",x"4416",x"42DB", -- 04F0-04FF 
x"0001",x"441E",x"42DB",x"0008",x"4332",x"0020",x"4332",x"0008",x"4332",x"B501",x"0020",x"42AE",x"9001",x"8012",x"FFFF",x"441E", -- 0500-050F 
x"42DB",x"441E",x"A00A",x"A00F",x"9002",x"0006",x"43AE",x"B501",x"4332",x"B501",x"4416",x"A00A",x"4293",x"0001",x"4416",x"42DB", -- 0510-051F 
x"B501",x"0020",x"42AE",x"B502",x"0008",x"42A7",x"A00B",x"A008",x"B412",x"001B",x"42A7",x"A00B",x"A008",x"441E",x"A00A",x"A00D", -- 0520-052F 
x"A00E",x"9FB2",x"0020",x"4332",x"4430",x"A00A",x"4416",x"A00A",x"4430",x"A00A",x"42A0",x"B603",x"A007",x"0000",x"B412",x"4293", -- 0530-053F 
x"43FF",x"A003",x"FF94",x"E2B3",x"0005",x"475F",x"B501",x"0030",x"42AE",x"A00B",x"B502",x"003A",x"42AE",x"A008",x"B502",x"0041", -- 0540-054F 
x"42AE",x"A00B",x"A00E",x"B501",x"9015",x"B412",x"0030",x"42A0",x"B501",x"000A",x"42AE",x"A00B",x"9002",x"0007",x"42A0",x"B501", -- 0550-055F 
x"0048",x"A00A",x"42AE",x"A00B",x"9004",x"B300",x"B300",x"0000",x"0000",x"B412",x"A003",x"FFD7",x"E2B9",x"0006",x"475F",x"0007", -- 0560-056F 
x"43E8",x"4416",x"A009",x"440F",x"A009",x"0000",x"4416",x"A00A",x"9063",x"B501",x"441E",x"A009",x"0001",x"4439",x"A009",x"FFFF", -- 0570-057F 
x"4442",x"A009",x"440F",x"A00A",x"441E",x"A00A",x"A007",x"428D",x"002B",x"42A7",x"9009",x"441E",x"A00A",x"4299",x"441E",x"A009", -- 0580-058F 
x"0000",x"4442",x"A009",x"8016",x"440F",x"A00A",x"441E",x"A00A",x"A007",x"428D",x"002D",x"42A7",x"900D",x"441E",x"A00A",x"4299", -- 0590-059F 
x"441E",x"A009",x"0000",x"4442",x"A009",x"4439",x"A00A",x"A000",x"4439",x"A009",x"4442",x"A00A",x"9FD2",x"441E",x"A00A",x"4416", -- 05A0-05AF 
x"A00A",x"42AE",x"9029",x"440F",x"A00A",x"441E",x"A00A",x"A007",x"428D",x"B501",x"9015",x"4546",x"A00B",x"9007",x"B300",x"4416", -- 05B0-05BF 
x"A00A",x"A000",x"4416",x"A009",x"800A",x"B412",x"0048",x"A00A",x"42C7",x"A007",x"441E",x"A00A",x"4299",x"441E",x"A009",x"8005", -- 05C0-05CF 
x"B300",x"441E",x"A00A",x"4416",x"A009",x"441E",x"A00A",x"4416",x"A00A",x"42AE",x"A00B",x"9FD7",x"4439",x"A00A",x"A00F",x"9001", -- 05D0-05DF 
x"A000",x"441E",x"A00A",x"4416",x"A00A",x"42A0",x"43FF",x"A003",x"FF83",x"E2C0",x"0004",x"475F",x"42F9",x"004C",x"A00A",x"004B", -- 05E0-05EF 
x"A009",x"004C",x"A00A",x"428D",x"4310",x"42A7",x"004C",x"A00A",x"004D",x"A00A",x"42AE",x"A008",x"9004",x"0001",x"004C",x"42DB", -- 05F0-05FF 
x"8FF0",x"004C",x"A00A",x"004B",x"A009",x"004C",x"A00A",x"428D",x"003C",x"42A7",x"9004",x"004C",x"A00A",x"004D",x"A009",x"004C", -- 0600-060F 
x"A00A",x"428D",x"4310",x"42A7",x"A00B",x"004C",x"A00A",x"004D",x"A00A",x"42AE",x"A008",x"9004",x"0001",x"004C",x"42DB",x"8FE5", -- 0610-061F 
x"004B",x"A00A",x"004C",x"A00A",x"B502",x"42A0",x"B501",x"9003",x"0001",x"004C",x"42DB",x"42E6",x"B300",x"A003",x"FFBA",x"E2C5", -- 0620-062F 
x"0002",x"475F",x"42F9",x"B502",x"4310",x"42A0",x"9007",x"42E6",x"B300",x"B300",x"B300",x"B300",x"0000",x"8023",x"42E6",x"B300", -- 0630-063F 
x"B412",x"0000",x"B603",x"42A0",x"9016",x"42F9",x"42F9",x"B502",x"428D",x"B502",x"428D",x"42A0",x"9004",x"B300",x"B300",x"0000", -- 0640-064F 
x"0000",x"B501",x"9004",x"4299",x"B412",x"4299",x"B412",x"42E6",x"42E6",x"4299",x"8FE7",x"B200",x"B300",x"9002",x"FFFF",x"8001", -- 0650-065F 
x"0000",x"A003",x"FFCC",x"E2C8",x"0004",x"475F",x"42F9",x"42F9",x"0000",x"0051",x"A00A",x"0041",x"A00A",x"9003",x"B501",x"A00A", -- 0660-066F 
x"A007",x"B501",x"4299",x"B501",x"A00A",x"B412",x"4299",x"A00A",x"42E6",x"42E6",x"B603",x"42F9",x"42F9",x"4632",x"9003",x"B412", -- 0670-067F 
x"A00D",x"B412",x"B502",x"A00D",x"B502",x"A00A",x"A00D",x"A00B",x"A008",x"B502",x"B501",x"A00A",x"A007",x"0051",x"A00A",x"42A7", -- 0680-068F 
x"A00B",x"A008",x"9004",x"B501",x"A00A",x"A007",x"8FDA",x"42E6",x"B300",x"42E6",x"B434",x"A00D",x"9004",x"B300",x"B300",x"0000", -- 0690-069F 
x"0000",x"A003",x"FFC0",x"E2CD",x"0004",x"475F",x"B412",x"0003",x"A007",x"B412",x"A003",x"FFF7",x"E2D2",x"0008",x"475F",x"0040", -- 06A0-06AF 
x"A00A",x"9003",x"407F",x"4000",x"8007",x"004F",x"A00A",x"4299",x"42A0",x"0FFF",x"A008",x"3000",x"0000",x"A007",x"A007",x"4319", -- 06B0-06BF 
x"A003",x"FFEA",x"E2DB",x"0006",x"475F",x"43D2",x"004F",x"A00A",x"0051",x"A00A",x"B502",x"42A0",x"4319",x"0051",x"A009",x"0020", -- 06C0-06CF 
x"45EC",x"41D2",x"0001",x"0041",x"A009",x"A003",x"FFEB",x"E2E2",x"0009",x"475F",x"004A",x"A00A",x"42F9",x"004B",x"A00A",x"42F9", -- 06D0-06DF 
x"004C",x"A00A",x"42F9",x"004D",x"A00A",x"42F9",x"B502",x"A007",x"004D",x"A009",x"B501",x"004A",x"A009",x"B501",x"004B",x"A009", -- 06E0-06EF 
x"004C",x"A009",x"0020",x"45EC",x"B501",x"901F",x"B603",x"4666",x"B501",x"9009",x"42F9",x"42F9",x"B200",x"42E6",x"42E6",x"46A6", -- 06F0-06FF 
x"B300",x"4324",x"8011",x"B200",x"B603",x"456F",x"9005",x"B200",x"B300",x"0003",x"43AE",x"8008",x"B434",x"B300",x"B412",x"B300", -- 0700-070F 
x"0050",x"A00A",x"9001",x"4089",x"8FDD",x"B200",x"42E6",x"004D",x"A009",x"42E6",x"004C",x"A009",x"42E6",x"004B",x"A009",x"42E6", -- 0710-071F 
x"004A",x"A009",x"A003",x"FFB3",x"E2EC",x"0004",x"475F",x"0042",x"A00A",x"D002",x"A009",x"0050",x"A00A",x"A00D",x"9003",x"E2F1", -- 0720-072F 
x"0002",x"420B",x"4389",x"0049",x"A00A",x"0100",x"44DA",x"46DA",x"8FF2",x"A003",x"FFE9",x"E2F4",x"0005",x"475F",x"E2FA",x"000B", -- 0730-073F 
x"420B",x"4389",x"4389",x"4727",x"A003",x"FFF5",x"E306",x"0006",x"475F",x"0000",x"0041",x"A009",x"A003",x"FFF8",x"E30D",x"000C", -- 0740-074F 
x"475F",x"42E6",x"42F9",x"A003",x"FFF9",x"E31A",x"000A",x"475F",x"42E6",x"46AF",x"A003",x"FFF9",x"E325",x"0003",x"475F",x"42E6", -- 0750-075F 
x"0050",x"A00A",x"9002",x"46AF",x"8001",x"42F9",x"A003",x"FFF4",x"E329",x"000A",x"475F",x"46C5",x"0001",x"0050",x"A009",x"4750", -- 0760-076F 
x"A003",x"FFF6",x"E334",x"0008",x"475F",x"46C5",x"0001",x"0050",x"A009",x"4757",x"A003",x"FFF6",x"E33D",x"0001",x"475F",x"46C5", -- 0770-077F 
x"0001",x"0050",x"A009",x"475E",x"A003",x"FFF6",x"E33F",x"0001",x"4751",x"0000",x"0050",x"A009",x"43DB",x"407F",x"A003",x"4319", -- 0780-078F 
x"4749",x"A003",x"FFF3",x"E341",x"0005",x"475F",x"4211",x"A003",x"FFFA",x"E347",x"0003",x"475F",x"4796",x"A00A",x"9005",x"4339", -- 0790-079F 
x"B300",x"4339",x"B300",x"8006",x"4339",x"4343",x"4332",x"4339",x"4343",x"4332",x"4339",x"4343",x"4332",x"4339",x"4343",x"4332", -- 07A0-07AF 
x"B300",x"A003",x"FFE6",x"E34B",x"0003",x"475F",x"E34F",x"0001",x"420B",x"0022",x"4332",x"479C",x"0022",x"4332",x"E351",x"0001", -- 07B0-07BF 
x"420B",x"A003",x"FFF0",x"E353",x"0005",x"475F",x"4796",x"A009",x"E359",x"0008",x"4205",x"46DA",x"407F",x"4000",x"A007",x"0010", -- 07C0-07CF 
x"A009",x"4389",x"0000",x"B603",x"A007",x"A00A",x"47B6",x"4299",x"B501",x"0010",x"42A7",x"9FF7",x"B300",x"E362",x"0004",x"420B", -- 07D0-07DF 
x"B501",x"4362",x"E367",x"0001",x"420B",x"B501",x"000F",x"A007",x"437C",x"0010",x"A007",x"B603",x"42C0",x"A00B",x"9FE2",x"B200", -- 07E0-07EF 
x"A003",x"0000",x"2F00",x"A009",x"A009",x"A003",x"FFF2",x"E377",x"0005",x"4098",x"2F01",x"FFFB",x"E37D",x"0006",x"474E",x"A000", -- 07F0-07FF ok
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
x"53",x"20",x"55",x"2B",x"20",x"55",x"2A",x"20",x"30",x"3D",x"20",x"30",x"4C",x"54",x"20",x"45", -- E0C0-E0CF 
x"4D",x"49",x"54",x"43",x"4F",x"44",x"45",x"20",x"4E",x"4F",x"54",x"20",x"41",x"4E",x"44",x"20", -- E0D0-E0DF 
x"4F",x"52",x"20",x"4B",x"45",x"59",x"43",x"4F",x"44",x"45",x"20",x"2B",x"20",x"21",x"20",x"40", -- E0E0-E0EF 
x"20",x"53",x"57",x"41",x"50",x"20",x"4F",x"56",x"45",x"52",x"20",x"44",x"55",x"50",x"20",x"52", -- E0F0-E0FF 
x"4F",x"54",x"20",x"44",x"52",x"4F",x"50",x"20",x"32",x"53",x"57",x"41",x"50",x"20",x"32",x"4F", -- E100-E10F 
x"56",x"45",x"52",x"20",x"32",x"44",x"55",x"50",x"20",x"32",x"44",x"52",x"4F",x"50",x"20",x"4E", -- E110-E11F 
x"4F",x"4F",x"50",x"20",x"42",x"2C",x"20",x"5A",x"2C",x"20",x"28",x"57",x"4F",x"52",x"44",x"3A", -- E120-E12F 
x"29",x"20",x"57",x"4F",x"52",x"44",x"3A",x"20",x"22",x"20",x"2E",x"22",x"20",x"48",x"45",x"52", -- E130-E13F 
x"45",x"20",x"4A",x"52",x"42",x"49",x"54",x"20",x"4A",x"52",x"30",x"42",x"49",x"54",x"20",x"58", -- E140-E14F 
x"53",x"45",x"54",x"42",x"54",x"20",x"41",x"4C",x"4C",x"4F",x"54",x"20",x"42",x"52",x"41",x"4E", -- E150-E15F 
x"43",x"48",x"2C",x"20",x"30",x"42",x"52",x"41",x"4E",x"43",x"48",x"2C",x"20",x"42",x"45",x"47", -- E160-E16F 
x"49",x"4E",x"20",x"41",x"47",x"41",x"49",x"4E",x"20",x"55",x"4E",x"54",x"49",x"4C",x"20",x"49", -- E170-E17F 
x"46",x"20",x"45",x"4E",x"44",x"5F",x"49",x"46",x"20",x"45",x"4C",x"53",x"45",x"20",x"57",x"48", -- E180-E18F 
x"49",x"4C",x"45",x"20",x"52",x"45",x"50",x"45",x"41",x"54",x"20",x"43",x"40",x"20",x"43",x"21", -- E190-E19F 
x"20",x"31",x"2B",x"20",x"2D",x"20",x"3D",x"20",x"4C",x"54",x"20",x"3E",x"20",x"2A",x"20",x"42", -- E1A0-E1AF 
x"59",x"45",x"20",x"42",x"59",x"45",x"20",x"20",x"2B",x"21",x"20",x"52",x"3E",x"20",x"3E",x"52", -- E1B0-E1BF 
x"20",x"52",x"20",x"2C",x"20",x"45",x"58",x"45",x"43",x"55",x"54",x"45",x"20",x"4B",x"45",x"59", -- E1C0-E1CF 
x"20",x"45",x"4D",x"49",x"54",x"20",x"53",x"48",x"4C",x"31",x"36",x"20",x"44",x"49",x"47",x"20", -- E1D0-E1DF 
x"54",x"59",x"50",x"45",x"20",x"48",x"47",x"2E",x"20",x"48",x"2E",x"20",x"2E",x"20",x"3F",x"20", -- E1E0-E1EF 
x"43",x"52",x"20",x"46",x"45",x"48",x"4C",x"45",x"52",x"54",x"45",x"58",x"54",x"20",x"44",x"49", -- E1F0-E1FF 
x"53",x"41",x"42",x"4C",x"45",x"20",x"77",x"65",x"69",x"74",x"65",x"72",x"20",x"6E",x"61",x"63", -- E200-E20F 
x"68",x"20",x"54",x"61",x"73",x"74",x"65",x"20",x"45",x"53",x"43",x"41",x"50",x"45",x"20",x"20", -- E210-E21F 
x"45",x"52",x"52",x"4F",x"52",x"20",x"3F",x"3F",x"3F",x"20",x"46",x"45",x"48",x"4C",x"45",x"52", -- E220-E22F 
x"54",x"45",x"58",x"54",x"20",x"45",x"52",x"52",x"4F",x"52",x"20",x"2D",x"20",x"46",x"65",x"68", -- E230-E23F 
x"6C",x"65",x"72",x"20",x"4E",x"75",x"6D",x"6D",x"65",x"72",x"20",x"20",x"43",x"53",x"50",x"21", -- E240-E24F 
x"20",x"43",x"53",x"50",x"3F",x"20",x"4C",x"4F",x"43",x"41",x"4C",x"20",x"45",x"4E",x"44",x"5F", -- E250-E25F 
x"4C",x"4F",x"43",x"41",x"4C",x"20",x"4C",x"30",x"20",x"4C",x"31",x"20",x"4C",x"32",x"20",x"4C", -- E260-E26F 
x"33",x"20",x"4C",x"34",x"20",x"4C",x"35",x"20",x"4C",x"36",x"20",x"4C",x"37",x"20",x"27",x"20", -- E270-E27F 
x"49",x"52",x"41",x"4D",x"41",x"44",x"52",x"20",x"4A",x"52",x"41",x"4D",x"41",x"44",x"52",x"20", -- E280-E28F 
x"58",x"4F",x"46",x"46",x"20",x"49",x"4E",x"43",x"52",x"34",x"20",x"4B",x"45",x"59",x"5F",x"49", -- E290-E29F 
x"4E",x"54",x"20",x"4B",x"45",x"59",x"43",x"4F",x"44",x"45",x"32",x"20",x"45",x"58",x"50",x"45", -- E2A0-E2AF 
x"43",x"54",x"20",x"44",x"49",x"47",x"49",x"54",x"20",x"4E",x"55",x"4D",x"42",x"45",x"52",x"20", -- E2B0-E2BF 
x"57",x"4F",x"52",x"44",x"20",x"5A",x"3D",x"20",x"46",x"49",x"4E",x"44",x"20",x"4C",x"43",x"46", -- E2C0-E2CF 
x"41",x"20",x"43",x"4F",x"4D",x"50",x"49",x"4C",x"45",x"2C",x"20",x"43",x"52",x"45",x"41",x"54", -- E2D0-E2DF 
x"45",x"20",x"49",x"4E",x"54",x"45",x"52",x"50",x"52",x"45",x"54",x"20",x"51",x"55",x"49",x"54", -- E2E0-E2EF 
x"20",x"6F",x"6B",x"20",x"53",x"54",x"41",x"52",x"54",x"20",x"46",x"4F",x"52",x"54",x"59",x"2D", -- E2F0-E2FF 
x"46",x"4F",x"52",x"54",x"48",x"20",x"53",x"4D",x"55",x"44",x"47",x"45",x"20",x"28",x"49",x"4D", -- E300-E30F 
x"4D",x"45",x"44",x"49",x"41",x"54",x"45",x"3A",x"29",x"20",x"28",x"43",x"4F",x"4D",x"50",x"49", -- E310-E31F 
x"4C",x"45",x"3A",x"29",x"20",x"28",x"3A",x"29",x"20",x"49",x"4D",x"4D",x"45",x"44",x"49",x"41", -- E320-E32F 
x"54",x"45",x"3A",x"20",x"43",x"4F",x"4D",x"50",x"49",x"4C",x"45",x"3A",x"20",x"3A",x"20",x"3B", -- E330-E33F 
x"20",x"44",x"55",x"42",x"49",x"54",x"20",x"4C",x"47",x"2E",x"20",x"4E",x"47",x"2E",x"20",x"78", -- E340-E34F 
x"20",x"2C",x"20",x"44",x"55",x"4D",x"50",x"5A",x"20",x"27",x"20",x"53",x"54",x"41",x"52",x"54", -- E350-E35F 
x"20",x"20",x"20",x"2D",x"2D",x"20",x"20",x"2D",x"20",x"54",x"20",x"30",x"4C",x"54",x"20",x"41", -- E360-E36F ok
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
signal EMIT_ABGESCHICKT_LOCAL,EMIT_ANGEKOMMEN_RUHEND,XOFF_INPUT_L: STD_LOGIC:='0';


begin

process begin wait until (CLK_I'event and CLK_I='1'); --ruhende Eingangsdaten für FortyForthprocessor
  EMIT_ANGEKOMMEN_RUHEND<=EMIT_ANGEKOMMEN;
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
    elsif PD=x"A005" then -- EMIT Zeichen ausgeben
      if (EMIT_ABGESCHICKT_LOCAL=EMIT_ANGEKOMMEN_RUHEND) and XOFF_INPUT_L='0' then
        EMIT_BYTE<=A(7 downto 0);
        EMIT_ABGESCHICKT_LOCAL<=not EMIT_ANGEKOMMEN_RUHEND;
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
EMIT_ABGESCHICKT<=EMIT_ABGESCHICKT_LOCAL;

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
