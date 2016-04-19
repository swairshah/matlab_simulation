function [cum_drops, avg_delays] = main_opt()

max_q = 2;

s1 = node(1, 0.5);
s2 = node(2, 0.5);
t1 = node(3, 0);
t2 = node(4, 0);

seed = randseed;
node.rand_stream(RandStream('mt19937ar', 'Seed', seed));

r1 = router(1, max_q, 0);
r2 = router(2, max_q, 0);

ls1 = link(s1, r1);
ls2 = link(s2, r2);
s1.outport_link = ls1; r1.inport1_link = ls1;
s2.outport_link = ls2; r2.inport1_link = ls2;

r3 = router(3, max_q, 0); r4 = router(4, max_q, 0);

r5 = router(5, max_q, 0); r6 = router(6, max_q, 0);

l13 = link(r1, r3); 
r1.outport1_link = l13; r3.inport1_link = l13;
l14 = link(r1, r4);
r1.outport2_link = l14; r4.inport1_link = l14;

l23 = link(r2, r3);
r2.outport1_link = l23; r3.inport2_link = l23;
l24 = link(r2, r3);
r2.outport2_link = l24; r4.inport2_link = l24;

l35 = link(r3, r5);
r3.outport1_link = l35; r5.inport1_link = l35;
l36 = link(r3, r6);
r3.outport2_link = l36; r6.inport1_link = l36;

l45 = link(r4, r5);
r4.outport1_link = l45; r5.inport2_link = l45;
l46 = link(r4, r6);                           
r4.outport2_link = l46; r6.inport2_link = l46;

lt1 = link(r5, t1);
lt2 = link(r6, t2);

r5.outport1_link = lt1;
r6.outport1_link = lt2;
t1.inlink = lt1;
t2.inlink = lt2;

same_dest_pkt_counter = 0;

for time = 1:10000
    
    %disp(r3.inport1_pkt);
    %disp(r3.inport2_pkt);
    %subslot 1: make control decisions
    %optimal_lb(r1, r2);
    control_optimal_network1(r1,r2,r3,r4);
    control_dst(r3, r4);
    r1.simulate(); r2.simulate(); 
    r3.simulate(); r4.simulate(); 
    r5.simulate(); r6.simulate(); 
    
    %subslot 2: generate/send pkts
    s1.generate_pkt(time);
    s2.generate_pkt(time);
    %if ~isempty(s1.packet()) && ~isempty(s2.packet()) && s1.packet(2) == s2.packet(2) 
    %    same_dest_pkt_counter = same_dest_pkt_counter + 1;
    %end
    s1.send(); s2.send();
    r1.send(); r2.send(); 
    r3.send(); r4.send(); 
    r5.fwd_to_dst(); r6.fwd_to_dst(); 
    
    %subslot 3: receive pkts
    r1.receive(); r2.receive(); 
    r3.receive(); r4.receive(); 
    r5.receive(); r6.receive(); 
    t1.receive(); t2.receive();

end

%disp(r1.cum_drop + r2.cum_drop+ r3.cum_drop+ r4.cum_drop+ r5.cum_drop+ r6.cum_drop +r7.cum_drop + r8.cum_drop);
disp(r1.cum_drop + r2.cum_drop+ r3.cum_drop+ r4.cum_drop+ r5.cum_drop+ r6.cum_drop);
disp(same_dest_pkt_counter);
