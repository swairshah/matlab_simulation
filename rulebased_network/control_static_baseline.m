function [] = control_static_baseline(r1, r2, r3, r4, r5, r6)
    r1.fwd_rules = [0 1; 0 0];
    r2.fwd_rules = [0 1; 0 1];
    r3.fwd_rules = [0 1; 1 1];
    r4.fwd_rules = [0 0; 1 1];
    r5.fwd_rules = [0 1; 0 1];
    r6.fwd_rules = [0 1; 0 1];
end
