-------------------------------------------------------

-- Chemin de données

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity dataPath is
  port (
    clk, ALUSrc_EX, MemWr_Mem, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE : in std_logic;
    RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : in std_logic_vector(1 downto 0);
    instr_DE : out std_logic_vector(31 downto 0);
    a1, a2, CC : out std_logic_vector(3 downto 0);
    Op3_EX_out_ext, Op3_ME_out_ext, Op3_RE_out_ext : out std_logic_vector(3 downto 0)
  );
end entity;

architecture dataPath_arch of dataPath is
  signal Res_RE, npc_fwd_br, pc_plus_4, i_FE, i_DE, Op1_DE, Op2_DE, Op1_EX, Op2_EX, extImm_DE, extImm_EX, Res_EX, Res_ME, WD_EX, WD_ME, Res_Mem_ME, Res_Mem_RE, Res_ALU_ME, Res_ALU_RE, Res_fwd_ME : std_logic_vector(31 downto 0);
  signal Op3_DE, Op3_EX, a1_DE, a1_EX, a2_DE, a2_EX, Op3_EX_out, Op3_ME, Op3_ME_out, Op3_RE, Op3_RE_out : std_logic_vector(3 downto 0);
begin

  Op3_EX_out_ext <= Op3_EX_out;
  Op3_ME_out_ext <= Op3_ME_out;
  Op3_RE_out_ext <= Op3_RE_out;

  -- pipeline registers

  pipe_i_FE_i_DE : entity work.Reg32sync
    port map(
      source => i_FE,
      output => i_DE,
      wr => Gel_DI,
      raz => RAZ_DI,
      clk => clk
    );

  pipe_reg1_a1 : entity work.Reg4
    port map(
      source => a1_DE,
      output => a1_EX,
      wr => '1',
      raz => Clr_EX,
      clk => clk
    );

  pipe_reg2_a2 : entity work.Reg4
    port map(
      source => a2_DE,
      output => a2_EX,
      wr => '1',
      raz => Clr_EX,
      clk => clk
    );

  pipe_Op1_Op1_EX : entity work.Reg32sync
    port map(
      source => Op1_DE,
      output => Op1_EX,
      wr => '1',
      raz => Clr_EX,
      clk => clk
    );

  pipe_Op2_Op2_EX : entity work.Reg32sync
    port map(
      source => Op2_DE,
      output => Op2_EX,
      wr => '1',
      raz => Clr_EX,
      clk => clk
    );

  pipe_extImm_ExtImm_EX : entity work.Reg32sync
    port map(
      source => extImm_DE,
      output => extImm_EX,
      wr => '1',
      raz => Clr_EX,
      clk => clk
    );

  pipe_Op3_DE_Op3_EX : entity work.Reg4
    port map(
      source => Op3_DE,
      output => Op3_EX,
      wr => '1',
      raz => Clr_EX,
      clk => clk
    );

  pipe_Res_EX_Res_ME : entity work.Reg32sync
    port map(
      source => Res_EX,
      output => Res_ME,
      wr => '1',
      raz => '1',
      clk => clk
    );

  pipe_WD_EX_WD_ME : entity work.Reg32sync
    port map(
      source => WD_EX,
      output => WD_ME,
      wr => '1',
      raz => '1',
      clk => clk
    );

  pipe_Op3_EX_out_Op3_ME : entity work.Reg4
    port map(
      source => Op3_EX_out,
      output => Op3_ME,
      wr => '1',
      raz => '1',
      clk => clk
    );

  pipe_Res_Mem_ME_Res_Mem_RE : entity work.Reg32sync
    port map(
      source => Res_Mem_ME,
      output => Res_Mem_RE,
      wr => '1',
      raz => '1',
      clk => clk
    );

  pipe_Res_ALU_ME_RES_ALU_RE : entity work.Reg32sync
    port map(
      source => Res_ALU_ME,
      output => Res_ALU_RE,
      wr => '1',
      raz => '1',
      clk => clk
    );

  pipe_Op3_ME_out_Op3_RE : entity work.Reg4
    port map(
      source => Op3_ME_out,
      output => Op3_RE,
      wr => '1',
      raz => '1',
      clk => clk
    );

  -- FE

  fe : entity work.etageFE
    port map(
      npc => Res_RE,
      npc_fw_br => npc_fwd_br,
      PCSrc_ER => PCSrc_ER,
      Bpris_EX => Bpris_EX,
      GEL_LI => Gel_LI,
      clk => clk,
      pc_plus_4 => pc_plus_4,
      i_FE => i_FE
    );

  -- -------------------------------------------------

  -- DE

  de : entity work.etageDE
    port map(
      i_DE => i_DE,
      WD_ER => Res_RE,
      pc_plus_4 => pc_plus_4,
      Op3_ER => Op3_RE_out,
      RegSrc => RegSrc,
      immSrc => immSrc,
      RegWr => RegWR,
      clk => clk,
      Reg1 => a1_DE,
      Reg2 => a2_DE,
      Op3_DE => Op3_DE,
      Op1 => Op1_DE,
      Op2 => Op2_DE,
      extImm => extImm_DE
    );

  -- -------------------------------------------------

  -- EX

  ex : entity work.etageEX
    port map(
      Op1_EX => Op1_EX,
      Op2_EX => Op2_EX,
      ExtImm_EX => extImm_EX,
      Res_fwd_ME => Res_fwd_ME,
      Res_fwd_ER => Res_RE,
      Op3_EX => Op3_EX,
      EA_EX => EA_EX,
      EB_EX => EB_EX,
      ALUCtrl_EX => ALUCtrl_EX,
      ALUSrc_EX => ALUSrc_EX,
      CC => CC,
      Op3_EX_out => Op3_EX_out,
      Res_EX => Res_EX,
      WD_EX => WD_EX,
      npc_fw_br => npc_fwd_br
    );

  -- -------------------------------------------------

  -- ME

  me : entity work.etageME
    port map(
      Res_ME => Res_ME,
      WD_ME => WD_ME,
      Op3_ME => Op3_ME,
      Op3_ME_out => Op3_ME_out,
      clk => clk,
      MemWR_MEM => MemWr_Mem,
      Res_Mem_ME => Res_Mem_ME,
      Res_ALU_ME => Res_ALU_ME,
      Res_fwd_ME => Res_fwd_ME
    );

  -- -------------------------------------------------

  -- RE

  re : entity work.etageER
    port map(
      Res_Mem_RE => Res_Mem_RE,
      Res_ALU_RE => Res_ALU_RE,
      Op3_RE => Op3_RE,
      MemToReg_RE => MemToReg_RE,
      Res_RE => Res_RE,
      Op3_RE_out => Op3_RE_out
    );

  -- -------------------------------------------------

  instr_DE <= i_DE;
  a1 <= a1_EX;
  a2 <= a2_EX;

