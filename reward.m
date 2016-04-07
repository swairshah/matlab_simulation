% Calculate the reward for the previous state & action
function rew = reward(r, t)
% Penalty for a packet drop
drop_penalty = -100;
% Penalty for the time delay
delay_penalty = -1;

% Drop caused by the previous decision
cum_drop = 0;
for i = 1:length(r)
    cum_drop = cum_drop + r{i}.cur_drop;
end
rew = drop_penalty * cum_drop;

% Delay caused by the second previous decision
cum_delay = 0;
for i = 1:length(t)
    cum_delay = cum_delay + t{i}.cur_delay;
end
rew = rew + delay_penalty * cum_delay;
end