#-----------------------------------------------------------------------------
#  University of California, San Diego - Center for Dark Silicon
#-----------------------------------------------------------------------------
#  io_fp_lib.py
#
#  Purpose: Library for IO-floorplanning files:
#           - Netlist (Verilog)
#           - Contraints (TCL)
#           - Layout (svg)
#
#  Author: Luis Vega - vegaluisjose@gmail.com
#-----------------------------------------------------------------------------

#-------
# Import
#-------

import os
import re

#-----------------------------------------------------------------------
# Netlist(verilog)
#
# Purpose: Take verilog netlist from Design Compiler, instantiate the top
#          module with the iopads, and output a new verilog netlist.
#-----------------------------------------------------------------------


#-------------------
# I/O file functions
#-------------------

def print_file(input_list, file_name):
    try:
        ofile = open(file_name, 'w')
        for line in input_list:
            ofile.write(line + '\n')
        ofile.close()
    except IOError:
        print "Cannot open file", ofile

def merge_file(files, file_name):
    try:
        content = ""
        for f in files:
            content = content + "\n"  + open(f).read()
        ofile = open(file_name, 'w')
        ofile.write(content)
        ofile.close()
    except IOError:
        print "Cannot open file"

#------------------
# Parsing functions
#------------------

def extract_module(input_v, output_v, module):
    try:
        ifile = open(input_v, 'r')
        data = ifile.read()
        ex_mod = re.search(r'module\s+' + module + '.*?endmodule', data, re.DOTALL)
        if ex_mod:
            ofile = open(output_v, 'w')
            ofile.write(ex_mod.group())
            ofile.close()
        else:
            print "Module " + module + " not found"
        ifile.close()
    except IOError:
        print "Cannot open file", ifile

def extract_ports(input_v, direction):
    try:
        ifile = open(input_v, 'r')
        data = ifile.read()
        form_ports = re.findall(direction + r'\s.*', data)
        if form_ports:
            one_bit_ports = []
            mult_bit_ports = []
            port_width = []
            for line in form_ports:
                fil = re.sub(r',', r' ', line)
                fil = re.sub(r';', r'', fil)
                fil = re.sub(direction + r'\s+', r'', fil)
                if re.search(r'\[', fil):
                    temp = re.findall(r'\s+(\w+)',fil)
                    mult_bit_ports = mult_bit_ports + temp
                    port_width = port_width + len(temp)*re.findall(r'\[(\d+):',fil)
                elif re.search(r'\w+', fil):
                    one_bit_ports = one_bit_ports + re.findall(r'\w+', fil)
        else:
            print "Module does not have " + direction + " ports"
        ifile.close()
        ports = [form_ports, one_bit_ports, mult_bit_ports, port_width]
        return ports
    except IOError:
        print "Cannot open file", ifile

#-----------------------------
# Verilog generation functions
#-----------------------------

def gen_top_module(top_module_name, form_ports, prfx):
    module = ["", "module " + top_module_name + " ("]
    last = len(form_ports) + 1
    for line in form_ports:
        fil = re.sub(r'\s(\w+)', ' ' + prfx + r'_\1', line)
        fil = re.sub(r',(\w+)', ', ' + prfx + r'_\1', fil)
        fil = re.sub(r';', r',', fil)
        module.append("    " + fil)
    module[last] = re.sub(r',', r'', module[last])
    module.append(");")
    return module

def gen_wires(form_ports):
    wires = [""]
    for item in form_ports:
        wires.append(re.sub(r'(input|output)', r'wire', item))
    return wires

def gen_instance(module_name, port_list):
    instance = ["", module_name + " " + module_name + "_inst ("]
    last = len(port_list) + 1
    for word in port_list:
        inst = "." + word + "(" + word + "),"
        instance.append("    " + inst)
    instance[last] = re.sub(r',', r'', instance[last])
    instance.append(");")
    return instance

def gen_ipads(pad_cell, prfx, obports, mbports, pwidth):
    ipads = [""]
    for i in range(len(obports)):
        line = pad_cell + " ipad_" + obports[i] + " (.PAD(" + prfx + "_" + obports[i] + "), .C(" + obports[i] + "));"
        ipads.append(line)
    for i in range(len(mbports)):
        port = mbports[i]
        w = int(pwidth[i]) + 1
        for j in range(w):
            line = pad_cell + " ipad_" + port + "_" + str(j) + " (.PAD(" + prfx + "_" + port + "[" + str(j) + "]), .C(" + port + "[" + str(j) + "]));"
            ipads.append(line)
    return ipads

