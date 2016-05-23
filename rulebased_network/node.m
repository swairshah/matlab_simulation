classdef node < handle
    %NODE Source/Destination nodes in a NW
    
    properties
        id; % Node id
        load; % Packet generation probability
        nodes = {}; % List of source/destination routers known to this node
        router; % Previous/next hop router
        packet = []; % Packet generatated/received at the current time stamp
        outport_link;
        cur_delay; % Delay of the current received packet
        cum_delay = 0; % Cumulative delay of the packets received
        pkt_count = 0; % Number of packets transmitted/received
        inlink;
        inq;
    end
    
    methods (Static)
        function r_stream = rand_stream(arg)
            persistent stream;
            if nargin
                stream = arg;
            end
            r_stream = stream;
        end
    end
    
    methods
        function obj = node(id, load)
            obj.id = id;
            obj.load = load;
        end
        function obj = connect_node(obj, node)
            obj.nodes = [obj.nodes, {node}];
        end
        function obj = connect_router(obj, router)
            obj.router = router;
        end
        function obj = enqueue(obj, pkt)
            obj.packet = pkt;
        end
        function obj = send(obj)
            if ~isempty(obj.packet)
                obj.outport_link.receive(obj.packet);
                obj.packet = [];
            end
        end
        
        %function obj = receive(obj, cur_time)
        %    if ~isempty(obj.packet)
        %        obj.cur_delay = cur_time - obj.packet(3);
        %        obj.cum_delay = obj.cum_delay + obj.cur_delay;
        %        obj.pkt_count = obj.pkt_count + 1;
        %        obj.packet = [];
        %    else
        %        obj.cur_delay = 0;
        %    end
        %end
        
        function obj = receive(obj)
            if ~isempty(obj.inlink) && ~isempty(obj.inlink.q)
                inpkt = obj.inlink.q(:,1);
                inpkt(4) = 0; %reset the delay
                obj.inq = [obj.inq, inpkt];
                obj.inlink.q(:,1) = [];
            end 
        end
        
        function pkt = generate_pkt(obj, cur_time)
            if rand(node.rand_stream) <= obj.load
                %dest = randi(node.rand_stream, length(obj.nodes));
                dest = randi(node.rand_stream, 2);
                pkt = [obj.id; dest; cur_time; 0];
                obj.packet = pkt;
            end
        end
        function obj = clear(obj)
            obj.packet = [];
            obj.cur_delay = 0;
            obj.cum_delay = 0;
            obj.pkt_count = 0;
        end
    end
end
