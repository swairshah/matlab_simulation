classdef router < handle
    properties
        id; % Router id
        max_q; % Maximum queue size
        inport1_pkt = [];
        inport2_pkt = [];
        inport1_control = 0; %send to outport1_q
        inport2_control = 0; %send to outport2_q
        inport1_link = [];
        inport2_link = [];
        outport1_q;
        outport2_q;
        outport1_link;
        outport2_link;
        delay; % Processing delay
        cum_drop = 0; % Cumulative packet drop count at this router
        cur_drop = 0; % Numnber of packets dropped at this router in this time stamp
    end
    
    methods
        function obj = router(id, max_q, delay)
            obj.id = id;
            obj.max_q = max_q;
            obj.delay = delay;
        end

        function ratio = ocp_ratio(obj)
			ratio = obj.ocp_size() / obj.max_q;
            ratio(1) = size(obj.outport1_q, 2) / obj.max_q;
            ratio(2) = size(obj.outport2_q, 2) / obj.max_q;
        end

        function ratio = ocp_size(obj)
            ratio(1) = size(obj.outport1_q, 2);
            ratio(2) = size(obj.outport2_q, 2);
        end
        
        function obj = increment_delays(obj)
            if ~isempty(obj.outport1_q)
                obj.outport1_q(4,:) = obj.outport1_q(4,:) + 1;
            end
            if ~isempty(obj.outport2_q)
                obj.outport2_q(4,:) = obj.outport2_q(4,:) + 1;
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

        function obj = control(obj)
            obj.increment_delays();
            obj.cur_drop = 0;
            if ~isempty(obj.inport1_pkt)
                if obj.inport1_control == 1
                    obj.outport1_q = [obj.outport1_q, obj.inport1_pkt];
                    obj.inport1_pkt = [];
                elseif obj.inport1_control == 2
                    obj.outport2_q = [obj.outport2_q, obj.inport1_pkt];
                    obj.inport1_pkt = [];
                else
                    obj.inport1_pkt = [];
					obj.cur_drop = obj.cur_drop + 1; % drop because of unknown destinations
                    obj.cum_drop = obj.cum_drop + 1;
                end
            end
            if ~isempty(obj.inport2_pkt)
                if obj.inport2_control == 1
                    obj.outport1_q = [obj.outport1_q, obj.inport2_pkt];
                    obj.inport2_pkt = [];
                elseif obj.inport2_control == 2
                    obj.outport2_q = [obj.outport2_q, obj.inport2_pkt];
                    obj.inport2_pkt = [];
                else
                    obj.inport2_pkt = [];
					obj.cur_drop = obj.cur_drop + 1; % drop because of unknown destinations
                    obj.cum_drop = obj.cum_drop + 1;
                end
            end
            obj.drop();
        end

		function obj = drop(obj)
            overflow = size(obj.outport1_q, 2) - obj.max_q;
            if overflow > 0
                obj.cur_drop = obj.cur_drop + overflow;
                obj.cum_drop = obj.cum_drop + overflow;
                obj.outport1_q(:, obj.max_q+1:end) = []; % remove overflow pkts from outport q
            end

            overflow = size(obj.outport2_q, 2) - obj.max_q;
            if overflow > 0
                obj.cur_drop = obj.cur_drop + overflow;
                obj.cum_drop = obj.cum_drop + overflow;
                obj.outport2_q(:, obj.max_q+1:end) = []; % remove overflow pkts from outport q
            end
		end

        function obj = clear(obj)
            obj.cur_drop = 0;
            obj.cum_drop = 0;
        end
    end
end
