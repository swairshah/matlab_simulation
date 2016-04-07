function [] = control_optimal(varargin)
    for i = 1:length(varargin)
        send_to_shorter_q(varargin{i});
    end
    function [] = send_to_shorter_q(router)
        len_1 = length(router.outport1_q);
        len_2 = length(router.outport2_q);
        if len_1 < len_2
            inport1_control = 0;
            len_1 = len_1 + 1;
        else
            inport1_control = 1;
            len_2 = len_2 + 1;
        end

        if len_1 < len_2
            inport2_control = 0;
        else
            inport2_control = 1;
        end
    end
end
