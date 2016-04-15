classdef control_base < handle
    %CONTROL_OPT Baseline controller
    
    properties
        cum_reward = [0, 0];
    end
    
    methods
        function obj = reward(obj, r, t)
            rew = reward(r, t) + .98 * obj.cum_reward(end);
            obj.cum_reward = [obj.cum_reward, rew];
        end
        
        function obj = control(obj, r)
            for i = 1:2
                obj.control_lb(r{i});
            end
            for i = 3:4
                obj.control_dst(r{i});
            end
            for i = 5:6
                obj.forward_dst(r{i});
            end
        end
        
        function obj = control_lb(obj, router)
            router.inport1_control = ~(router.inport1_control - 1) + 1;
            router.inport2_control = ~(router.inport2_control - 1) + 1;
        end
        
        function obj = control_dst(obj, router)
            % if pkt dst = 1, control = 1 (send to top outport queue)
            % else if pkt dst = 2 control = 2 (send to bottom outport queue)
            if ~isempty(router.inport1_pkt)
                router.inport1_control =  router.inport1_pkt(2);
            end
            if ~isempty(router.inport2_pkt)
                router.inport2_control =  router.inport2_pkt(2);
            end
        end
        
        function obj = forward_dst(obj, router)
            % if pkt dst = 1, control = 1 (send to top outport queue)
            % else if pkt dst = 2 control = 2 (send to bottom outport queue)
            pkt = router.inport1_pkt;
            if ~isempty(pkt) && pkt(2)==router.outport1_link.next.id
                router.inport1_control =  1;
            else
                router.inport1_control =  0;
            end
            pkt = router.inport2_pkt;
            if ~isempty(pkt) && pkt(2)==router.outport1_link.next.id
                router.inport2_control =  1;
            else
                router.inport2_control =  0;
            end
        end
        
        function obj = clear(obj)
            obj.cum_reward = [0, 0];
        end
    end
end