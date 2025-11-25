library ieee;
use ieee.std_logic_1164.all;

-- COMPONENTE: EDGE DETECTOR (detecta borda de DESCIDA)

entity edge_detector is
    port(
        clk      : in  std_logic;
        signal_in : in  std_logic; -- sinal já debounced
        pulse_out : out std_logic  -- pulso de 1 clock
    );
end entity;

architecture rtl_edge of edge_detector is
    signal prev : std_logic := '1';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            prev <= signal_in;
        end if;
    end process;

    pulse_out <= '1' when (prev = '1' and signal_in = '0') else '0';
end architecture;