library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- COMPONENTE: DEBOUNCER (elimina bounce do botão físico, realiza o tratamento de ruído)

entity debouncer is
    generic(
        COUNT_MAX : integer := 2_500_000  -- ~50ms a 50 MHz
    );
    port(
        clk      : in  std_logic;
        btn_in   : in  std_logic;  -- ativo em LOW
        btn_stable : out std_logic -- ainda ativo em LOW
    );
end entity;

architecture rtl_deb of debouncer is
    signal counter : unsigned(31 downto 0) := (others => '0');
    signal sync    : std_logic := '1';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_in = sync then
                counter <= (others => '0');
            else
                if counter < COUNT_MAX then
                    counter <= counter + 1;
                else
                    sync <= btn_in;
                end if;
            end if;
        end if;
    end process;

    btn_stable <= sync;
end architecture;