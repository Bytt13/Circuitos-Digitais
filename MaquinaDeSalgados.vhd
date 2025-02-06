library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Declaração da entidade da máquina de vender salgados como uma máquina de estados
entity MaquinaDeSalgados is
    Port (
        entrada_moeda : in unsigned(1 downto 0); -- Entrada de seleção de moeda (0,25; 0,50; 1,00)
        selecao_salgado : in unsigned(2 downto 0); -- Entrada de seleção do salgado
        clock : in std_logic; -- Sinal de clock
        reset : in std_logic; -- Sinal de reset
        dispensador_salgado : out unsigned(3 downto 0); -- Saída do dispensador de salgado
        devolvendo_troco : out unsigned(3 downto 0) -- Saída do troco (4 bits para acomodar valores maiores que 3)
    );
end entity MaquinaDeSalgados;

architecture Behavioral of MaquinaDeSalgados is
    -- Tipos enumerados para os estados da máquina de estados
    type estados is (esperando, esperandoMoeda, esperandoMaisMoeda, selecionandoSalgado, liberandoSalgado, devolvendoTroco);
    signal estado_atual, proximo_estado : estados;
    
    -- Declaração de constantes para os tipos de salgados e seus preços
    constant BatataFritaGrande : unsigned(3 downto 0) := "0001";
    constant BatataFritaMedia : unsigned(3 downto 0) := "0010";
    constant BatataFritaPequena : unsigned(3 downto 0) := "0011";
    constant TortilhaGrande : unsigned(3 downto 0) := "0100";
    constant TortilhaPequena : unsigned(3 downto 0) := "0101";
    
    -- Constantes para os valores das moedas aceitas
    constant MOEDA_25 : unsigned(1 downto 0) := "00";
    constant MOEDA_50 : unsigned(1 downto 0) := "01";
    constant MOEDA_100 : unsigned(1 downto 0) := "10";
    
    -- Variáveis para armazenar o valor inserido e o preço do salgado selecionado
    signal valor_inserido : unsigned(3 downto 0) := (others => '0'); -- Ajustado para 4 bits
    signal preco_salgado : unsigned(3 downto 0);

begin
    -- Processo de controle da máquina de estados
    process (clock, reset)
    begin
        if reset = '1' then
            estado_atual <= esperando; -- Estado inicial após reset
        elsif rising_edge(clock) then
            estado_atual <= proximo_estado; -- Atualiza o estado atual com o próximo estado calculado
        end if;
    end process;

    -- Lógica da máquina de estados
    process (estado_atual, entrada_moeda, selecao_salgado)
    begin
        case estado_atual is
            when esperando =>
                if entrada_moeda = MOEDA_25 or entrada_moeda = MOEDA_50 or entrada_moeda = MOEDA_100 then
                    proximo_estado <= esperandoMoeda;
                else
                    proximo_estado <= esperando;
                end if;
            
            when esperandoMoeda =>
                -- Adicionar validação de moedas aqui
                case entrada_moeda is
                    when MOEDA_25 | MOEDA_50 | MOEDA_100 =>
                        valor_inserido <= valor_inserido + unsigned(entrada_moeda); -- Adiciona o valor da moeda inserida
                        proximo_estado <= selecionandoSalgado;
                    when others =>
                        proximo_estado <= esperandoMoeda; -- Permanece no estado esperando moeda se a moeda não for válida
                end case;
            
            when selecionandoSalgado =>
                case selecao_salgado is
                    when "000" => -- Seleção de BatataFritaGrande
                        preco_salgado <= to_unsigned(250, 4); -- Preço é 2,50 (em centavos)
                        if valor_inserido >= preco_salgado then
                            proximo_estado <= liberandoSalgado;
                        else
                            proximo_estado <= devolvendoTroco;
                        end if;
                    when "001" => -- Seleção de BatataFritaMedia
                        preco_salgado <= to_unsigned(150, 4); -- Preço é 1,50 (em centavos)
                        if valor_inserido >= preco_salgado then
                            proximo_estado <= liberandoSalgado;
                        else
                            proximo_estado <= devolvendoTroco;
                        end if;
                    when "010" => -- Seleção de BatataFritaPequena
                        preco_salgado <= to_unsigned(75, 4); -- Preço é 0,75 (em centavos)
                        if valor_inserido >= preco_salgado then
                            proximo_estado <= liberandoSalgado;
                        else
                            proximo_estado <= devolvendoTroco;
                        end if;
                    when "011" => -- Seleção de TortilhaGrande
                        preco_salgado <= to_unsigned(350, 4); -- Preço é 3,50 (em centavos)
                        if valor_inserido >= preco_salgado then
                            proximo_estado <= liberandoSalgado;
                        else
                            proximo_estado <= devolvendoTroco;
                        end if;
                    when "100" => -- Seleção de TortilhaPequena
                        preco_salgado <= to_unsigned(200, 4); -- Preço é 2,00 (em centavos)
                        if valor_inserido >= preco_salgado then
                            proximo_estado <= liberandoSalgado;
                        else
                            proximo_estado <= devolvendoTroco;
                        end if;
                    when others => -- Caso padrão, retorna ao estado de espera
                        proximo_estado <= esperando;
                end case;
            
            when liberandoSalgado =>
                dispensador_salgado <= to_unsigned(1, 4); -- Simulando a saída do salgado (exemplo)
                devolvendo_troco <= unsigned(valor_inserido) - preco_salgado; -- Calcula o troco
                valor_inserido <= (others => '0'); -- Zera o valor inserido após dispensar o salgado
                proximo_estado <= esperando; -- Retorna ao estado de espera após dispensar
            
            when devolvendoTroco =>
                devolvendo_troco <= valor_inserido; -- Retorna todo o valor inserido como troco
                valor_inserido <= (others => '0'); -- Zera o valor inserido após retornar o troco
                proximo_estado <= esperando; -- Retorna ao estado de espera após retornar o troco
            
            when others =>
                proximo_estado <= esperando; -- Caso padrão, retorna ao estado de espera
        end case;
    end process;

end architecture Behavioral;