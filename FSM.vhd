library ieee;
use ieee.std_logic_1164.all;

-- FSM DO JOGO (controle de LOAD e DISPLAY)

entity fsm_jogo is
    port(
        clk        : in std_logic;
        reset      : in std_logic;  -- pulso (edge detect) - ATIVO EM LOW
        enter      : in std_logic;  -- pulso (edge detect) - ATIVO EM LOW
          

        loadA      : out std_logic; -- Sorteio (usado para garantir o carregamento inicial)
        loadB      : out std_logic; 
        display_en : out std_logic; 
        reset_display : out std_logic -- Sinal para acionar displays no reset
    );
end entity;

architecture rtl_fsm of fsm_jogo is
    type estado_t is (INICIO1,INICIO2, T0, C1, C2, T1);
    signal estado, prox_estado : estado_t := INICIO1;
    
    -- Sinais para tratar botoes ativos em LOW
    signal reset_active, enter_active : std_logic;
begin

    -- InversÃ£o dos sinais: convertemos de ativo-LOW para ativo-HIGH
    --reset_active <=  reset;  -- not reset=0 (pressionado) -> reset_active=1
    --enter_active <=  enter;  -- not enter=0 (pressionado) -> enter_active=1

    process(clk, reset_active)
    begin
        if reset_active = '1' then
            estado <= INICIO1;
        elsif rising_edge(clk) then
            estado <= prox_estado;
        end if;
    end process;

    process(estado, enter_active, reset_active)
    begin
        loadA <= '0';
        loadB <= '0';
        display_en <= '0';
        reset_display <= '0';
        prox_estado <= estado;

        case estado is
            when INICIO1 =>
                loadA <= '1';       -- Forca o carregamento/sorteio inicial
                reset_display <= '1'; -- Aciona todos os displays como aviso
                prox_estado <= INICIO2;   -- Vai para estado de espera pela tentativa
                
            when INICIO2 =>
                loadA <= '0';       -- Garante mudança de nivel do load e lógica do carregamento
                reset_display <= '1';
                prox_estado <= T0;   

            when T0 => -- Espera pela tentativa (ENTER)
                if enter_active = '1' then
                    loadB <= '1';     -- Carrega o valor de SW nos Registradores B
                    prox_estado <= C1;
                end if;

            when C1 => -- 
                loadB <= '0'; 
                display_en <= '1';   -- Habilita o display 
                prox_estado <= C2;
                
            when C2 =>
                display_en <= '1';
                if enter_active = '1' then   
                    prox_estado <= T1;
                end if;
                
            when T1 =>
                if enter_active = '1' then
                    prox_estado <= T0;
                end if;
        end case;
        
        -- Assync reset, ativa displays
        if reset_active = '1' then
            reset_display <= '1';
        end if;
    end process;
end architecture;
