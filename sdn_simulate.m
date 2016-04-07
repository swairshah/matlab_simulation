function [cum_drops, avg_delays] = sdn_simulate(duration, loads, controller, buffers, delays, seed)
cum_drops = zeros(1, length(loads));
avg_delays = zeros(1, length(loads));

% Initialize the SDN
[s, t, r] = sdn_init(buffers, delays);

% Use the same stream for all packet generation
node.rand_stream(RandStream('mt19937ar', 'Seed', seed));
time = 1;
for l = 1:length(loads)
    % Set the packet generation loads
    for i = 1:length(s)
        s{i}.load = loads(l);
    end
    
    for time_loop = 1:duration
        % Process a single step of packet forwarding at every router
        sdn_step(controller, s, r, t, time);
        
        time=time+1;
    end
    
    % Calculate cumulative drop for this load
    cum_drop = 0;
    for i = 1:length(r)
        cum_drop = cum_drop + r{i}.cum_drop;
    end
    cum_drops(l) = cum_drop;
    % Calculate average delay for this load
    cum_delay = 0;
    pkt_count = 0;
    for i = 1:length(t)
        cum_delay = cum_delay + t{i}.cum_delay;
        pkt_count = pkt_count + t{i}.pkt_count;
    end
    avg_delay = cum_delay / pkt_count;
    avg_delays(l) = avg_delay;
    
    % Clear the drops & delays at nodes & routers for next load. The buffers queues are maintained though.
    for i = 1:length(r)
        r{i}.clear();
    end
    for i = 1:length(t)
        t{i}.clear();
    end
end
end


function sdn_step(controller,s, r, t, time)
% Inter-slot: make control decisions
controller.control(r);
for i=1:length(r)
    r{i}.control();
end

% Sub-slot 1: generate/send packets
s{1}.generate_pkt(time);
s{2}.generate_pkt(time);
for i=1:length(r)
    r{i}.send();
end

% Sub-slot 2: receive packets
for i=1:length(r)
    r{i}.receive();
end
for i = 1:length(t)
    t{i}.receive(time);
end

% Calculate the reward of this time step
controller.reward(r, t);
end