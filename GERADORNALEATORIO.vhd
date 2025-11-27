library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- GERADOR DE NÚMEROS ALEATÓRIOS

entity gerador_aleatorio is
    port (
        CLK     : in std_logic;
        RST     : in std_logic;
        EN      : in std_logic;
        NUM1    : out std_logic_vector(2 downto 0);
        NUM2    : out std_logic_vector(2 downto 0);
        NUM3    : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of gerador_aleatorio is
    signal contador : unsigned(15 downto 0) := (others => '0');
    signal n1, n2, n3: std_logic_vector(2 downto 0);
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Contador sempre incrementando
            contador <= contador + 1;
            
            -- Quando EN='1', captura os valores aleatÃ³rios
            if EN = '1' then
                n1 <= std_logic_vector(contador(2 downto 0));
                n2 <= std_logic_vector(contador(5 downto 3));
                n3 <= std_logic_vector(contador(8 downto 6));
            end if;
        end if;
    end process;
    
    NUM1 <= n1;
    NUM2 <= n2;
    NUM3 <= n3;
end architecture;
