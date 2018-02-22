#!/usr/bin/python

import sys;
import re;

# MBT 1/2/2017
#
# this python script does a recursive descent parse of the .lib file
# and then provides an API to search and delete from it.
#
# currently the search and delete patterns are hard-coded into this file
# but they could be separated out and this could be made a general library
#
#

#
#
# parse_lib
# parses .lib file hierarchically into a tree according to brackets
#
#

def parse_lib (input,left) :
    node = [];
    token = "";
    index = left;
    while (index < len(input)):
        if (input[index] == '{') :
            node.append(token)
            child, index = parse_lib(input,index+1);
            node.append(child)
            token = "";
        if (input[index] == '}') :
            node.append(token)
            return (node, index+1)
        token += input[index]
        index=index+1

    return(node,index)

#
# prints out parse_lib tree identically to parsing
#
#

def print_parse_lib_tree (fileptr,node,depth=0) :
    for x in node :
        if isinstance(x,list) :
            fileptr.write("{");
            print_parse_lib_tree(fileptr,x, depth+1);
            fileptr.write("}");
        else :
            fileptr.write(x);

#
#
# finds a matching path through the hierarchical text of the lib file using regexps
#
#
# find_route returns a list of indexes; the indexes correspond to the tag positions, not the list positions
#   e.g.
#    a { }
#    b {  c {  } f }
#    g {  h { } i { } j   };

#    i.e
#      a: 0
#      b: 2
#      c: 2 0
#      f: 2 2
#      g: 4
#      h: 4 0
#      i: 4 2
#      j: 4 4
#


def find_route (node,path,depth) :
    #sys.stderr.write("entering delete path depth = "+str(depth)+"\n");
    if (depth==len(path)) :
        return 1;
    else :
        pattern = re.compile(path[depth],re.DOTALL);
    index = 0;
    while (index < len(node)) :
        if (not isinstance(node[index],list)) :
            # match against node,ignoring white space
            m = pattern.match(node[index]);
            if (m) :
                #sys.stderr.write("<@ matched:" + path[depth]+ m.group() +"@>");
                #sys.stderr.write("matched:"+path[depth]+"\n");
                if (depth == len(path)-1) :
                    route = []
                    route.insert(0,index);
                    return route;
                if (isinstance(node[index+1],list)) :
                    route = find_route(node[index+1],path,depth+1);
                    if (len(route)>0) :
                        route.insert(0,index);
                        return route;
                    #else :
                    #    sys.stderr.write( "did not match\n");
            #else :
                #sys.stderr.write("<@notmatched:" + path[depth] + node[index]+"@>");
                #sys.stderr.write("<@notmatched:" + path[depth]+"@>");
        index = index+1;
    #sys.stderr.write("returning; failed to match\n");
    return [];

#
#
# deletes a node through the hierarchical text of the lib file using the
# coordinates found by find_route
#
#

def delete_route (node, path) :
    ptr = node;
    index = 0;
    while (index < len(path)-1) :
        #sys.stderr.write(str(path[index])+",");
        ptr = ptr[path[index]+1];
        index = index + 1;
    ptr.pop(path[index]);

user_in = sys.stdin.read()

node,index = parse_lib(user_in,0)


# finds and deletes a node through the hierarchical text of the file

def find_and_delete_regexp_route(node,path) :
    result = find_route(node,path,0);
    if (result) :
        sys.stderr.write("# INFO: regexp path found and deleted at location: ");
        sys.stderr.write(str(result)+"\n");

        # pop up one level from found node
        result.pop();

        # deletes the node and its { } clause
        delete_route(node,result);
        delete_route(node,result);
    else :
        sys.stderr.write("# INFO: did not delete any clauses in .lib file\n");

#
# here is a hierarchical list of regexps to find the correct section in the file to delete
#
# currently we are deleting sections that create timing assertions between CLKA and CLKB
# which should not apply if we are not reading/writing the same address
#

prefix_string =  "tsmc180_2rf_lg[0-9]+_w[0-9]+_m[0-9+]_[a-z]+"

find_and_delete_regexp_route(node
                      ,[".*library\("+prefix_string+".*_syn\).*"
                        ,".*cell\("+prefix_string+"\).*"
                        ,".*pin\(CLKA\).*",".*timing\(\).*"
                        ,".*related_pin.*CLKB.*timing_type.*setup_rising.*"
                        ]
                      );

find_and_delete_regexp_route(node
                      ,[".*library\("+prefix_string+".*_syn\).*"
                        ,".*cell\("+prefix_string+"\).*"
                        ,".*pin\(CLKB\).*",".*timing\(\).*"
                        ,".*related_pin.*CLKA.*timing_type.*setup_rising.*"
                        ]
                      );

if (len(sys.argv) == 2) :
    print "outputing to file: ",sys.argv[1];
    fileptr = open(sys.argv[1],'w');
    # output file
    print_parse_lib_tree(fileptr, node)
    fileptr.write("\n");
else:
    print "usage: <exec> <output file>",sys.argv[1];
