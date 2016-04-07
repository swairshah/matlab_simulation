function best_nn = sdn_best_nn(duration, N, batch, loads, hiddenLayerSize, buffers, delays, pkt_size, action_size, epsilon_step, replay_size, sample_size)
% Use the same seed for all packet generation
pkt_seed = randseed;
% Use the same seed for all random decisions
dec_seed = randseed;

switch 1
    case N <= 3
        rows = 1;
    case N <= 9
        rows = 2;
    case N <= 17
        rows = 3;
    otherwise
        rows = 4;
end
cols = ceil((N)/rows);

load = loads;
if size(loads, 2) == 1
    load = ones(1, batch) * loads;
end

best_mean = -Inf;
best_nn = [];
figure('name', 'NN Candidates');
for n = 1:N
    % Create a new NN-controller
    state_size=[];
    for i=1:6
        state_size=[state_size buffers(i) buffers(i)];
    end
    nn = control_nn(hiddenLayerSize, state_size, pkt_size, action_size, epsilon_step, dec_seed, replay_size, sample_size);
    
    % Run the simulations
    sdn_simulate(duration, load, nn, buffers, delays, pkt_seed);
    
    cur_mean = mean(nn.cum_reward);
    if cur_mean > best_mean
        best_nn = nn;
        best_mean = cur_mean;
    end
    
    subplot(rows, cols, n);
    plot(nn.cum_reward);
    title(strcat('Candidate-', num2str(n)));
    xlabel('Time');
    ylabel('Reward');
    if n == 1
        title(sprintf('Same packets, n-[%s], e-1/%d, r-%d, s-%d', sprintf('%d,', hiddenLayerSize), 1/epsilon_step, replay_size, sample_size));
    end
end

savefig(sprintf('[%s], [%s], [%s], %d-%d.fig', sprintf('%d,', buffers), sprintf('%d,', delays), sprintf('%d,', hiddenLayerSize), sample_size, replay_size));
end