def gen_opads(pad_cell, prfx, obports, mbports, pwidth):
    opads = [""]
    for i in range(len(obports)):
        line = pad_cell + " opad_" + obports[i] + " (.I(" + obports[i] + "), .PAD(" + prfx + "_" + obports[i] + "));"
        opads.append(line)
    for i in range(len(mbports)):
        port = mbports[i]
        w = int(pwidth[i]) + 1
        for j in range(w):
            line = pad_cell + " opad_" + port + "_" + str(j) + " (.I(" + port + "[" + str(j) + "]), .OEN(1'b0), .PAD(" + prfx + "_" + port + "[" + str(j) + "]));"
            opads.append(line)
    return opads

def gen_iopads_verilog(input_v, output_v, module_name, top_module_name, prfx, io_cells):
    # Extracted module - verilog file
    module_v = module_name + '.v'

    # Verilog - output file - module_name_iopads.v
    top_v = module_name + ".top.v"

    # Unpacking io_cells
    ipad_cell, opad_cell = io_cells

    # Extracting the module from verilog netlist
    extract_module(input_v, module_v, module_name)

    # Extracting port information from the desired module
    in_fports, in_obports, in_mbports, in_pwidth = extract_ports(module_v, "input")
    out_fports, out_obports, out_mbports, out_pwidth = extract_ports(module_v, "output")

    # Grouping fports
    fports = in_fports + out_fports

    # Port names
    port_names = in_obports + in_mbports + out_obports + out_mbports

    # Generating new top module that instantiate the desired module
    top_module = gen_top_module(top_module_name, fports, prfx)

    # Generating wires for connecting the desired module
    wires = gen_wires(fports)

    # Generating the instance of the desired module
    instance = gen_instance(module_name, port_names)

    # Generating IPADs instantiation/connection
    ipads = gen_ipads(ipad_cell, prfx, in_obports, in_mbports, in_pwidth)

    # Generating OPADs instantiation/connection
    opads = gen_opads(opad_cell, prfx, out_obports, out_mbports, out_pwidth)

    # Last line
    last_line = ["", "endmodule"]

    # Putting all together to print the verilog file
    v_list = top_module + wires + instance + ipads + opads + last_line
    print_file(v_list, top_v)

    # Merging the design compiler netlist with the new top module
    m_files = [input_v, top_v]
    merge_file(m_files, output_v)

    # Removing the extracted module
    os.remove(module_v)
    os.remove(top_v)

#-----------------------------------------------------------------------
# Constraints(TCL)
#
# Output: pin_pad_physical_constraints
#         physical_only_cells_creation_file
#-----------------------------------------------------------------------

#----------
# Functions
#----------

def prefixer(signals, pfx):
    output_list = []
    if (isinstance(signals, list)):
        for i in signals:
            output_list.append(pfx + "_" + i)
    else:
            output_list.append(pfx + "_" + signals)
    return output_list

def create_pad_cell(pad_name, num_pad, ref_names):
    cell = "create_cell { "
    for i in range(num_pad):
        cell = cell + pad_name + "_" + str(i) + " "
    cell = cell + "} " + ref_names
    return cell

def create_corner_cell(corner_names, corner_cell):
    cell = "create_cell { "
    for i in range(4):
        cell = cell + corner_names[i] + " "
    cell = cell + "} " + corner_cell
    return cell

def create_cell(cells_creation_file, core_power_number, io_power_number, ref_names, power_names, corner_names):

    [core_vss_cell, core_vdd_cell, io_vss_cell, io_vdd_cell, corner_cell] = ref_names
    [core_vss_name, core_vdd_name, io_vss_name, io_vdd_name] = power_names

    # Crate core-power and io-power cells
    cell = []
    cell.append(create_pad_cell(core_vss_name, core_power_number[0], core_vss_cell))
    cell.append(create_pad_cell(core_vdd_name, core_power_number[1], core_vdd_cell))
    cell.append(create_pad_cell(io_vss_name, io_power_number[0], io_vss_cell))
    cell.append(create_pad_cell(io_vdd_name, io_power_number[1], io_vdd_cell))

    cell.append(create_corner_cell(corner_names, corner_cell))

    # Print result
    print_file(cell, cells_creation_file)

