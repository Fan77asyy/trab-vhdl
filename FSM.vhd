library ieee;
use ieee.std_logic_1164.all;

-- FSM DO JOGO (controle de LOAD e DISPLAY)

entity fsm_jogo is
    port(
        clk       : in std_logic;
        reset     : in std_logic;  -- pulso (edge detect)
        enter     : in std_logic;  -- pulso (edge detect)
        timeout   : in std_logic;  -- timer que pode tirar

        loadA     : out std_logic; -- Sorteio (usado para garantir o carregamento inicial)
        loadB     : out std_logic; -- Carrega a tentativa do usuário (B)
        display_en: out std_logic -- Habilita o display de resultados
    );
end entity;

architecture rtl_fsm of fsm_jogo is
    type estado_t is (INICIO, T0, C1, C2, T1);
    signal estado, prox_estado : estado_t := INICIO;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            estado <= INICIO;
        elsif rising_edge(clk) then
            estado <= prox_estado;
        end if;
    end process;

    process(estado, enter, timeout)
    begin
        loadA <= '0';
        loadB <= '0';
        display_en <= '0';
        prox_estado <= estado;

        case estado is -- CONFERIR COERÊNCIA COM A MÁQUINA DE ESTADOS
            when INICIO =>
                loadA <= '1';       -- Força o carregamento/sorteio inicial
                prox_estado <= T0;   -- Vai para estado de espera pela tentativa

            when T0 => -- Espera pela tentativa (ENTER)
                if enter = '1' then
                    loadB <= '1';     -- Carrega o valor de SW nos Registradores B
                    prox_estado <= C1;
                end if;

            when C1 => -- Transição rápida após carregar a tentativa
                display_en <= '1';   -- Habilita o display e o timer
                prox_estado <= C2;

           when C2 =>
                display_en <= '1';
                if enter = '1' then   
                    prox_estado <= T1;
                end if;

            when T1 =>
                if enter = '1' then
                    prox_estado <= T0;
                end if;
        end case;
    end process;
end architecture;