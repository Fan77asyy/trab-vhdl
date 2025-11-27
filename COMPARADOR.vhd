library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- COMPARADOR NUMERO ALEATÓRIO E TENTATIVA

entity comparador is
    port (
        A_in   : in  std_logic_vector(8 downto 0);  -- NÃºmero sorteado (A2 A1 A0)
        B_in   : in  std_logic_vector(8 downto 0);  -- Tentativa do usuÃ¡rio (B2 B1 B0)
        R_out  : out std_logic_vector(5 downto 0)   -- Resultados: r2(1:0), r1(1:0), r0(1:0)
    );
end entity;

architecture rtl of comparador is
    signal A0, A1, A2 : std_logic_vector(2 downto 0);
    signal B0, B1, B2 : std_logic_vector(2 downto 0);
    
    signal r0, r1, r2 : std_logic_vector(1 downto 0);
begin
    -- Separa os dÃ­gitos
    A0 <= A_in(2 downto 0);
    A1 <= A_in(5 downto 3);
    A2 <= A_in(8 downto 6);
    
    B0 <= B_in(2 downto 0);
    B1 <= B_in(5 downto 3);
    B2 <= B_in(8 downto 6);
    
    -- LÃ³gica de comparaÃ§Ã£o para cada dÃ­gito
    process(A0, A1, A2, B0, B1, B2)
    begin
        -- ComparaÃ§Ã£o DÃ­gito 0
        if B0 = A0 then
            r0 <= "10";  -- NÃºmero correto na posiÃ§Ã£o correta
        elsif B0 = A1 or B0 = A2 then
            r0 <= "01";  -- NÃºmero correto na posiÃ§Ã£o errada
        else
            r0 <= "00";  -- NÃºmero nÃ£o existe
        end if;
        
        -- ComparaÃ§Ã£o DÃ­gito 1
        if B1 = A1 then
            r1 <= "10";  -- NÃºmero correto na posiÃ§Ã£o correta
        elsif B1 = A0 or B1 = A2 then
            r1 <= "01";  -- NÃºmero correto na posiÃ§Ã£o errada
        else
            r1 <= "00";  -- NÃºmero nÃ£o existe
        end if;
        
        -- ComparaÃ§Ã£o DÃ­gito 2
        if B2 = A2 then
            r2 <= "10";  -- NÃºmero correto na posiÃ§Ã£o correta
        elsif B2 = A0 or B2 = A1 then
            r2 <= "01";  -- NÃºmero correto na posiÃ§Ã£o errada
        else
            r2 <= "00";  -- NÃºmero nÃ£o existe
        end if;
    end process;
    
    -- Concatena os resultados
    R_out <= r2 & r1 & r0;
    
end architecture;