def pin_pad_physical_constraints(pad_constraint_file, corner_names, pad_list):

    # Constraint list
    constraints = []

    # Corners
    for i in range(4):
        constraints.append("set_pad_physical_constraints -side " + str(i + 1) + " -pad_name " + corner_names[i])

    # Fixing direction of right and bottom side to counter clockwise
    for i in range(2):
        pad_list[2 + i] = pad_list[2 + i][::-1]

    # Ordering and placing pads
    for i in range(len(pad_list)):
        for j in range(len(pad_list[i])):
            constraints.append("set_pad_physical_constraints -side " + str(i+1) +
                               " -pad_name " + pad_list[i][j] + " -order " + str(j+1))

    # Print
    print_file(constraints, pad_constraint_file)

#------
# Class
#------

class side_pad_list(object):
    def __init__(self):
        self.pad_list = []
    def place(self, pads):
        for p in pads:
            self.pad_list.append(p)
    def get_list(self):
        return self.pad_list

class power_pad(object):
    def __init__(self, vss_name = "vss", vdd_name = "vdd", last_pad = 0):
        self.vss_name = vss_name
        self.vdd_name = vdd_name
        self.vss_pad_cnt = 0
        self.vdd_pad_cnt = 0
        self.last_pad = last_pad
    def new_pad(self, num_pads = 1):
        self.next_pad = []
        if (self.last_pad == 0):
            for i in range(num_pads):
                self.next_pad.append(self.vss_name + "_" + str(self.vss_pad_cnt))
                self.vss_pad_cnt += 1
            self.last_pad = 1
        elif (self.last_pad == 1):
            for i in range(num_pads):
                self.next_pad.append(self.vdd_name + "_" + str(self.vdd_pad_cnt))
                self.vdd_pad_cnt += 1
            self.last_pad = 0
        return self.next_pad
    def get_vss_pad(self):
        return self.vss_pad_cnt
    def get_vdd_pad(self):
        return self.vdd_pad_cnt

class murn_channel(object):
    def __init__(self, clk_name = "clk", data_name = "data", cmd_name = "cmd", token_name = "token"):
        self.clk_name = clk_name
        self.data_name = data_name
        self.cmd_name = cmd_name
        self.token_name = token_name
        self.clk_cnt = 0
        self.data_cnt = 0
        self.cmd_cnt = 0
        self.token_cnt = 0
    def get_cmd(self):
        self.next_pad = [self.cmd_name + "_" + str(self.cmd_cnt)]
        self.cmd_cnt += 1
        return self.next_pad
    def get_data(self):
        self.next_pad = [self.data_name + "_" + str(self.data_cnt)]
        self.data_cnt += 1
        return self.next_pad
    def get_token(self):
        self.next_pad = [self.token_name + "_" + str(self.token_cnt)]
        self.token_cnt += 1
        return self.next_pad
    def get_clk(self):
        self.next_pad = [self.clk_name + "_" + str(self.clk_cnt)]
        self.clk_cnt += 1
        return self.next_pad
    def get_total(self):
        return self.cmd_cnt + self.data_cnt + self.token_cnt + self.clk_cnt


class sys_signal(object):
    def __init__(self, clk = "clk", rst = "rst"):
        self.clk = [clk]
        self.rst = [rst]
    def get_clk(self):
        return self.clk
    def get_rst(self):
        return self.rst
    def get_total(self):
        return 2

#-----------------------------------------------------------------------
# Layout(svg)
#-----------------------------------------------------------------------

def header_svg(width, height):
    first = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" "
    size = "width=\"" + str(width) + "\" height=\"" + str(height) + "\" "
    vbox = "viewBox=\"0 -" + str(height) + " " + str(width) + " " + str(height) + "\""
    last = ">"
    return first + size + vbox + last

def footer_svg():
    return "</svg>"

def read_colormap(colormap):
    try:
        f = open(colormap, 'r')
        name_table = []
        color_table = []
        for line in f:
            item = line.replace(' ','').rstrip().split(',')
            if (len(item[0]) > 0 and len(item[1]) > 0):
                name_table.append(item[0])
                color_table.append(item[1])
        f.close()
        return name_table, color_table
    except IOError:
        print "Cannot open file", colormap

