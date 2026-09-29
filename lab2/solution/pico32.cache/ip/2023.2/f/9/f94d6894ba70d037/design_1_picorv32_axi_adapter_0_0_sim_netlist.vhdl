-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Thu Aug  8 17:22:26 2024
-- Host        : DESKTOP-5D6U9FV running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_picorv32_axi_adapter_0_0_sim_netlist.vhdl
-- Design      : design_1_picorv32_axi_adapter_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_picorv32_axi_adapter is
  port (
    mem_axi_bready : out STD_LOGIC;
    mem_axi_awvalid : out STD_LOGIC;
    mem_axi_wvalid : out STD_LOGIC;
    mem_axi_arvalid : out STD_LOGIC;
    clk : in STD_LOGIC;
    mem_axi_awready : in STD_LOGIC;
    resetn : in STD_LOGIC;
    mem_valid : in STD_LOGIC;
    mem_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    mem_axi_rvalid : in STD_LOGIC;
    mem_axi_bvalid : in STD_LOGIC;
    mem_axi_arready : in STD_LOGIC;
    mem_axi_wready : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_picorv32_axi_adapter;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_picorv32_axi_adapter is
  signal ack_arvalid_i_1_n_0 : STD_LOGIC;
  signal ack_arvalid_reg_n_0 : STD_LOGIC;
  signal ack_awvalid : STD_LOGIC;
  signal ack_awvalid_i_1_n_0 : STD_LOGIC;
  signal ack_wvalid_i_1_n_0 : STD_LOGIC;
  signal ack_wvalid_reg_n_0 : STD_LOGIC;
  signal \^mem_axi_arvalid\ : STD_LOGIC;
  signal \^mem_axi_bready\ : STD_LOGIC;
  signal xfer_done : STD_LOGIC;
  signal xfer_done_i_1_n_0 : STD_LOGIC;
begin
  mem_axi_arvalid <= \^mem_axi_arvalid\;
  mem_axi_bready <= \^mem_axi_bready\;
ack_arvalid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00EA0000AAAAAAAA"
    )
        port map (
      I0 => ack_arvalid_reg_n_0,
      I1 => \^mem_axi_arvalid\,
      I2 => mem_axi_arready,
      I3 => xfer_done,
      I4 => mem_valid,
      I5 => resetn,
      O => ack_arvalid_i_1_n_0
    );
ack_arvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => ack_arvalid_i_1_n_0,
      Q => ack_arvalid_reg_n_0,
      R => '0'
    );
ack_awvalid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000EA0000000000"
    )
        port map (
      I0 => ack_awvalid,
      I1 => mem_axi_awready,
      I2 => \^mem_axi_bready\,
      I3 => resetn,
      I4 => xfer_done,
      I5 => mem_valid,
      O => ack_awvalid_i_1_n_0
    );
ack_awvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => ack_awvalid_i_1_n_0,
      Q => ack_awvalid,
      R => '0'
    );
ack_wvalid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00EA0000AAAAAAAA"
    )
        port map (
      I0 => ack_wvalid_reg_n_0,
      I1 => \^mem_axi_bready\,
      I2 => mem_axi_wready,
      I3 => xfer_done,
      I4 => mem_valid,
      I5 => resetn,
      O => ack_wvalid_i_1_n_0
    );
ack_wvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => ack_wvalid_i_1_n_0,
      Q => ack_wvalid_reg_n_0,
      R => '0'
    );
mem_axi_arvalid_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000010000"
    )
        port map (
      I0 => mem_wstrb(1),
      I1 => mem_wstrb(0),
      I2 => mem_wstrb(3),
      I3 => mem_wstrb(2),
      I4 => mem_valid,
      I5 => ack_arvalid_reg_n_0,
      O => \^mem_axi_arvalid\
    );
mem_axi_awvalid_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000FFFE0000"
    )
        port map (
      I0 => mem_wstrb(1),
      I1 => mem_wstrb(0),
      I2 => mem_wstrb(3),
      I3 => mem_wstrb(2),
      I4 => mem_valid,
      I5 => ack_awvalid,
      O => mem_axi_awvalid
    );
mem_axi_bready_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA8"
    )
        port map (
      I0 => mem_valid,
      I1 => mem_wstrb(2),
      I2 => mem_wstrb(3),
      I3 => mem_wstrb(0),
      I4 => mem_wstrb(1),
      O => \^mem_axi_bready\
    );
mem_axi_wvalid_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000FFFE0000"
    )
        port map (
      I0 => mem_wstrb(1),
      I1 => mem_wstrb(0),
      I2 => mem_wstrb(3),
      I3 => mem_wstrb(2),
      I4 => mem_valid,
      I5 => ack_wvalid_reg_n_0,
      O => mem_axi_wvalid
    );
xfer_done_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"A8FFA800"
    )
        port map (
      I0 => mem_valid,
      I1 => mem_axi_rvalid,
      I2 => mem_axi_bvalid,
      I3 => resetn,
      I4 => xfer_done,
      O => xfer_done_i_1_n_0
    );
