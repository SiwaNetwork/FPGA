--*****************************************************************************************
-- Testbench: PpsGenerator
-- Smoke test: verify PPS pulse generation aligned to second rollover.
--*****************************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library TimecardLib;
use TimecardLib.Timecard_Package.all;

library work;
use work.Tb_Package.all;

entity Tb_PpsGenerator is
end entity Tb_PpsGenerator;

architecture sim of Tb_PpsGenerator is
    constant CLK_PERIOD    : time := 20 ns;  -- 50 MHz
    constant CLK_NX_PERIOD : time := 4 ns;   -- 250 MHz (5x)

    signal Clk             : std_logic := '0';
    signal ClkNx           : std_logic := '0';
    signal RstN            : std_logic := '0';

    signal ClockTime_Sec   : std_logic_vector(31 downto 0) := (others => '0');
    signal ClockTime_Nsec  : std_logic_vector(31 downto 0) := (others => '0');
    signal ClockTime_Jump  : std_logic := '0';
    signal ClockTime_Val   : std_logic := '1';

    signal Pps_Evt         : std_logic;

    -- AXI
    signal AwValid         : std_logic := '0';
    signal AwReady         : std_logic;
    signal AwAddr          : std_logic_vector(15 downto 0) := (others => '0');
    signal AwProt          : std_logic_vector(2 downto 0) := (others => '0');
    signal WValid          : std_logic := '0';
    signal WReady          : std_logic;
    signal WData           : std_logic_vector(31 downto 0) := (others => '0');
    signal WStrb           : std_logic_vector(3 downto 0) := (others => '0');
    signal BValid          : std_logic;
    signal BResp           : std_logic_vector(1 downto 0);
    signal BReady          : std_logic := '0';

    signal ArValid         : std_logic := '0';
    signal ArReady         : std_logic;
    signal ArAddr          : std_logic_vector(15 downto 0) := (others => '0');
    signal ArProt          : std_logic_vector(2 downto 0) := (others => '0');
    signal RValid          : std_logic;
    signal RData           : std_logic_vector(31 downto 0);
    signal RResp           : std_logic_vector(1 downto 0);
    signal RReady          : std_logic := '0';

    signal TestDone        : boolean := false;
    signal PpsDetected     : boolean := false;
begin

    Clk   <= not Clk   after CLK_PERIOD / 2 when not TestDone;
    ClkNx <= not ClkNx after CLK_NX_PERIOD / 2 when not TestDone;

    DUT: entity work.PpsGenerator
        generic map (
            ClockPeriod_Gen         => 20,
            OutputPolarity_Gen      => true,
            HighResFreqMultiply_Gen => 5,
            Sim_Gen                 => true
        )
        port map (
            SysClk_ClkIn                => Clk,
            SysClkNx_ClkIn              => ClkNx,
            SysRstN_RstIn               => RstN,
            ClockTime_Second_DatIn      => ClockTime_Sec,
            ClockTime_Nanosecond_DatIn  => ClockTime_Nsec,
            ClockTime_TimeJump_DatIn    => ClockTime_Jump,
            ClockTime_ValIn             => ClockTime_Val,
            Pps_EvtOut                  => Pps_Evt,
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

    -- Time counter: increment nanoseconds by 20 every clock
    TimeProc: process(Clk)
    begin
        if rising_edge(Clk) then
            if RstN = '0' then
                ClockTime_Sec  <= (others => '0');
                ClockTime_Nsec <= (others => '0');
            else
                if unsigned(ClockTime_Nsec) >= 1000000000 - 20 then
                    ClockTime_Nsec <= (others => '0');
                    ClockTime_Sec  <= std_logic_vector(unsigned(ClockTime_Sec) + 1);
                else
                    ClockTime_Nsec <= std_logic_vector(unsigned(ClockTime_Nsec) + 20);
                end if;
            end if;
        end if;
    end process;

    -- Detect PPS rising edge
    PpsDetect: process(Clk)
        variable PpsOld : std_logic := '0';
    begin
        if rising_edge(Clk) then
            PpsOld := Pps_Evt;
            if Pps_Evt = '1' and PpsOld = '0' then
                PpsDetected <= true;
            end if;
        end if;
    end process;

    StimProc: process
        variable RdData : std_logic_vector(31 downto 0);
    begin
        -- Reset
        RstN <= '0';
        wait for 10 * CLK_PERIOD;
        RstN <= '1';
        wait for 2 * CLK_PERIOD;

        -- Enable PPS Generator via AXI (Control register @ 0x00, bit 0 = 1)
        report "Enable PPS Generator";
        AxiWrite(Clk, AwValid, std_logic_vector(resize(unsigned(AwAddr), 32)), AwReady,
                 WValid, WData, WStrb, WReady, BValid, BResp, BReady,
                 x"00000000", x"00000001");

        -- Set polarity high via AXI (Polarity register @ 0x08, bit 0 = 1)
        report "Set PPS polarity high";
        AxiWrite(Clk, AwValid, std_logic_vector(resize(unsigned(AwAddr), 32)), AwReady,
                 WValid, WData, WStrb, WReady, BValid, BResp, BReady,
                 x"00000008", x"00000001");

        -- Wait for at least one full second (1.1s ~ 55M cycles @ 20ns)
        report "Wait for PPS pulse...";
        PpsDetected <= false;
        wait for 1100 ms;

        assert PpsDetected
            report "PPS pulse was not detected within 1.1 seconds!"
            severity error;

        -- Read version register as sanity check
        AxiRead(Clk, ArValid, std_logic_vector(resize(unsigned(ArAddr), 32)), ArReady,
                RValid, RData, RResp, RReady, x"0000000C", RdData);
        report "PPS Generator Version = 0x" & integer'image(to_integer(unsigned(RdData)));

        report "PpsGenerator smoke test passed!";
        TestDone <= true;
        wait;
    end process;

end architecture sim;