def find_color(name, name_table, color_table):
    for i in range(len(name_table)):
        if (re.match(name_table[i], name)):
            return color_table[i]
    return "none"

def xy_to_svg_rect(ll_x, ll_y, ur_x, ur_y):
    x = ll_x
    y = ur_y
    width = ur_x - ll_x
    height = ur_y - ll_y
    return x, y, width, height

def draw_rectangle(x, y, width, height, fill_color, stroke_color, stroke_width):
    rect = "<rect x=\"" + str(x) + "\" y=\"-" + str(y) + "\" width=\"" + \
           str(width) + "\" height=\"" + str(height) + "\" style=\"fill:" + \
           fill_color + ";stroke:" + stroke_color + ";stroke-width:" + \
           str(stroke_width) + "\"/>"
    return rect

def gen_metal_xy(xy_file):
    try:
        f = open(xy_file, 'r')
        icc_xy = []
        metal_xy = []
        for line in f:
            icc_xy.append(line.rstrip())
            i = line.rstrip().split(',')
            if (re.match('^bpo.*', i[0])):
                if (i[5]=="left"):
                    m_LL_X = float(i[1]) + 2
                    m_LL_Y = float(i[2]) - 12.5
                    m_UR_X = float(i[3]) - 127.8
                    m_UR_Y = float(i[4]) + 12.5
                elif (i[5]=="top"):
                    m_LL_X = float(i[1]) - 12.5
                    m_LL_Y = float(i[2]) + 127.8
                    m_UR_X = float(i[3]) + 12.5
                    m_UR_Y = float(i[4]) - 2
                elif (i[5]=="right"):
                    m_LL_X = float(i[1]) + 127.8
                    m_LL_Y = float(i[2]) - 12.5
                    m_UR_X = float(i[3]) - 2
                    m_UR_Y = float(i[4]) + 12.5
                elif (i[5]=="bottom"):
                    m_LL_X = float(i[1]) - 12.5
                    m_LL_Y = float(i[2]) + 2
                    m_UR_X = float(i[3]) + 12.5
                    m_UR_Y = float(i[4]) - 127.8
                metal_xy.append("metal_" + i[0] + "," + str(m_LL_X) + "," + str(m_LL_Y) + "," + str(m_UR_X) + "," + str(m_UR_Y) + "," + i[5])
            elif (re.match('^bpi.*', i[0])):
                if (i[5]=="left"):
                    m_LL_X = float(i[1]) + 2
                    m_LL_Y = float(i[2]) - 12.5
                    m_UR_X = float(i[3]) - 12.8
                    m_UR_Y = float(i[4]) + 12.5
                elif (i[5]=="top"):
                    m_LL_X = float(i[1]) - 12.5
                    m_LL_Y = float(i[2]) + 12.8
                    m_UR_X = float(i[3]) + 12.5
                    m_UR_Y = float(i[4]) - 2
                elif (i[5]=="right"):
                    m_LL_X = float(i[1]) + 12.8
                    m_LL_Y = float(i[2]) - 12.5
                    m_UR_X = float(i[3]) - 2
                    m_UR_Y = float(i[4]) + 12.5
                elif (i[5]=="bottom"):
                    m_LL_X = float(i[1]) - 12.5
                    m_LL_Y = float(i[2]) + 2
                    m_UR_X = float(i[3]) + 12.5
                    m_UR_Y = float(i[4]) - 12.8
                metal_xy.append("metal_" + i[0] + "," + str(m_LL_X) + "," + str(m_LL_Y) + "," + str(m_UR_X) + "," + str(m_UR_Y) + "," + i[5])
        f.close()
        return icc_xy + metal_xy
    except IOError:
        print "Cannot open file", xy_file

def draw_layout(xy_file, colormap, stroke_color, stroke_width):
    name_table, color_table = read_colormap(colormap)
    layout = []
    xy = gen_metal_xy(xy_file)
    for line in xy:
        item = line.split(',')
        [x, y, width, height] = xy_to_svg_rect(float(item[1]), float(item[2]), float(item[3]), float(item[4]))
        fill_color = find_color(item[0], name_table, color_table)
        layout.append(draw_rectangle(x, y, width, height, fill_color, stroke_color, stroke_width))
    return layout, xy

