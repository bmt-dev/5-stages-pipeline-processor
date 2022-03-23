library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etages_tb is
end entity etages_tb;

architecture test of etages_tb is
    signal t_clk, t_Gel_LI, t_PCSrc_ER, t_Bpris_EX : std_logic;
    signal t_npc, t_npc_fw_br, t_pc_plus_4, t_i_FE : std_logic_vector(31 downto 0);
begin

    etage : entity work.etageFE
        port map(
            clk => t_clk,
            Gel_LI => t_Gel_LI,
            PCSrc_ER => t_PCSrc_ER,
            Bpris_EX => t_Bpris_EX,
            npc => t_npc,
            npc_fw_br => t_npc_fw_br,
            pc_plus_4 => t_pc_plus_4,
            i_FE => t_i_FE
        );

    P_CLK : process
    begin
        t_clk <= '1';
        wait for 5 ns;
        t_clk <= '0';
        wait for 5 ns;
    end process P_CLK;

    P_TEST : process
    begin
        t_npc <= (others => '0');
        t_npc_fw_br <= (others => '0');
        t_Gel_LI <= '1';
        t_PCSrc_ER <= '0';
        t_Bpris_EX <= '0';

        wait for 5 ns;

        wait;
    end process P_TEST;
end architecture test;