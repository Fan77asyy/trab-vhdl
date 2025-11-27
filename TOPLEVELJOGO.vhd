library ieee;
use ieee.std_logic_1164.all;

-- TOP LEVEL â€” jogo_adivinhacao para placa DE10-Lite
entity jogo_adivinhacao is
    port 
    (	
        MAX10_CLK1_50 	: in std_logic;
        KEY	   			: in std_logic_vector (1 downto 0);
        SW	   		 	: in std_logic_vector (9 downto 0);
        LEDR   		 	: out std_logic_vector (9 downto 0);
        HEX0			: out std_logic_vector (7 downto 0);
        HEX1 		    : out std_logic_vector (7 downto 0);
        HEX2		    : out std_logic_vector (7 downto 0); 
        HEX3		    : out std_logic_vector (7 downto 0);
        HEX4	   		: out std_logic_vector (7 downto 0);
        HEX5   		    : out std_logic_vector (7 downto 0)
    );
end entity;

architecture top_refactored of jogo_adivinhacao is

    component debouncer is
        port(
            clk       	: in  std_logic;
            btn_in   	: in  std_logic;
            btn_stable 	: out std_logic
        );
    end component;

    component edge_detector is
        port(
            clk       : in  std_logic;
            signal_in : in  std_logic;
            pulse_out : out std_logic
        );
    end component;

    component fsm_jogo is
        port(
            clk        : in std_logic;
            reset      : in std_logic;
            enter      : in std_logic;
            timeout    : in std_logic;
            loadA      : out std_logic;
            loadB      : out std_logic;
            display_en : out std_logic;
            reset_display : out std_logic
        );
    end component;

    component gerador_aleatorio is
        port(
            CLK  : in std_logic;
            RST  : in std_logic;
            EN   : in std_logic;
            NUM1 : out std_logic_vector(2 downto 0);
            NUM2 : out std_logic_vector(2 downto 0);
            NUM3 : out std_logic_vector(2 downto 0)
        );
    end component;

    component registrador is
        port(
            clk  : in  std_logic;
            load : in  std_logic;
            din  : in  std_logic_vector(2 downto 0);
            dout : out std_logic_vector(2 downto 0)
        );
    end component;

    component comparador is
        port(
            A_in  : in  std_logic_vector(8 downto 0);
            B_in  : in  std_logic_vector(8 downto 0);
            R_out : out std_logic_vector(5 downto 0)
        );
    end component;

    component decod7seg is
        port(
            code : in  std_logic_vector(1 downto 0);
            hex  : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Sinais de Controle 
    signal loadA, loadB, disp_en, reset_display : std_logic;
    signal deb_reset, deb_enter   				: std_logic;
    signal rst, ent               				: std_logic;
    
    signal SW_data               : std_logic_vector(8 downto 0);
    signal A_sorteado            : std_logic_vector(8 downto 0);
    signal B_tentativa           : std_logic_vector(8 downto 0);
    signal R_resultados          : std_logic_vector(5 downto 0);
    
    -- Sinais do Gerador AleatÃ³rio
    signal num_aleat1, num_aleat2, num_aleat3 : std_logic_vector(2 downto 0);
    
    -- Sinais para displays
    signal hex0_internal, hex1_internal, hex2_internal : std_logic_vector(6 downto 0);

begin

    -- Mapeamento de entradas
    SW_data <= SW(8 downto 0);
    
    -- LEDs espelham os switches
    LEDR(9 downto 0) <= SW(9 downto 0);

    -- 1. Tratamento de Chaves (Debouncer + Edge Detector)
    RESET_DEB: debouncer port map(
        clk => MAX10_CLK1_50,
        btn_in => KEY(0),
        btn_stable => deb_reset
    );

    ENTER_DEB: debouncer port map(
        clk => MAX10_CLK1_50,
        btn_in => KEY(1),
        btn_stable => deb_enter
    );
    
    RESET_EDGE: edge_detector port map(
        clk => MAX10_CLK1_50,
        signal_in => deb_reset,
        pulse_out => rst
    );

    ENTER_EDGE: edge_detector port map(
        clk => MAX10_CLK1_50,
        signal_in => deb_enter,
        pulse_out => ent
    );

    -- 2. MÃ¡quina de Estados (Controle Central)
    FSM: fsm_jogo port map(
        clk => MAX10_CLK1_50,
        reset => rst,
        enter => ent,
        timeout => '0',
        loadA => loadA,
        loadB => loadB,
        display_en => disp_en,
        reset_display => reset_display
    );

    -- 3. Gerador de NÃºmeros AleatÃ³rios
    RAND_GEN: gerador_aleatorio port map(
        CLK => MAX10_CLK1_50,
        RST => rst,
        EN => loadA,
        NUM1 => num_aleat1,
        NUM2 => num_aleat2,
        NUM3 => num_aleat3
    );

    -- 4. Registradores A (Armazenam o nÃºmero sorteado)
    REG_A1: registrador port map(
        clk => MAX10_CLK1_50,
        load => loadA, 
        din => num_aleat1,
        dout => A_sorteado(2 downto 0)
    );

    REG_A2: registrador port map(
        clk => MAX10_CLK1_50,
        load => loadA, 
        din => num_aleat2,
        dout => A_sorteado(5 downto 3)
    );

    REG_A3: registrador port map(
        clk => MAX10_CLK1_50,
        load => loadA, 
        din => num_aleat3,
        dout => A_sorteado(8 downto 6)
    );

    -- 5. Registradores B (Armazenam a tentativa do usuÃ¡rio)
    REG_B1: registrador port map(
        clk => MAX10_CLK1_50,
        load => loadB, --ent
        din => SW_data(2 downto 0),
        dout => B_tentativa(2 downto 0)
    );

    REG_B2: registrador port map(
        clk => MAX10_CLK1_50,
        load => loadB, --ent
        din => SW_data(5 downto 3),
        dout => B_tentativa(5 downto 3)
    );

    REG_B3: registrador port map(
        clk => MAX10_CLK1_50,
        load => loadB, --ent
        din => SW_data(8 downto 6),
        dout => B_tentativa(8 downto 6)
    );

    -- 6. LÃ³gica de ComparaÃ§Ã£o
    COMPARE: comparador port map(
        A_in => A_sorteado,
        B_in => B_tentativa,
        R_out => R_resultados
    );

    -- 7. Decodificadores de 7 Segmentos
    DEC0: decod7seg port map(
        code => R_resultados(1 downto 0),
        hex => hex0_internal
    );

    DEC1: decod7seg port map(
        code => R_resultados(3 downto 2),
        hex => hex1_internal
    );

    DEC2: decod7seg port map(
        code => R_resultados(5 downto 4),
        hex => hex2_internal
    );
    
    -- 8. Mapeamento para displays com controle de reset
    HEX0 <= '1' & hex0_internal when reset_display = '0' else "11111111";
    HEX1 <= '1' & hex1_internal when reset_display = '0' else "11111111";
    HEX2 <= '1' & hex2_internal when reset_display = '0' else "11111111";
    
    -- 9. Displays nÃ£o utilizados - acendem todos durante reset
    HEX3 <= "11111111" when reset_display = '1' else (others => '1');
    HEX4 <= "11111111" when reset_display = '1' else (others => '1');
    HEX5 <= "11111111" when reset_display = '1' else (others => '1');

end architecture;
