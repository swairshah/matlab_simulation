classdef link < handle
    % link is a directional link 
    properties
        id
        prev % router that sends packets to the link
        next % link sends packets to this router
        q % since links are fifo, packets sent to it are in a q (size is unbounded)
    end
    
    methods
        function obj = link(prev, next)
            obj.prev = prev;
            obj.next = next;
        end

        function obj = prev_router(obj, router)
            obj.prev = router;
        end

        function obj = next_router(obj, router)
            obj.next = router;
        end

        function obj = receive(obj, pkt)
            obj.q = pkt;
        end
    end
end

