set_false_path -from [get_clocks -of_objects [get_pins TauDesignTx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins TauDesignTx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins TauDesignTx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins TauDesignTx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]]

