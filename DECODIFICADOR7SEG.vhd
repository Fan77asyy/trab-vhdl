library ieee;
use ieee.std_logic_1164.all;

-- DECODIFICADOR 7 SEGMENTOS (S: 0 / 1 / 2)

entity decod7seg is
    port(
        code : in  std_logic_vector(1 downto 0);
        hex  : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl_dec of decod7seg is
begin
    -- 7-seg : ativo em 0:
    -- 0 = 1000000 (Nenhum acerto)
    -- 1 = 1111001 (50% certo)
    -- 2 = 0100100 (100% certo)
    
    with code select
        hex <= "1000000" when "00", -- 0
               "1111001" when "01", -- 1
               "0100100" when "10", -- 2
               "1111111" when others; -- Apagado
end architecture;

