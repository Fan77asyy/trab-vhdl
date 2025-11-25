library ieee;
use ieee.std_logic_1164.all;

-- REGISTRADOR 3 BITS

entity reg3 is
    port(
        clk  : in  std_logic;
        load : in  std_logic;
        din  : in  std_logic_vector(2 downto 0);
        dout : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl_reg3 of reg3 is
    signal data : std_logic_vector(2 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                data <= din;
            end if;
        end if;
    end process;
    dout <= data;
end architecture;