library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- MÓDULO: SORTEIO E COMPARAÇÃO

entity sorteio_e_comparacao is
    port(
        clk       : in  std_logic;
        
        -- Entrada da tentativa do usuário (B3, B2, B1) 
        B_in      : in  std_logic_vector(8 downto 0); 

        -- Saída da Comparação (r2, r1, r0) 
        R_out     : out std_logic_vector(5 downto 0) 
    );
end entity;

architecture rtl of sorteio_e_comparacao is
    -- contador de sorteio aleatório
    signal random_counter : unsigned(8 downto 0) := (others => '0');

    -- Números sorteados (A)
    signal A1, A2, A3 : std_logic_vector(2 downto 0);
    
    -- Números da tentativa (B) - Saída dos registradores B
    signal B1, B2, B3 : std_logic_vector(2 downto 0);

    -- Resultados da comparação (r)
    signal r0, r1, r2 : std_logic_vector(1 downto 0);

begin
    -- Geração dos números sorteados (pseudoaleatório)
    process(clk)
    begin
        if rising_edge(clk) then
            random_counter <= random_counter + 1;
        end if;
    end process;

    A1 <= std_logic_vector(random_counter(2 downto 0)); -- Num 0
    A2 <= std_logic_vector(random_counter(5 downto 3)); -- Num 1
    A3 <= std_logic_vector(random_counter(8 downto 6)); -- Num 2
    
    -- Desempacotamento da tentativa (B)
    B3 <= B_in(8 downto 6);
    B2 <= B_in(5 downto 3);
    B1 <= B_in(2 downto 0);

    -- Lógica de Comparação/ talvez colocar em outro arquivo de comparação
    
    -- Comparação Posição 0 (B1 vs A)
    r0 <= "10" when (B1 = A1) else        
          "01" when (B1 = A2 or B1 = A3) else
          "00";

    -- Comparação Posição 1 (B2 vs A)
    r1 <= "10" when (B2 = A2) else
          "01" when (B2 = A1 or B2 = A3) else
          "00";

    -- Comparação Posição 2 (B3 vs A)
    r2 <= "10" when (B3 = A3) else
          "01" when (B3 = A1 or B3 = A2) else
          "00";

    -- Saída Concatenada
    R_out <= r2 & r1 & r0;
    
end architecture;