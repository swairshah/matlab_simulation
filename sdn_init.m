function [s, t, r] = sdn_init(buffers, delays)
% Source nodes
s = {node(1, 0), node(2, 0)};
% Destination nodes
t = {node(1, 0), node(2, 0)};
% Router nodes
r = cell(1, 6);
for i = 1:6
    r{i} = router(i, buffers(i), delays(i));
end

% Connection between the nodes
st = [1 1; 1 2; 2 1; 2 2]';
sr = [1 1; 2 2]';
for ij = st
	i = ij(1); j = ij(2);
    s{i}.connect_node(t{j});
end

ls1 = link(s{1}, r{1});
s{1}.outport_link = ls1; r{1}.inport1_link = ls1;
ls2 = link(s{2}, r{2});
s{2}.outport_link = ls2; r{2}.inport1_link = ls2;

l13 = link(r{1}, r{3}); 
r{1}.outport1_link = l13; r{3}.inport1_link = l13;
l14 = link(r{1}, r{4});
r{1}.outport2_link = l14; r{4}.inport1_link = l14;

l23 = link(r{2}, r{3});
r{2}.outport1_link = l23; r{3}.inport2_link = l23;
l24 = link(r{2}, r{3});
r{2}.outport2_link = l24; r{4}.inport2_link = l24;

l35 = link(r{3}, r{5});
r{3}.outport1_link = l35; r{5}.inport1_link = l35;
l36 = link(r{3}, r{6});
r{3}.outport2_link = l36; r{6}.inport1_link = l36;

l45 = link(r{4}, r{5});
r{4}.outport1_link = l45; r{5}.inport2_link = l45;
l46 = link(r{4}, r{6});                           
r{4}.outport2_link = l46; r{6}.inport2_link = l46;

l51 = link(r{5}, t{1});
r{5}.outport1_link = l51; t{1}.inport_link = l51;
l62 = link(r{6}, t{2});                          
r{6}.outport1_link = l62; t{2}.inport_link = l62;
end