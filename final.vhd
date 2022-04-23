library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cpu is
    port (
        clk : in std_logic
    );
end entity;

architecture cpu_arch of cpu is

    signal CondEx, CCWr, CCWr_EX, PCSrc_DE, PCSrc_EX, PCSrc_ME, PCSrc_ER, RegWr_DE, RegWR_EX, RegWR_Me, RegWR_RE, MemWr_DE, MemWr_EX, MemWr_Me, Branch_DE, Branch_EX, Bpris_EX, MemToReg_DE, MemToReg_EX, MemToReg_ME, MemToReg_RE, ALUSrc_DE, ALUSrc_EX, Gel_LI, En_DI, Clr_DI, Clr_EX, RegWr_EX_and_CondEx, PCSrc_EX_and_CondEx, MemWr_EX_and_CondEx : std_logic;
    signal ALUCtrl_DE, ALUCtrl_EX, immSrc, RegSrc, EA_EX, EB_EX : std_logic_vector(1 downto 0);
    signal instr_DE : std_logic_vector(31 downto 0);
    signal CC, Cond_DE, Cond_EX, CC_EX, CC_p, a1, a2, Op3_EX_out, Op3_ME_out, Op3_RE_out : std_logic_vector(3 downto 0);

begin

    pipe_CC_p_CC_EX : entity work.Reg4
        port map(
            source => CC_p,
            output => CC_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_CCWr_CCWr_EX : entity work.Reg1
        port map(
            source => CCWr,
            output => CCWr_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_Cond_DE_Cond_EX : entity work.Reg4
        port map(
            source => Cond_DE,
            output => Cond_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_RegWr_DE_RegWR_EX : entity work.Reg1
        port map(
            source => RegWr_DE,
            output => RegWR_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    RegWr_EX_and_CondEx <= RegWr_EX and CondEx;

    pipe_RegWr_EX_and_CondEx_RegWR_ME : entity work.Reg1
        port map(
            source => RegWr_EX_and_CondEx,
            output => RegWR_ME,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_RegWr_ME_RegWR_ER : entity work.Reg1
        port map(
            source => RegWr_ME,
            output => RegWR_RE,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_PCSrc_DE_PCSrc_EX : entity work.Reg1
        port map(
            source => PCSrc_DE,
            output => PCSrc_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    PCSrc_EX_and_CondEx <= PCSrc_EX and CondEx;

    pipe_PCSrc_EX_and_CondEx_PCSrc_ME : entity work.Reg1
        port map(
            source => PCSrc_EX_and_CondEx,
            output => PCSrc_ME,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_PCSrc_ME_PCSrc_ER : entity work.Reg1
        port map(
            source => PCSrc_ME,
            output => PCSrc_ER,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_MemWr_DE_MemWr_EX : entity work.Reg1
        port map(
            source => MemWr_DE,
            output => MemWr_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    MemWr_EX_and_CondEx <= MemWr_EX and CondEx;

    pipe_MemWr_EX_and_CondEx_MemWr_ME : entity work.Reg1
        port map(
            source => MemWr_EX_and_CondEx,
            output => MemWr_ME,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_ALUCtrl_DE_ALUCtrl_EX : entity work.Reg2
        port map(
            source => ALUCtrl_DE,
            output => ALUCtrl_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_Branch_DE_Branch_EX : entity work.Reg1
        port map(
            source => Branch_DE,
            output => Branch_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    Bpris_EX <= CondEx and Branch_EX;

    pipe_MemToReg_DE_MemToReg_EX : entity work.Reg1
        port map(
            source => MemToReg_DE,
            output => MemToReg_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_MemToReg_EX_MemToReg_ME : entity work.Reg1
        port map(
            source => MemToReg_EX,
            output => MemToReg_ME,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_MemToReg_ME_MemToReg_RE : entity work.Reg1
        port map(
            source => MemToReg_ME,
            output => MemToReg_RE,
            wr => '1',
            raz => '1',
            clk => clk
        );

    pipe_ALUSrc_DE_ALUSrc_EX : entity work.Reg1
        port map(
            source => ALUSrc_DE,
            output => ALUSrc_EX,
            wr => '1',
            raz => '1',
            clk => clk
        );

    datapath : entity work.dataPath
        port map(
            clk => clk,
            ALUSrc_EX => ALUSrc_EX,
            MemWr_Mem => MemWr_ME,
            PCSrc_ER => PCSrc_ER,
            Bpris_EX => Bpris_EX,
            Gel_LI => Gel_LI,
            Gel_DI => En_DI,
            RAZ_DI => Clr_DI,
            RegWR => RegWR_RE,
            Clr_EX => Clr_EX,
            MemToReg_RE => MemToReg_RE,
            RegSrc => RegSrc,
            EA_EX => EA_EX,
            EB_EX => EB_EX,
            immSrc => immSrc,
            ALUCtrl_EX => ALUCtrl_EX,
            instr_DE => instr_DE,
            a1 => a1,
            a2 => a2,
            CC => CC,
            Op3_ME_out_ext => Op3_ME_out,
            Op3_RE_out_ext => Op3_RE_out,
            Op3_EX_out_ext => Op3_EX_out
        );

    control_unit : entity work.control_unit
        port map(
            instr => instr_DE,
            PCSrc => PCSrc_DE,
            RegWr => RegWr_DE,
            MemWr => MemWr_DE,
            AluCtrl => ALUCtrl_DE,
            Branch => Branch_DE,
            MemToReg => MemToReg_DE,
            CCWr => CCWr,
            AluSrc => ALUSrc_DE,
            ImmSrc => immSrc,
            RegSrc => RegSrc,
            Cond => Cond_DE
        );

    cond_unit : entity work.cond_unit
        port map(
            Cond => Cond_EX,
            CC_EX => CC_EX,
            CC => CC,
            CC_p => CC_p,
            CCWr_EX => CCWr_EX,
            CondEx => CondEx
        );

    alea_unit : entity work.alea_unit
        port map(
            Gel_LI => Gel_LI,
            En_DI => En_DI,
            Clr_DI => Clr_DI,
            Clr_EX => Clr_EX,
            EA_EX => EA_EX,
            EB_EX => EB_EX,
            a1 => a1,
            a2 => a2,
            Op3_EX_out => Op3_EX_out,
            Op3_ME_out => Op3_ME_out,
            Op3_RE_out => Op3_RE_out,
            Bpris_EX => Bpris_EX,
            PCSrc_DE => PCSrc_DE,
            PCSrc_EX => PCSrc_EX,
            PCSrc_ME => PCSrc_ME,
            PCSrc_ER => PCSrc_ER,
            RegWR_Mem => RegWR_ME,
            RegWR_RE => RegWR_RE,
            MemToReg_EX => MemToReg_EX
        );

end architecture;