## Generated SDC file "pacman_top.out.sdc"

## Copyright (C) 2024  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 23.1std.1 Build 993 05/14/2024 SC Lite Edition"

## DATE    "Sun Nov  3 22:50:29 2024"

##
## DEVICE  "10M50DAF484C7G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]
create_clock -name {clockDivider:CLK_GAME|outClock} -period 1.000 -waveform { 0.000 0.500 } [get_registers {clockDivider:CLK_GAME|outClock}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {CLK_CTRL|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 300 -master_clock {clk} [get_pins {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {CLK_CTRL|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 50 -master_clock {clk} [get_pins {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {CLK_VGA|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {clk} [get_pins {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clockDivider:CLK_GAME|outClock}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLK_VGA|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clockDivider:CLK_GAME|outClock}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLK_CTRL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

