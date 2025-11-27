library ieee;
use ieee.std_logic_1164.all;

-- COMPONENTE: EDGE DETECTOR (detecta borda de DESCIDA)

entity edge_detector is
    port(
        clk       : in  std_logic;
        signal_in : in  std_logic; -- sinal jÃ¡ debounced
        pulse_out : out std_logic  -- pulso de 1 clock
    );
end entity;

architecture rtl_edge of edge_detector is
    signal sig_in_d : std_logic := '0';       -- versão atrasada do sinal
    signal counter  : integer range 0 to 3 := 0;
begin
    process(clk)
    begin

        if rising_edge(clk) then
            -- detecta borda de subida
            if signal_in = '1' and sig_in_d = '0' then
                counter <= 3;  -- inicia pulso de 3 ciclos
            elsif counter > 0 then
                counter <= counter - 1;
            end if;

            -- saída ativa enquanto contador > 0
            if counter > 0 then
                pulse_out <= '1';
            else
                pulse_out <= '0';
            end if;

            -- atualiza versão atrasada do sinal
            sig_in_d <= signal_in;
        end if;
    end process;


  --  pulse_out <= '1' when (prev = '1' and signal_in = '0') else '0';
end architecture;
