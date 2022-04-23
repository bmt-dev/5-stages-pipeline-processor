library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cpu_tb is
end entity;

architecture cpu_test of cpu_tb is
    constant clkpulse : time := 5 ns; -- 1/2 periode horloge

    signal t_clk : std_logic;
begin

    cpu : entity work.cpu
        port map(
            clk => t_clk
        );

    P_CLK : process
    begin
        t_clk <= '1';
        wait for clkpulse;
        t_clk <= '0';
        wait for clkpulse;
    end process P_CLK;

    P_TEST : process
    begin
        wait for clkpulse * 50;
        assert FALSE report "FIN DE SIMULATION" severity FAILURE; -- success
    end process P_TEST;

end architecture;

----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etage_fe_tb is
end entity;

architecture fe_test of etage_fe_tb is
    constant clkpulse : time := 500 ns; -- 1/2 periode horloge

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
        wait for clkpulse;
        t_clk <= '0';
        wait for clkpulse;
    end process P_CLK;

    P_TEST : process
    begin
        t_npc <= (others => '0');
        t_npc_fw_br <= (others => '0');
        t_Gel_LI <= '1';
        t_PCSrc_ER <= '0';
        t_Bpris_EX <= '0';

        wait for clkpulse * 2;
        assert t_i_FE = x"00000000" report "ERREUR SIMULATION" severity FAILURE;
        assert t_pc_plus_4 = std_logic_vector(to_unsigned(4, t_pc_plus_4'length)) report "ERREUR SIMULATION" severity FAILURE;

        wait for clkpulse * 2;
        assert t_i_FE = x"00000001" report "ERREUR SIMULATION" severity FAILURE;
        assert t_pc_plus_4 = std_logic_vector(to_unsigned(8, t_pc_plus_4'length)) report "ERREUR SIMULATION" severity FAILURE;

        wait for clkpulse * 2;
        assert t_i_FE = x"00000002" report "ERREUR SIMULATION" severity FAILURE;
        assert t_pc_plus_4 = std_logic_vector(to_unsigned(12, t_pc_plus_4'length)) report "ERREUR SIMULATION" severity FAILURE;

        wait until (t_clk = '0');
        wait for clkpulse * 3;
        assert FALSE report "FIN DE SIMULATION" severity FAILURE; -- success
    end process P_TEST;

end architecture;

----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etage_de_tb is
end entity;

architecture de_test of etage_de_tb is
    constant clkpulse : time := 500 ns; -- 1/2 periode horloge

    signal t_clk, t_RegWr : std_logic;
    signal t_Op3_ER, t_Reg1, t_Reg2, t_Op3_DE : std_logic_vector(3 downto 0);
    signal t_RegSrc, t_immSrc : std_logic_vector(1 downto 0);
    signal t_i_DE, t_WD_ER, t_pc_plus_4, t_Op1, t_Op2, t_extImm : std_logic_vector(31 downto 0);
begin

    etage : entity work.etageDE
        port map(
            i_DE => t_i_DE,
            WD_ER => t_WD_ER,
            pc_plus_4 => t_pc_plus_4,
            Op3_ER => t_Op3_ER,
            RegSrc => t_RegSrc,
            immSrc => t_immSrc,
            RegWr => t_RegWr,
            clk => t_clk,
            Reg1 => t_Reg1,
            Reg2 => t_Reg2,
            Op3_DE => t_Op3_DE,
            Op1 => t_Op1,
            Op2 => t_Op2,
            extImm => t_extImm
        );

    P_CLK : process
    begin
        t_clk <= '1';
        wait for clkpulse;
        t_clk <= '0';
        wait for clkpulse;
    end process P_CLK;

    P_TEST : process
    begin
        wait until (t_clk = '1');
        t_RegWr <= '1';
        t_Op3_ER <= "0000";
        t_WD_ER <= (others => '0');

        wait until (t_clk = '1');

        t_RegWr <= '0';
        t_RegSrc <= (others => '0');
        wait for 1 ns;
        t_i_DE <= x"E0810002"; -- add r0, r1, r2

        wait for 5 ns;
        assert t_Reg1 = "0001" report "ERREUR SIMULATION" severity FAILURE;
        assert t_Reg2 = "0010" report "ERREUR SIMULATION" severity FAILURE;

        wait until (t_clk = '0');
        wait for clkpulse * 3;
        assert FALSE report "FIN DE SIMULATION" severity FAILURE; -- success
    end process P_TEST;

end architecture;

----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etage_ex_tb is
end entity;

architecture ex_test of etage_ex_tb is
    constant clkpulse : time := 500 ns; -- 1/2 periode horloge

    signal t_ALUSrc_EX : std_logic;
    signal t_EA_EX, t_EB_EX, t_ALUCtrl_EX : std_logic_vector(1 downto 0);
    signal t_Op3_EX, t_CC, t_Op3_EX_out : std_logic_vector(3 downto 0);
    signal t_Res_EX, t_WD_EX, t_npc_fw_br, t_Op1_EX, t_Op2_EX, t_ExtImm_EX, t_Res_fwd_ME, t_Res_fwd_ER : std_logic_vector(31 downto 0);
begin

    etage : entity work.etageEX
        port map(
            Op1_EX => t_Op1_EX,
            Op2_EX => t_Op2_EX,
            ExtImm_EX => t_ExtImm_EX,
            Res_fwd_ME => t_Res_fwd_ME,
            Res_fwd_ER => t_Res_fwd_ER,
            Op3_EX => t_Op3_EX,
            EA_EX => t_EA_EX,
            EB_EX => t_EB_EX,
            ALUCtrl_EX => t_ALUCtrl_EX,
            ALUSrc_EX => t_ALUSrc_EX,
            CC => t_CC,
            Op3_EX_out => t_Op3_EX_out,
            Res_EX => t_Res_EX,
            WD_EX => t_WD_EX,
            npc_fw_br => t_npc_fw_br
        );

    P_TEST : process
    begin
        t_Op1_EX <= (others => '0');
        t_Op2_EX <= x"00000001";
        t_EA_EX <= "00";
        t_EB_EX <= "00";
        t_ALUSrc_EX <= '0';
        t_ALUCtrl_EX <= "10"; -- and

        wait for 1 ns;
        assert t_Res_EX = std_logic_vector(to_unsigned(0, t_Res_EX'length)) report "ERREUR SIMULATION" severity FAILURE;

        wait for 3 ns;
        assert FALSE report "FIN DE SIMULATION" severity FAILURE; -- success
    end process P_TEST;

end architecture;

----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etage_me_tb is
end entity;

architecture me_test of etage_me_tb is
    constant clkpulse : time := 500 ns; -- 1/2 periode horloge

    signal t_clk, t_MemWR_MEM : std_logic;
    signal t_Op3_ME, t_Op3_ME_out : std_logic_vector(3 downto 0);
    signal t_Res_ME, t_WD_ME, t_Res_Mem_ME, t_Res_ALU_ME, t_Res_fwd_ME : std_logic_vector(31 downto 0);

begin

    etage : entity work.etageME
        port map(
            clk => t_clk,
            MemWR_MEM => t_MemWR_MEM,
            Op3_ME => t_Op3_ME,
            Op3_ME_out => t_Op3_ME_out,
            Res_ME => t_Res_ME,
            WD_ME => t_WD_ME,
            Res_Mem_ME => t_Res_Mem_ME,
            Res_ALU_ME => t_Res_ALU_ME,
            Res_fwd_ME => t_Res_fwd_ME
        );

    P_CLK : process
    begin
        t_clk <= '1';
        wait for clkpulse;
        t_clk <= '0';
        wait for clkpulse;
    end process P_CLK;

    P_TEST : process
    begin
        t_MemWR_MEM <= '1';
        t_WD_ME <= (others => '1');

        wait for clkpulse * 2;
        t_MemWR_MEM <= '0';
        t_Res_ME <= (others => '0');

        assert t_Res_Mem_ME = x"FFFFFFFF" report "ERREUR SIMULATION" severity FAILURE;

        wait until (t_clk = '0');
        wait for clkpulse * 3;
        assert FALSE report "FIN DE SIMULATION" severity FAILURE; -- success
    end process P_TEST;

end architecture;

----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etage_er_tb is
end entity;

architecture er_test of etage_er_tb is
    signal t_MemToReg_RE : std_logic;
    signal t_Res_Mem_RE, t_Res_ALU_RE, t_Res_RE : std_logic_vector(31 downto 0);
    signal t_Op3_RE, t_Op3_RE_out : std_logic_vector(3 downto 0);

begin

    etage : entity work.etageER
        port map(
            MemToReg_RE => t_MemToReg_RE,
            Res_Mem_RE => t_Res_Mem_RE,
            Res_ALU_RE => t_Res_ALU_RE,
            Res_RE => t_Res_RE,
            Op3_RE => t_Op3_RE,
            Op3_RE_out => t_Op3_RE_out
        );

    P_TEST : process
    begin
        t_Res_Mem_RE <= x"00000000";
        t_Res_ALU_RE <= x"00000001";
        t_Op3_RE <= "0000";
        wait for 1 ns;

        t_MemToReg_RE <= '1';
        wait for 1 ns;

        assert t_Res_RE = t_Res_Mem_RE report "ERREUR SIMULATION" severity FAILURE;

        t_MemToReg_RE <= '0';
        wait for 1 ns;

        assert t_Res_RE = t_Res_ALU_RE report "ERREUR SIMULATION" severity FAILURE;

        assert t_Op3_RE_out = t_Op3_RE report "ERREUR SIMULATION" severity FAILURE;

        wait for 3 ns;
        assert FALSE report "FIN DE SIMULATION" severity FAILURE; -- success

    end process P_TEST;

end architecture;

----------------------------------------------------