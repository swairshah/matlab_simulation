function [] = control_globalopt(r1, r2, r3, r4, r5, r6)
    % decision to be taken for r1, r2, r3, r4.
    % r5 and r6 are passed just for the queue information

    r5_top = length(r5.outport1_q); r5_bottom = length(r5.outport2_q);
    r6_top = length(r6.outport1_q); r6_bottom = length(r6.outport2_q);
    r3_top = length(r3.outport1_q); r3_bottom = length(r3.outport2_q);
    r4_top = length(r4.outport1_q); r4_bottom = length(r4.outport2_q);
    r1_top = length(r1.outport1_q); r1_bottom = length(r1.outport2_q);
    r2_top = length(r2.outport1_q); r2_bottom = length(r2.outport2_q);

    % decision for r3.inport1_control
    if ~isempty(r3.inport1_pkt)

    if r3.inport1_pkt r3.inport1_pkt(2) == 1 %dst is r7
        if min([r3_top, r5_top]) > min([r3_bottom, r6_top])
            r3.inport1_control = 1; % prefer r6
            % this causes r3_bottom to increase
            r3_bottom = r3_bottom + 1;
        else
            r3_inport1_control = 0; %prefer r5
            r3_top = r3_top + 1;
        end

    else % dest is r8
        if min([r3_top, r5_bottom]) > min([r3_bottom, r6_bottom])
            r3.inport1_control = 1;
            r3_bottom = r3_bottom + 1;
        else 
            r3.inport1_control = 0;
            r3_top = r3_top + 1;
        end
    end
    
    end

    %decision for r3.inport2_control
    if ~isempty(r3.inport2_pkt)
    if r3.inport2_pkt(2) == 1
         if min([r3_top, r5_top]) > min([r3_bottom, r6_top])
            r3.inport2_control = 1; % prefer r6
            % this causes r3_bottom to increase
            r3_bottom = r3_bottom + 1;
        else
            r3_inport2_control = 0; %prefer r5
            r3_top = r3_top + 1;
        end
    else % dest is r8
        if min([r3_top, r5_bottom]) > min([r3_bottom, r6_bottom])
            r3.inport2_control = 1;
            r3_bottom = r3_bottom + 1;
        else 
            r3.inport2_control = 0;
            r3_top = r3_top + 1;
        end
    end
    end

    % decision for r4.inport1_control
    if ~isempty(r4.inport1_pkt)
    if r4.inport1_pkt(2) == 1
        if min([r4_top, r5_top]) > min([r4_bottom, r6_top])
            r4.inport1_control = 2;
            r4_bottom = r4_bottom + 1;
        else
            r4.inport1_control = 1;
            r4_top = r4_top + 1;
        end
    else %dest is r8
        if min([r4_bottom, r6_bottom]) < min([r4_top, r5_bottom])
            r4.inport1_control = 2;
            r4_bottom = r4_bottom + 1;
        else
            r4.inport1_control = 1;
            r4_top = r4_top + 1;
        end
    end
    end

    %decision for r4.inport2_control
    if ~isempty(r4.inport2_pkt)
    if r4.inport2_pkt(2) == 1
        if min([r4_top, r5_top]) > min([r4_bottom, r6_top])
            r4.inport2_control = 2;
            r4_bottom = r4_bottom + 1;
        else
            r4.inport2_control = 1;
            r4_top = r4_top + 1;
        end
    else %dest is t2/r8
        if min([r4_bottom, r6_bottom]) < min([r4_top, r5_bottom])
            r4.inport2_control = 2;
            r4_bottom = r4_bottom + 1;
        else
            r4.inport2_control = 1;
            r4_top = r4_top + 1;
        end
    end
    end

    %%%%%r1 

    %r1 inport1_control
    % paths to dst t1 
    % [r1_top, r3_top, r5_top]
    % [r1_top, r3_bottom, r6_top]
    % [r1_bottom, r4_top, r5_top]
    % [r1_bottom, r4_bottom, r6_top]

    %paths to dst t2
    % [r1_top, r3_top, r5_bottom]
    % [r1_top, r3_bottom, r6_bottom]
    % [r1_bottom, r4_top, r5_bottom]
    % [r1_bottom, r4_bottom, r6_bottom]

    if ~isempty(r1.inport1_pkt)
    if r1.inport1_pkt(2) == 1
        t1_top_min = min(min([r1_top, r3_top, r5_top]), min([r1_top, r3_bottom, r6_top]));
        t1_bottom_min = min(min([r1_bottom, r4_top, r5_top]), min([r1_bottom, r4_bottom, r6_top]));
        if t1_bottom_min < t1_top_min
            r1.inport1_control = 2;
            r1_bottom = r1_bottom + 1;
        else
            r1.inport1_control = 1;
            r1_top = r1_top + 1;
        end
    else %dest is t2
        t2_top_min = min(min([r1_top, r3_top, r5_bottom]), min([r1_top, r3_bottom, r6_bottom]));
        t2_bottom_min = min(min([r1_bottom, r4_top, r5_bottom]), min([r1_bottom, r4_bottom, r6_bottom]));
        if t2_bottom_min < t2_top_min
            r1.inport1_control = 2;
            r1_bottom = r1_bottom + 1;
        else
            r1.inport1_control = 1;
            r1_top = r1_top + 1;
        end
    end
    end
    
    if ~isempty(r1.inport2_pkt)
    if r1.inport2_pkt(2) == 1
        t1_top_min = min(min([r1_top, r3_top, r5_top]), min([r1_top, r3_bottom, r6_top]));
        t1_bottom_min = min(min([r1_bottom, r4_top, r5_top]), min([r1_bottom, r4_bottom, r6_top]));
        if t1_bottom_min < t1_top_min
            r1.inport2_control = 2;
            r1_bottom = r1_bottom + 1;
        else
            r1.inport2_control = 1;
            r1_top = r1_top + 1;
        end
    else %dest is t2
        t2_top_min = min(min([r1_top, r3_top, r5_bottom]), min([r1_top, r3_bottom, r6_bottom]));
        t2_bottom_min = min(min([r1_bottom, r4_top, r5_bottom]), min([r1_bottom, r4_bottom, r6_bottom]));
        if t2_bottom_min < t2_top_min
            r1.inport2_control = 2;
            r1_bottom = r1_bottom + 1;
        else
            r1.inport2_control = 1;
            r1_top = r1_top + 1;
        end
    end
    end

    %r2
    
    if ~isempty(r2.inport1_pkt)
    if r2.inport1_pkt(2) == 1
        t1_top_min = min(min([r2_top, r3_top, r5_top]), min([r2_top, r3_bottom, r6_top]));
        t1_bottom_min = min(min([r2_bottom, r4_top, r5_top]), min([r2_bottom, r4_bottom, r6_top]));
        if t1_bottom_min < t1_top_min
            r2.inport1_control = 2;
            r2_bottom = r2_bottom + 1;
        else
            r2.inport1_control = 1;
            r2_top = r2_top + 1;
        end
    else %dest is t2
        t2_top_min = min(min([r2_top, r3_top, r5_bottom]), min([r2_top, r3_bottom, r6_bottom]));
        t2_bottom_min = min(min([r2_bottom, r4_top, r5_bottom]), min([r2_bottom, r4_bottom, r6_bottom]));
        if t2_bottom_min < t2_top_min
            r2.inport1_control = 2;
            r2_bottom = r2_bottom + 1;
        else
            r2.inport1_control = 1;
            r2_top = r2_top + 1;
        end
    end
    end
   
    if ~isempty(r2.inport2_pkt)
    if r2.inport2_pkt(2) == 1
        t1_top_min = min(min([r2_top, r3_top, r5_top]), min([r2_top, r3_bottom, r6_top]));
        t1_bottom_min = min(min([r2_bottom, r4_top, r5_top]), min([r2_bottom, r4_bottom, r6_top]));
        if t1_bottom_min < t1_top_min
            r2.inport2_control = 2;
            r2_bottom = r2_bottom + 1;
        else
            r2.inport2_control = 1;
            r2_top = r2_top + 1;
        end
    else %dest is t2
        t2_top_min = min(min([r2_top, r3_top, r5_bottom]), min([r2_top, r3_bottom, r6_bottom]));
        t2_bottom_min = min(min([r2_bottom, r4_top, r5_bottom]), min([r2_bottom, r4_bottom, r6_bottom]));
        if t2_bottom_min < t2_top_min
            r2.inport2_control = 2;
            r2_bottom = r2_bottom + 1;
        else
            r2.inport2_control = 1;
            r2_top = r2_top + 1;
        end
    end
    end

end