xfer_done_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => xfer_done_i_1_n_0,
      Q => xfer_done,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    clk : in STD_LOGIC;
    resetn : in STD_LOGIC;
    mem_axi_awvalid : out STD_LOGIC;
    mem_axi_awready : in STD_LOGIC;
    mem_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    mem_axi_wvalid : out STD_LOGIC;
    mem_axi_wready : in STD_LOGIC;
    mem_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    mem_axi_bvalid : in STD_LOGIC;
    mem_axi_bready : out STD_LOGIC;
    mem_axi_arvalid : out STD_LOGIC;
    mem_axi_arready : in STD_LOGIC;
    mem_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    mem_axi_rvalid : in STD_LOGIC;
    mem_axi_rready : out STD_LOGIC;
    mem_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_valid : in STD_LOGIC;
    mem_instr : in STD_LOGIC;
    mem_ready : out STD_LOGIC;
    mem_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    mem_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_picorv32_axi_adapter_0_0,picorv32_axi_adapter,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "picorv32_axi_adapter,Vivado 2023.2";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  signal \<const0>\ : STD_LOGIC;
  signal \^mem_addr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^mem_axi_rdata\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^mem_instr\ : STD_LOGIC;
  signal \^mem_wdata\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^mem_wstrb\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF mem_axi, ASSOCIATED_RESET resetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of mem_axi_arready : signal is "xilinx.com:interface:aximm:1.0 mem_axi ARREADY";
  attribute X_INTERFACE_INFO of mem_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 mem_axi ARVALID";
  attribute X_INTERFACE_INFO of mem_axi_awready : signal is "xilinx.com:interface:aximm:1.0 mem_axi AWREADY";
  attribute X_INTERFACE_INFO of mem_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 mem_axi AWVALID";
  attribute X_INTERFACE_INFO of mem_axi_bready : signal is "xilinx.com:interface:aximm:1.0 mem_axi BREADY";
  attribute X_INTERFACE_INFO of mem_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 mem_axi BVALID";
  attribute X_INTERFACE_INFO of mem_axi_rready : signal is "xilinx.com:interface:aximm:1.0 mem_axi RREADY";
  attribute X_INTERFACE_INFO of mem_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 mem_axi RVALID";
  attribute X_INTERFACE_INFO of mem_axi_wready : signal is "xilinx.com:interface:aximm:1.0 mem_axi WREADY";
  attribute X_INTERFACE_INFO of mem_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 mem_axi WVALID";
  attribute X_INTERFACE_INFO of resetn : signal is "xilinx.com:signal:reset:1.0 resetn RST";
  attribute X_INTERFACE_PARAMETER of resetn : signal is "XIL_INTERFACENAME resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of mem_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 mem_axi ARADDR";
  attribute X_INTERFACE_INFO of mem_axi_arprot : signal is "xilinx.com:interface:aximm:1.0 mem_axi ARPROT";
  attribute X_INTERFACE_INFO of mem_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 mem_axi AWADDR";
  attribute X_INTERFACE_INFO of mem_axi_awprot : signal is "xilinx.com:interface:aximm:1.0 mem_axi AWPROT";
  attribute X_INTERFACE_INFO of mem_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 mem_axi RDATA";
  attribute X_INTERFACE_PARAMETER of mem_axi_rdata : signal is "XIL_INTERFACENAME mem_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 0, HAS_RRESP 0, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of mem_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 mem_axi WDATA";
  attribute X_INTERFACE_INFO of mem_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 mem_axi WSTRB";
begin
  \^mem_addr\(31 downto 0) <= mem_addr(31 downto 0);
  \^mem_axi_rdata\(31 downto 0) <= mem_axi_rdata(31 downto 0);
  \^mem_instr\ <= mem_instr;
  \^mem_wdata\(31 downto 0) <= mem_wdata(31 downto 0);
  \^mem_wstrb\(3 downto 0) <= mem_wstrb(3 downto 0);
  mem_axi_araddr(31 downto 0) <= \^mem_addr\(31 downto 0);
  mem_axi_arprot(2) <= \^mem_instr\;
  mem_axi_arprot(1) <= \<const0>\;
  mem_axi_arprot(0) <= \<const0>\;
  mem_axi_awaddr(31 downto 0) <= \^mem_addr\(31 downto 0);
  mem_axi_awprot(2) <= \<const0>\;
  mem_axi_awprot(1) <= \<const0>\;
  mem_axi_awprot(0) <= \<const0>\;
  mem_axi_wdata(31 downto 0) <= \^mem_wdata\(31 downto 0);
  mem_axi_wstrb(3 downto 0) <= \^mem_wstrb\(3 downto 0);
  mem_rdata(31 downto 0) <= \^mem_axi_rdata\(31 downto 0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_picorv32_axi_adapter
     port map (
      clk => clk,
      mem_axi_arready => mem_axi_arready,
      mem_axi_arvalid => mem_axi_arvalid,
      mem_axi_awready => mem_axi_awready,
      mem_axi_awvalid => mem_axi_awvalid,
      mem_axi_bready => mem_axi_bready,
      mem_axi_bvalid => mem_axi_bvalid,
      mem_axi_rvalid => mem_axi_rvalid,
      mem_axi_wready => mem_axi_wready,
      mem_axi_wvalid => mem_axi_wvalid,
      mem_valid => mem_valid,
      mem_wstrb(3 downto 0) => \^mem_wstrb\(3 downto 0),
      resetn => resetn
    );
mem_axi_rready_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000002"
    )
        port map (
      I0 => mem_valid,
      I1 => \^mem_wstrb\(2),
      I2 => \^mem_wstrb\(3),
      I3 => \^mem_wstrb\(0),
      I4 => \^mem_wstrb\(1),
      O => mem_axi_rready
    );
mem_ready_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => mem_axi_bvalid,
      I1 => mem_axi_rvalid,
      O => mem_ready
    );
end STRUCTURE;
