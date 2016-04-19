function [] = control_globalopt(r1, r2, r3, r4)
    % decision to be taken for r1, r2

    r3_top = length(r3.outport1_q); r3_bottom = length(r3.outport2_q);
    r4_top = length(r4.outport1_q); r4_bottom = length(r4.outport2_q);
    r1_top = length(r1.outport1_q); r1_bottom = length(r1.outport2_q);
    r2_top = length(r2.outport1_q); r2_bottom = length(r2.outport2_q);

    if ~isempty(r1.inport1_pkt)
    if r1.inport1_pkt(2) == 1 %dst is r5
        if r4_top < r3_top
            r1.inport1_control = 1;
            r4_top = r4_top + 1;
        else
            r1.inport1_control = 0;
            r3_top = r3_top + 1;
        end
    else %dst is r6
        if r4_bottom < r3_bottom
            r1.inport1_control = 1;
            r4_bottom = r4_bottom + 1;
        else
            r1.inport1_control = 0;
            r3_bottom = r3_bottom + 1;
        end

    end
    end

    if ~isempty(r1.inport2_pkt)
    if r1.inport2_pkt(2) == 1 %dst is r5
        if r4_top < r3_top
            r1.inport2_control = 1;
            r4_top = r4_top + 1;
        else
            r1.inport2_control = 0;
            r3_top = r3_top + 1;
        end
    else %dst is r6
        if r4_bottom < r3_bottom
            r1.inport2_control = 1;
            r4_bottom = r4_bottom + 1;
        else
            r1.inport2_control = 0;
            r3_bottom = r3_bottom + 1;
        end

    end
    end

    %r2 

    if ~isempty(r2.inport1_pkt)
    if r2.inport1_pkt(2) == 1 %dst is r5
        if r4_top < r3_top
            r2.inport1_control = 1;
            r4_top = r4_top + 1;
        else
            r2.inport1_control = 0;
            r3_top = r3_top + 1;
        end
    else %dst is r6
        if r4_bottom < r3_bottom
            r2.inport1_control = 1;
            r4_bottom = r4_bottom + 1;
        else
            r2.inport1_control = 0;
            r3_bottom = r3_bottom + 1;
        end

    end
    end

    if ~isempty(r2.inport2_pkt)
    if r2.inport2_pkt(2) == 1 %dst is r5
        if r4_top < r3_top
            r2.inport2_control = 1;
            r4_top = r4_top + 1;
        else
            r2.inport2_control = 0;
            r3_top = r3_top + 1;
        end
    else %dst is r6
        if r4_bottom < r3_bottom
            r2.inport2_control = 1;
            r4_bottom = r4_bottom + 1;
        else
            r2.inport2_control = 0;
            r3_bottom = r3_bottom + 1;
        end

    end
    end

end
