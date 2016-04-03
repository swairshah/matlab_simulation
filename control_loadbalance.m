function [] = control_loadbalance(varargin)
    for i = 1:length(varargin)
        flip_control(varargin{i});
    end
    function [] = flip_control(router)
        router.inport1_control = ~router.inport1_control;
        router.inport2_control = ~router.inport2_control;
    end
end
