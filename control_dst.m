function [] = control_dst(varargin)
    for i = 1:length(varargin)
        route_to_dst(varargin{i});
    end
    function [] = route_to_dst(router)
        % if pkt dst = 1, control = 0 (send to top outport queue)
        % else if pkt dst = 2 control = 1 (send to bottom outport queue)
        if ~isempty(router.inport1_pkt)
            router.inport1_control =  router.inport1_pkt(2) - 1;
        end
        if ~isempty(router.inport2_pkt)
            router.inport2_control =  router.inport2_pkt(2) - 1;
        end
    end
end
