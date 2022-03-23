-------------------------------------------------

-- Etage FE

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity etageFE is
  port (
    npc, npc_fw_br : in std_logic_vector(31 downto 0);
    PCSrc_ER, Bpris_EX, GEL_LI, clk : in std_logic;
    pc_plus_4, i_FE : out std_logic_vector(31 downto 0)
  );
end entity;

architecture etageFE_arch of etageFE is
  signal pc_inter, pc_reg_in, pc_reg_out, sig_pc_plus_4, sig_4 : std_logic_vector(31 downto 0);
begin

  pc : entity work.Reg32
    port map(
      source => pc_reg_in,
      output => pc_reg_out,
      wr => GEL_LI,
      raz => '1',
      clk => clk
    );

  imem : entity work.inst_mem
    port map(
      addr => pc_reg_out,
      instr => i_FE
    );

  add : entity work.addComplex
    port map(
      A => pc_reg_out,
      B => sig_4,
      cin => '0',
      s => sig_pc_plus_4
    );

  sig_4 <= (2 => '1', others => '0');

  pc_reg_in <= pc_inter when Bpris_EX = '0' else
    npc_fw_br when Bpris_EX = '1' else
    (others => 'X');

  pc_inter <= npc when PCSrc_ER = '1' else
    sig_pc_plus_4 when PCSrc_ER = '0' else
    (others => 'X');

  pc_plus_4 <= sig_pc_plus_4;

end architecture;

-- -------------------------------------------------

-- -- Etage DE

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageDE is
-- end entity

-- -------------------------------------------------

-- -- Etage EX

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageEX is
-- end entity
-- -------------------------------------------------

-- -- Etage ME

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageME is
-- end entity
-- -------------------------------------------------

-- -- Etage ER

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageER is
-- end entity