end architecture;

-------------------------------------------------------

-- Unité de contrôle

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity control_unit is
  port (
    instr : in std_logic_vector(31 downto 0);
    PCSrc, RegWr, MemToReg, MemWr, Branch, CCWr, AluSrc : out std_logic;
    AluCtrl, ImmSrc, RegSrc : out std_logic_vector(1 downto 0);
    Cond : out std_logic_vector(3 downto 0)
  );
end entity;

architecture control_unit_arch of control_unit is

begin

  Cond <= instr(31 downto 28);

  AluCtrl <= "00" when (instr(27 downto 26) = "10")
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "0100")
    or (instr(27 downto 26) = "01" and instr(23) = '0') else

    "01" when (instr(27 downto 26) = "00" and instr(24 downto 21) = "0010")
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010")
    or (instr(27 downto 26) = "01" and instr(23) = '1') else

    "10" when (instr(27 downto 26) = "00" and instr(24 downto 21) = "0000") else

    "11" when (instr(27 downto 26) = "00" and instr(24 downto 21) = "1100") else

    "XX";

  Branch <= '0' when (instr(27 downto 26) = "00" and instr(25) = '0')
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010" and instr(25) = '0' and instr(20) = '1')
    or (instr(27 downto 26) = "00" and instr(25) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '0') else

    '1' when instr(27 downto 26) = "10" else

    'X';

  MemToReg <= '0' when (instr(27 downto 26) = "00" and instr(25) = '0')
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010" and instr(25) = '0' and instr(20) = '1')
    or (instr(27 downto 26) = "00" and instr(25) = '1')
    or (instr(27 downto 26) = "10") else

    '1' when (instr(27 downto 26) = "01" and instr(20) = '1') else

    'X';

  MemWr <= '0' when (instr(27 downto 26) = "00" and instr(25) = '0')
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010" and instr(25) = '0' and instr(20) = '1')
    or (instr(27 downto 26) = "00" and instr(25) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '1')
    or (instr(27 downto 26) = "10") else

    '1' when (instr(27 downto 26) = "01" and instr(20) = '0') else

    'X';

  AluSrc <= '0' when (instr(27 downto 26) = "00" and instr(25) = '0')
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010" and instr(25) = '0' and instr(20) = '1') else

    '1' when (instr(27 downto 26) = "00" and instr(25) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '0')
    or (instr(27 downto 26) = "10") else

    'X';

  ImmSrc <= "00" when (instr(27 downto 26) = "00" and instr(25) = '1') else

    "01" when (instr(27 downto 26) = "01" and instr(20) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '0') else

    "10" when instr(27 downto 26) = "10" else

    "XX";

  RegWr <= '1' when (instr(27 downto 26) = "00" and instr(25) = '0')
    or (instr(27 downto 26) = "00" and instr(25) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '1') else

    '0' when (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010" and instr(25) = '0' and instr(20) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '0')
    or (instr(27 downto 26) = "10") else

    'X';

  RegSrc <= "00" when (instr(27 downto 26) = "00" and instr(25) = '0')
    or (instr(27 downto 26) = "00" and instr(24 downto 21) = "1010" and instr(25) = '0' and instr(20) = '1') else

    "10" when instr(27 downto 26) = "01" and instr(20) = '0' else

    (0 => '0', others => '0') when (instr(27 downto 26) = "00" and instr(25) = '1') or (instr(27 downto 26) = "01" and instr(20) = '1') else

    (0 => '1', others => '0') when instr(27 downto 26) = "10" else -- others peut etre à n'importe quelle valeur vu que c'est X

    "XX";

  PCSrc <= '1' when (instr(27 downto 26) = "00" and instr(25) = '0' and instr(15 downto 12) = "1111")
    or (instr(27 downto 26) = "00" and instr(25) = '1' and instr(15 downto 12) = "1111")
    or (instr(27 downto 26) = "01" and instr(20) = '1' and instr(15 downto 12) = "1111") else

    '0' when (instr(27 downto 26) = "00" and instr(25) = '0' and instr(20) = '1' and instr(15 downto 12) /= "1111")
    or (instr(27 downto 26) = "00" and instr(25) = '1' and instr(15 downto 12) /= "1111")
    or (instr(27 downto 26) = "01" and instr(20) = '1' and instr(15 downto 12) /= "1111") else

    'X';

  CCWr <= '0' when (instr(27 downto 26) = "00" and instr(25) = '0' and instr(20) = '0')
    or (instr(27 downto 26) = "00" and instr(25) = '1' and instr(20) = '0')
    or (instr(27 downto 26) = "01" and instr(20) = '1')
    or (instr(27 downto 26) = "01" and instr(20) = '0')
    or (instr(27 downto 26) = "10") else

    '1' when (instr(27 downto 26) = "00" and instr(25) = '0' and instr(20) = '1')
    or (instr(27 downto 26) = "00" and instr(25) = '1' and instr(20) = '1') else

    'X';

end architecture;

-------------------------------------------------------

-- Unité de gestion des conditions

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cond_unit is
  port (
    Cond, CC_EX, CC : in std_logic_vector(3 downto 0);
    CC_p : out std_logic_vector(3 downto 0); -- CC_p pour CC'
    CCWr_EX : in std_logic;
    CondEx : out std_logic
  );
end entity;

architecture cond_unit_arch of cond_unit is
  signal CondExtemp : std_logic;
begin

  CC_p <= CC when CCWr_EX = '1' and CondExtemp = '1' else
    CC_EX;

  -- N(3) Z(2) C(1) V(0)

  CondExtemp <= '1' when
    (Cond = "0000" and CC_EX(2) = '1')
    or (Cond = "0001" and CC_EX(2) = '0')
    or (Cond = "0010" and CC_EX(1) = '1')
    or (Cond = "0011" and CC_EX(1) = '0')
    or (Cond = "0100" and CC_EX(3) = '1')
    or (Cond = "0101" and CC_EX(3) = '0')
    or (Cond = "0110" and CC_EX(0) = '1')
    or (Cond = "0111" and CC_EX(0) = '0')
    or (Cond = "1000" and (CC_EX(1) = '1' and CC_EX(2) = '0'))
    or (Cond = "1001" and (CC_EX(1) = '0' and CC_EX(2) = '1'))
    or (Cond = "1010" and (CC_EX(3) = CC_EX(0)))
    or (Cond = "1011" and (CC_EX(3) /= CC_EX(0)))
    or (Cond = "1100" and (CC_EX(2) = '0' and (CC_EX(3) = CC_EX(0))))
    or (Cond = "1101" and (CC_EX(2) = '1' or (CC_EX(3) /= CC_EX(0))))
    or (Cond = "1110") else
    '0';

  CondEx <= CondExtemp;

end architecture;

-------------------------------------------------------

-- Unité de gestion des aléas

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity alea_unit is
  port (
    Gel_LI, En_DI, Clr_DI, Clr_EX : out std_logic;
    EA_EX, EB_EX : out std_logic_vector(1 downto 0);
    a1, a2, Op3_EX_out, Op3_ME_out, Op3_RE_out : in std_logic_vector(3 downto 0);
    Bpris_EX, PCSrc_DE, PCSrc_EX, PCSrc_ME, PCSrc_ER, RegWR_Mem, RegWR_RE, MemToReg_EX : in std_logic
  );
end entity;

architecture alea_unit_arch of alea_unit is
  signal LDRStall : std_logic;
begin

  EA_EX <= "10" when (a1 = Op3_ME_out and RegWR_Mem = '1') else
    "01" when (a1 /= Op3_ME_out and a1 = Op3_RE_out and RegWR_RE = '1') else
    "00";

  EB_EX <= "10" when (a2 = Op3_ME_out and RegWR_Mem = '1') else
    "01" when (a2 /= Op3_ME_out and a2 = Op3_RE_out and RegWR_RE = '1') else
    "00";

  LDRStall <= '1' when (a1 = Op3_EX_out or a2 = Op3_EX_out) and MemToReg_EX = '1' else
    '0';

  En_DI <= not LDRStall;

  Clr_EX <= not (LDRStall and Bpris_EX);

  GEL_LI <= not (LDRStall and PCSrc_DE and PCSrc_EX and PCSrc_ME);

  Clr_DI <= not (PCSrc_DE and PCSrc_EX and PCSrc_ME and PCSrc_ER and Bpris_EX);

end architecture;

--------------------------------------------------------