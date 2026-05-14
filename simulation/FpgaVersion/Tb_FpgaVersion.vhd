--*****************************************************************************************
-- Testbench: FpgaVersion
--*****************************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library TimecardLib;
use TimecardLib.Timecard_Package.all;

library work;
use work.Tb_Package.all;

entity Tb_FpgaVersion is
end entity Tb_FpgaVersion;

architecture sim of Tb_FpgaVersion is
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz

    signal Clk          : std_logic := '0';
    signal RstN         : std_logic := '0';
    signal GoldenImageN : std_logic := '1';

    -- AXI Write
    signal AwValid      : std_logic := '0';
    signal AwReady      : std_logic;
    signal AwAddr       : std_logic_vector(11 downto 0) := (others => '0');
    signal AwProt       : std_logic_vector(2 downto 0) := (others => '0');
    signal WValid       : std_logic := '0';
    signal WReady       : std_logic;
    signal WData        : std_logic_vector(31 downto 0) := (others => '0');
    signal WStrb        : std_logic_vector(3 downto 0) := (others => '0');
    signal BValid       : std_logic;
    signal BResp        : std_logic_vector(1 downto 0);
    signal BReady       : std_logic := '0';

    -- AXI Read
    signal ArValid      : std_logic := '0';
    signal ArReady      : std_logic;
    signal ArAddr       : std_logic_vector(11 downto 0) := (others => '0');
    signal ArProt       : std_logic_vector(2 downto 0) := (others => '0');
    signal RValid       : std_logic;
    signal RData        : std_logic_vector(31 downto 0);
    signal RResp        : std_logic_vector(1 downto 0);
    signal RReady       : std_logic := '0';

    signal ReadData     : std_logic_vector(31 downto 0);
    signal TestDone     : boolean := false;
begin

    Clk <= not Clk after CLK_PERIOD / 2 when not TestDone;

    DUT: entity work.FpgaVersion
        generic map (
            VersionNumber_Gen        => x"0003",
            VersionNumber_Golden_Gen => x"0001"
        )
        port map (
            SysClk_ClkIn                => Clk,
            SysRstN_RstIn               => RstN,
            GoldenImageN_EnaIn          => GoldenImageN,
            AxiWriteAddrValid_ValIn     => AwValid,
            AxiWriteAddrReady_RdyOut    => AwReady,
            AxiWriteAddrAddress_AdrIn   => AwAddr,
            AxiWriteAddrProt_DatIn      => AwProt,
            AxiWriteDataValid_ValIn     => WValid,
            AxiWriteDataReady_RdyOut    => WReady,
            AxiWriteDataData_DatIn      => WData,
            AxiWriteDataStrobe_DatIn    => WStrb,
            AxiWriteRespValid_ValOut    => BValid,
            AxiWriteRespReady_RdyIn     => BReady,
            AxiWriteRespResponse_DatOut => BResp,
            AxiReadAddrValid_ValIn      => ArValid,
            AxiReadAddrReady_RdyOut     => ArReady,
            AxiReadAddrAddress_AdrIn    => ArAddr,
            AxiReadAddrProt_DatIn       => ArProt,
            AxiReadDataValid_ValOut     => RValid,
            AxiReadDataReady_RdyIn      => RReady,
            AxiReadDataResponse_DatOut  => RResp,
            AxiReadDataData_DatOut      => RData
        );

    StimProc: process
    begin
        -- Reset
        RstN <= '0';
        wait for 10 * CLK_PERIOD;
        RstN <= '1';
        wait for 2 * CLK_PERIOD;

        -- Test 1: Read version in normal mode (GoldenImageN = '1')
        report "Test 1: Read version (normal image)";
        GoldenImageN <= '1';
        AxiRead(Clk, ArValid, std_logic_vector(resize(unsigned(ArAddr), 32)), ArReady,
                RValid, RData, RResp, RReady, x"00000000", ReadData);
        assert ReadData = x"00010003"
            report "Version mismatch in normal mode! Expected 0x00010003, got " & integer'image(to_integer(unsigned(ReadData)))
            severity error;

        wait for 5 * CLK_PERIOD;

        -- Test 2: Read version in golden mode
        report "Test 2: Read version (golden image)";
        GoldenImageN <= '0';
        wait for 2 * CLK_PERIOD; -- allow combinatorial update
        AxiRead(Clk, ArValid, std_logic_vector(resize(unsigned(ArAddr), 32)), ArReady,
                RValid, RData, RResp, RReady, x"00000000", ReadData);
        assert ReadData = x"00010000"
            report "Version mismatch in golden mode! Expected 0x00010000, got " & integer'image(to_integer(unsigned(ReadData)))
            severity error;

        -- Test 3: Write attempt to read-only register should return SLVERR
        report "Test 3: Write to read-only register (expect SLVERR)";
        AxiWrite(Clk, AwValid, std_logic_vector(resize(unsigned(AwAddr), 32)), AwReady,
                 WValid, WData, WStrb, WReady, BValid, BResp, BReady, x"00000000", x"DEADBEEF");
        assert BResp = "10"
            report "Expected SLVERR (10) on write to RO register, got " & integer'image(to_integer(unsigned(BResp)))
            severity error;

        report "All tests passed!";
        TestDone <= true;
        wait;
    end process;

end architecture sim;
