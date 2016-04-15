function [] = optimal_lb(varargin)
    for i = 1:length(varargin)
        flip_control(varargin{i});
    end
    function [] = flip_control(router)
        if ~isempty(router.inport1_pkt)
            router.inport1_control = ~router.inport1_control;
        end

        if ~isempty(router.inport2_pkt)
            router.inport2_control = ~router.inport2_control;
        end
    end
end
