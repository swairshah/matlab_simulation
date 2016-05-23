classdef router < handle
    properties
        id; % Router id
        max_q; % Maximum queue size
        neighbors = {}; % List of next hop routers
        inport1_pkt = [];
        inport2_pkt = [];
        %inport1_control = 0; %send to outport1_q
        %inport2_control = 1; %send to outport2_q

        % fwd_rules is a binary matrix
        % each entry is 0 or 1, 0 for fwd to top, 1 for bottom
        % fwd_rules(i,j) denotes rule for packet with source i dst j
        fwd_rules = [0 0; 0 0];

        inport1_link = [];
        inport2_link = [];
        outport1_q;
        outport2_q;
        outport1_link;
        outport2_link;
        node; % Next hop node set by the central controller
        delay; % Processing delay
        cum_drop = 0; % Cumulative packet drop count at this router
        cur_drop = 0; % Numnber of packets dropped at this router in this time stamp
        q1_hist = 0; % array of queue length histories e.g. [1,2,1,3..] ,
                     % to be reset whenever the controller/main loop wants to sample
        q2_hist = 0;
    end
    
    methods
        function obj = router(id, max_q, delay)
            obj.id = id;
            obj.max_q = max_q;
            obj.delay = delay;
        end
        function obj = connect_router(obj, router)
            obj.neighbors = [obj.neighbors, {router}];
        end
        function obj = connect_node(obj, node)
            obj.node = node;
        end
        function ratio = occupancy(obj)
            ratio = size(obj.q, 2) / obj.max_q;
        end

        function obj = reset_delay(obj, pkt)
            pkt(4) = 0;
        end
        
        function obj = increment_delays(obj)
            if ~isempty(obj.outport1_q)
                obj.outport1_q(4,1) = obj.outport1_q(4,1) + 1;
            end
            if ~isempty(obj.outport2_q)
                obj.outport2_q(4,1) = obj.outport2_q(4,1) + 1;
            end
        end

        function obj = send(obj)
            if ~isempty(obj.outport1_q) 
                pkt = obj.outport1_q(:,1); 
                if pkt(4) >= obj.delay
                    obj.outport1_q(:,1) = [];
                    obj.outport1_link.receive(pkt);
                end
            end
            if ~isempty(obj.outport2_q) 
                pkt = obj.outport2_q(:,1); 
                if pkt(4) >= obj.delay
                    obj.outport2_q(:,1) = [];
                    obj.outport2_link.receive(pkt);
                end
            end
        end

        function obj = fwd_to_dst(obj)
            if ~isempty(obj.outport1_q)
                pkt = obj.outport1_q(:,1); 
                obj.outport1_q(:,1) = [];
                obj.outport1_link.receive(pkt);
            end
        end

        function obj = receive(obj)
            if ~isempty(obj.inport1_link) && ~isempty(obj.inport1_link.q)
                obj.inport1_pkt = obj.inport1_link.q(:,1);
                obj.inport1_pkt(4) = 0; %reset the delay
                obj.inport1_link.q(:,1) = [];
            end 
            if ~isempty(obj.inport2_link) && ~isempty(obj.inport2_link.q)
                obj.inport2_pkt = obj.inport2_link.q(:,1);
                obj.inport2_pkt(4) = 0; %reset the delay
                obj.inport2_link.q(:,1) = [];
            end 
        end

        function obj = simulate(obj)
            if ~isempty(obj.inport1_pkt)
                pkt = obj.inport1_pkt;
                obj.inport1_pkt = [];
                % check if fwd_rules(src,dst) says top (0) or bottom(1)
                if obj.fwd_rules(pkt(1),pkt(2)) == 0
                    obj.outport1_q = [obj.outport1_q, pkt];
                else 
                    obj.outport2_q = [obj.outport2_q, pkt];
                    obj.inport1_pkt = [];
                end
            end
            if ~isempty(obj.inport2_pkt)
                pkt = obj.inport2_pkt;
                obj.inport2_pkt = [];

                % check if fwd_rules(src,dst) says top (0) or bottom(1)
                if obj.fwd_rules(pkt(1),pkt(2)) == 0
                    obj.outport1_q = [obj.outport1_q, pkt];
                    obj.inport2_pkt = [];
                else 
                    obj.outport2_q = [obj.outport2_q, pkt];
                    obj.inport2_pkt = [];
                end
            end
            obj.drop();
            obj.increment_delays();
        end
		function obj = drop(obj)
			overflow = size(obj.outport1_q, 2) - obj.max_q;
            if overflow > 0
                obj.cur_drop = overflow;
                obj.cum_drop = obj.cum_drop + overflow;
                obj.outport1_q(:, obj.max_q+1:end) = []; % remove overflow pkts from outport q
            else
                obj.cur_drop = 0;
			end

            overflow = size(obj.outport2_q, 2) - obj.max_q;
            if overflow > 0
                obj.cur_drop = overflow;
                obj.cum_drop = obj.cum_drop + overflow;
                obj.outport2_q(:, obj.max_q+1:end) = []; % remove overflow pkts from outport q
            else
                obj.cur_drop = 0;
			end
		end

        function obj = update_q_history(obj)
            obj.q1_hist = [obj.q1_hist,size(obj.outport1_q, 2)]
            obj.q2_hist = [obj.q2_hist,size(obj.outport2_q, 2)]
        end

        function obj = clear(obj)
            obj.cur_drop = 0;
            obj.cum_drop = 0;
        end

        function obj = clear_hist(obj)
            obj.q1_hist = [];
            obj.q2_hist = [];
        end
    end
end
