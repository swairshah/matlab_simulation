function sdn_compare(duration, batch_count, loads, buffers, delays, base, q, nn)
% Use the same seed for all packet generation
seed = randseed;

batches = [];
for load = loads
    batches = [batches, load * ones(1, batch_count)];
end
% Run the simulations
q.learn = 0;
nn.learn = 0;
q.clear();
nn.clear();
[drop_b, delay_b] = sdn_simulate(duration, batches, base, buffers, delays, seed);
[drop_q, delay_q] = sdn_simulate(duration, batches, q, buffers, delays, seed);
[drop_n, delay_n] = sdn_simulate(duration, batches, nn, buffers, delays, seed);

% Negelect the initial zero reward
total_duration = size(base.cum_reward, 2)-1;
min_reward = min([min(base.cum_reward), min(q.cum_reward), min(nn.cum_reward)]);

figure('name', 'Best Of All');
subplot(2, 3, 1);
plot(0:total_duration, base.cum_reward);
title(strcat('Buffers-[', sprintf('%d,', buffers), '], Delays-[', sprintf('%d,', delays), '], Baseline'));
xlabel('Time');
ylabel('Reward');
axis([0, total_duration, min_reward, 0])

subplot(2, 3, 2);
plot(0:total_duration, q.cum_reward);
title('Q-controller');
xlabel('Time');
ylabel('Reward');
axis([0, total_duration, min_reward, 0])

subplot(2, 3, 3);
plot(0:total_duration, nn.cum_reward);
title('NN-controller');
xlabel('Time');
ylabel('Reward');
axis([0, total_duration, min_reward, 0])

x_value = 1:length(batches);
x_label = 'Time';
max_drop = max([max(drop_b), max(drop_q), max(drop_n)]);
max_delay = max([max(delay_b), max(delay_q), max(delay_n)]);

subplot(2, 3, 4);
h = plotyy(x_value, drop_b, x_value, delay_b);
title('Baseline');
xlabel(x_label);
ylabel(h(1),'Drops');
ylabel(h(2),'Avg Delay');
axis(h(1), [0, length(batches), 0, max_drop]);
axis(h(2), [0, length(batches), 0, max_delay]);
h(1).XTick = 0:batch_count:length(batches);
h(1).XTickLabel = [loads, 0];

subplot(2, 3, 5);
h = plotyy(x_value, drop_q, x_value, delay_q);
title('Q-controller');
xlabel(x_label);
ylabel(h(1),'Drops');
ylabel(h(2),'Avg Delay');
axis(h(1), [0, length(batches), 0, max_drop]);
axis(h(2), [0, length(batches), 0, max_delay]);
h(1).XTick = 0:batch_count:length(batches);
h(1).XTickLabel = [loads, 0];

subplot(2, 3, 6);
h = plotyy(x_value, drop_n, x_value, delay_n);
title('NN-controller');
xlabel(x_label);
ylabel(h(1),'Drops');
ylabel(h(2),'Avg Delay');
axis(h(1), [0, length(batches), 0, max_drop]);
axis(h(2), [0, length(batches), 0, max_delay]);
h(1).XTick = 0:batch_count:length(batches);
h(1).XTickLabel = [loads, 0];

savefig(sprintf('[%s], [%s], [%s].fig', sprintf('%d,', buffers), sprintf('%d,', delays), sprintf('%.2f,', loads)));
end