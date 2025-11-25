library ieee;
use ieee.std_logic_1164.all;

-- TOP LEVEL — jogo_adivinhacao (Caminho de Dados Refatorado)

entity jogo_adivinhacao is
    port(
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0); -- KEY0=RESET, KEY1=ENTER (Ativo LOW)
        SW       : in  std_logic_vector(8 downto 0); -- Tentativa do usuário

        HEX0, HEX1, HEX2 : out std_logic_vector(6 downto 0) -- Displays de resultado
    );
end entity;

architecture top_refactored of jogo_adivinhacao is

    -- Sinais de Controle e Utilidade
    signal loadA, loadB, disp_en  : std_logic; -- Sinais de controle da FSM
    signal deb_reset, deb_enter    : std_logic; -- Saída do Debouncer
    signal rst, ent                : std_logic; -- Saída do Edge Detector (pulsos)

    -- Barramentos de Dados
    signal SW_data                : std_logic_vector(8 downto 0); -- Dados brutos dos switches
    signal B_tentativa            : std_logic_vector(8 downto 0); -- Tentativa armazenada (saída dos Registradores B)
    signal R_resultados           : std_logic_vector(5 downto 0); -- Resultados da comparação (r2, r1, r0)

begin

    SW_data <= SW; 

    -- 1. Tratamento de Chaves (Debouncer + Edge Detector)
    -- Converte a pressão do botão em um pulso de 1 clock
    RESET_DEB: entity work.debouncer port map(CLOCK_50, KEY(0), deb_reset);
    ENTER_DEB: entity work.debouncer port map(CLOCK_50, KEY(1), deb_enter);
    
    RESET_EDGE: entity work.edge_detector port map(CLOCK_50, deb_reset, rst);
    ENTER_EDGE: entity work.edge_detector port map(CLOCK_50, deb_enter, ent);

    -- 2. Máquina de Estados (Controle Central)
    FSM: entity work.fsm_jogo
        port map(
            clk        => CLOCK_50,
            reset      => rst,
            enter      => ent,
            timeout    => '0',         -- Conexão desativada (Timer removido)
            loadA      => loadA,      
            loadB      => loadB,      
            display_en => disp_en      
        );

    -- 3. Registradores B (Armazenam a última tentativa (SW) quando ENTER é pressionado)
    REG_B1: entity work.reg3 port map(CLOCK_50, loadB, SW_data(2 downto 0), B_tentativa(2 downto 0));
    REG_B2: entity work.reg3 port map(CLOCK_50, loadB, SW_data(5 downto 3), B_tentativa(5 downto 3));
    REG_B3: entity work.reg3 port map(CLOCK_50, loadB, SW_data(8 downto 6), B_tentativa(8 downto 6));

    -- 4. Lógica de Sorteio e Comparação
    COMPARE: entity work.sorteio_e_comparacao
        port map(
            clk        => CLOCK_50,
            B_in       => B_tentativa, -- A comparação usa a saída dos registradores (B_tentativa)
            R_out      => R_resultados
        );

    -- 5. Decodificadores de 7 Segmentos
    DEC0: entity work.decod7seg port map(R_resultados(1 downto 0), HEX0); -- r0
    DEC1: entity work.decod7seg port map(R_resultados(3 downto 2), HEX1); -- r1
    DEC2: entity work.decod7seg port map(R_resultados(5 downto 4), HEX2); -- r2

end architecture;