# Define main clock (100 MHz)
create_clock -name clk -period 10.0 [get_ports clk]

# Tell analyzer to ignore async reset paths
set_false_path -from [get_ports clr]
