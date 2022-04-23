library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package bus_mux_pkg is
  type bus_mux_array is array(natural range <>) of std_logic_vector(31 downto 0);
end package bus_mux_pkg;

-------------------------------------------------

-- 32 bits Register (For PC storage )

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Reg32 is
  port (
    source : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0);
    wr, raz, clk : in std_logic
  );
end entity;

architecture arch_reg of Reg32 is
  signal sig : std_logic_vector(31 downto 0) := (others => '0');
begin
  output <= sig;
  process (clk, raz)
  begin
    if raz = '0' then
      sig <= (others => '0');
    else
      if (rising_edge(clk)) then
        if (wr = '1') then
          sig <= source;
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- 32 bits Register (For inter-stage buffers )

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Reg32sync is
  port (
    source : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0);
    wr, raz, clk : in std_logic
  );
end entity;

architecture arch_reg_sync of Reg32sync is
  signal sig : std_logic_vector(31 downto 0) := (others => '0');
begin
  output <= sig;
  process (clk)
  begin
    if (rising_edge(clk)) then
      if raz = '0' then
        sig <= (others => '0');
      else
        if (wr = '1') then
          sig <= source;
        end if;
      end if;
    end if;
  end process;
end architecture;
-------------------------------------------------

-- 4 bits Register (For inter-stage buffers)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Reg4 is
  port (
    source : in std_logic_vector(3 downto 0);
    output : out std_logic_vector(3 downto 0);
    wr, raz, clk : in std_logic
  );
end entity;

architecture arch_reg of Reg4 is
  signal sig : std_logic_vector(3 downto 0) := (others => '0');
begin
  output <= sig;
  process (clk)
  begin
    if (rising_edge(clk)) then
      if raz = '0' then
        sig <= (others => '0');
      else
        if (wr = '1') then
          sig <= source;
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- 2 bits Register (For inter-stage buffers)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Reg2 is
  port (
    source : in std_logic_vector(1 downto 0);
    output : out std_logic_vector(1 downto 0);
    wr, raz, clk : in std_logic
  );
end entity;

architecture arch_reg of Reg2 is
  signal sig : std_logic_vector(1 downto 0) := (others => '0');
begin
  output <= sig;
  process (clk)
  begin
    if (rising_edge(clk)) then
      if raz = '0' then
        sig <= (others => '0');
      else
        if (wr = '1') then
          sig <= source;
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- 1 bit Register (For inter-stage buffers)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Reg1 is
  port (
    source : in std_logic;
    output : out std_logic;
    wr, raz, clk : in std_logic
  );
end entity;

architecture arch_reg of Reg1 is
  signal sig : std_logic := '0';
begin
  output <= sig;
  process (clk)
  begin
    if (rising_edge(clk)) then
      if raz = '0' then
        sig <= '0';
      else
        if (wr = '1') then
          sig <= source;
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- Register bank

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.bus_mux_pkg.all;

entity RegisterBank is
  port (
    s_reg_0 : in std_logic_vector(3 downto 0);
    data_o_0 : out std_logic_vector(31 downto 0);
    s_reg_1 : in std_logic_vector(3 downto 0);
    data_o_1 : out std_logic_vector(31 downto 0);
    dest_reg : in std_logic_vector(3 downto 0);
    data_i : in std_logic_vector(31 downto 0);
    pc_in : in std_logic_vector(31 downto 0);
    wr_reg : in std_logic;
    clk : in std_logic
  );
end entity RegisterBank;
architecture arch_reg_bank of RegisterBank is
  signal regs : bus_mux_array(31 downto 0);

begin
  data_o_0 <= pc_in when to_integer(unsigned(s_reg_0)) = 15 else
    regs(to_integer(unsigned(s_reg_0)));
  data_o_1 <= pc_in when to_integer(unsigned(s_reg_1)) = 15 else
    regs(to_integer(unsigned(s_reg_1)));
  process (clk)
    variable dest : integer;
  begin
    if (wr_reg = '1' and rising_edge(clk)) then
      dest := to_integer(unsigned(dest_reg));
      regs(dest) <= data_i;
    end if;
  end process;

end architecture;