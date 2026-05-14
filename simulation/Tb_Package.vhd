--*****************************************************************************************
-- Testbench Package
-- Common procedures for AXI4-Lite master transactions
--*****************************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Tb_Package is
    procedure AxiWrite (
        signal Clk        : in  std_logic;
        signal AwValid    : out std_logic;
        signal AwAddr     : out std_logic_vector(31 downto 0);
        signal AwReady    : in  std_logic;
        signal WValid     : out std_logic;
        signal WData      : out std_logic_vector(31 downto 0);
        signal WStrb      : out std_logic_vector(3 downto 0);
        signal WReady     : in  std_logic;
        signal BValid     : in  std_logic;
        signal BResp      : in  std_logic_vector(1 downto 0);
        signal BReady     : out std_logic;
        constant Address  : in  std_logic_vector(31 downto 0);
        constant Data     : in  std_logic_vector(31 downto 0)
    );

    procedure AxiRead (
        signal Clk        : in  std_logic;
        signal ArValid    : out std_logic;
        signal ArAddr     : out std_logic_vector(31 downto 0);
        signal ArReady    : in  std_logic;
        signal RValid     : in  std_logic;
        signal RData      : in  std_logic_vector(31 downto 0);
        signal RResp      : in  std_logic_vector(1 downto 0);
        signal RReady     : out std_logic;
        constant Address  : in  std_logic_vector(31 downto 0);
        variable Data     : out std_logic_vector(31 downto 0)
    );
end package Tb_Package;

package body Tb_Package is

    procedure AxiWrite (
        signal Clk        : in  std_logic;
        signal AwValid    : out std_logic;
        signal AwAddr     : out std_logic_vector(31 downto 0);
        signal AwReady    : in  std_logic;
        signal WValid     : out std_logic;
        signal WData      : out std_logic_vector(31 downto 0);
        signal WStrb      : out std_logic_vector(3 downto 0);
        signal WReady     : in  std_logic;
        signal BValid     : in  std_logic;
        signal BResp      : in  std_logic_vector(1 downto 0);
        signal BReady     : out std_logic;
        constant Address  : in  std_logic_vector(31 downto 0);
        constant Data     : in  std_logic_vector(31 downto 0)
    ) is
    begin
        AwAddr  <= Address;
        AwValid <= '1';
        WData   <= Data;
        WStrb   <= x"F";
        WValid  <= '1';
        BReady  <= '0';

        wait until rising_edge(Clk);
        while AwReady = '0' or WReady = '0' loop
            if AwReady = '1' then AwValid <= '0'; end if;
            if WReady  = '1' then WValid  <= '0'; end if;
            wait until rising_edge(Clk);
        end loop;
        AwValid <= '0';
        WValid  <= '0';

        wait until rising_edge(Clk) and BValid = '1';
        BReady <= '1';
        wait until rising_edge(Clk);
        BReady <= '0';
    end procedure;

    procedure AxiRead (
        signal Clk        : in  std_logic;
        signal ArValid    : out std_logic;
        signal ArAddr     : out std_logic_vector(31 downto 0);
        signal ArReady    : in  std_logic;
        signal RValid     : in  std_logic;
        signal RData      : in  std_logic_vector(31 downto 0);
        signal RResp      : in  std_logic_vector(1 downto 0);
        signal RReady     : out std_logic;
        constant Address  : in  std_logic_vector(31 downto 0);
        variable Data     : out std_logic_vector(31 downto 0)
    ) is
    begin
        ArAddr  <= Address;
        ArValid <= '1';
        RReady  <= '0';

        wait until rising_edge(Clk);
        while ArReady = '0' loop
            wait until rising_edge(Clk);
        end loop;
        ArValid <= '0';

        wait until rising_edge(Clk) and RValid = '1';
        Data := RData;
        RReady <= '1';
        wait until rising_edge(Clk);
        RReady <= '0';
    end procedure;

end package body Tb_Package;
