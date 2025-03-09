import json
import os

with open('config.json') as f:
    config = json.load(f)

with open('yosys_synth_script.ys', 'w') as f:
    f.write("# read design\n")

    for verilog_file in config['VERILOG_FILES']:
        file_path = verilog_file.replace("dir::", "") 
        f.write(f"read_verilog -sv {file_path}\n")

    f.write(f"hierarchy -check -top {config['DESIGN_NAME']}\n")

    f.write("# the high-level stuff\n")
    f.write("proc; opt; fsm; opt; memory; opt\n")

    f.write("# mapping to internal cell library\n")
    f.write("techmap; opt\n")

    f.write("# mapping flip-flops to sky130_fd_sc_hd__tt_025C_1v80.lib\n")
    f.write("dfflibmap -liberty /foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib\n")
    
    f.write("# mapping logic to sky130_fd_sc_hd__tt_025C_1v80.lib\n")
    f.write("abc -liberty /foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib\n")
    
    f.write("clean\n")

    f.write("# write netlist file\n")
    f.write("write_verilog design_synth.v\n")
    f.write("write_blif design_synth.blif\n")
