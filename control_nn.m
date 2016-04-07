classdef control_nn < handle
    % CONTROL_NN Central contoller class to make NW control decisions using a NN to approximate the Q-function
    
    properties
        net; % Neural NW
        action_size;
        state_size;
        prev_state;
        prev_action;
        cum_reward = 0;
        alpha = 0.9; % Learning rate
        gamma = 0.8; % Discount factor
        epsilon = 1; % Epsilon value for greedy decisions
        min_epsilon = 0.1; % Minimum upto which epsilon is decremented
        epsilon_step; % Epsilon step size
        r_stream; % Stream of random numbers
        learn = 1; % Flag for the state of the learner : 1-learning phase, 0-greedy phase
        R = []; % Replay set
        replay_size; % Max size of the replay set
        sample_size; % Max number of samples used per adapt() call
    end
    
    methods
        function obj = control_nn(hiddenLayerSize, state_size, action_size, eps_step, seed, replay_size, sample_size)
            % Create a Curve Fitting Network with a single hidden layer of size 10 by
            % default. The Neural NW is used in place of the Q(s,a) function
            nn = fitnet(hiddenLayerSize);
            nn.inputs{1}.size = length(state_size);
            nn.layers{size(hiddenLayerSize,2)+1}.size = prod(action_size); % Output layer size
            %net.layers{3}.transferFcn = 'logsig';
            %net.adaptParam.passes = duration;
            nn = setwb(nn, ones(1, 100));
            nn = init(nn);
            nn.trainParam.showWindow=0;
            nn.performParam.regularization = 0.5;
            obj.net = nn;

            obj.state_size = state_size;
            obj.action_size = action_size;
            obj.prev_state = ones(1, length(state_size));
            obj.prev_action = ones(1, length(action_size));
            obj.epsilon_step = eps_step;
            obj.r_stream = RandStream('mt19937ar', 'Seed', seed);
            obj.replay_size = replay_size;
            obj.sample_size = sample_size;
        end
        function obj = reward(obj, r, t)
            rew = reward(r, t) + .98 * obj.cum_reward(end);
            obj.cum_reward = [obj.cum_reward, rew];
        end
        function obj = control(obj, r)
            cur_state = ones(1, length(obj.state_size));
            for i = 1:length(obj.state_size)
                % State depends on only the first routers
                cur_state(i) = r{i}.occupancy();
            end
            % Reward for the previous state & action
            rew = obj.cum_reward(end);
            
            % Compute the Q update using the previous reward
            if obj.learn == 1
                % Add the previous state, action and reward to the replay set
                [rR, ~] = size(obj.R);
                if rR < obj.replay_size
                    rR = rR + 1;
                else
                    % When the Replay set gets too big forget the oldest sample
                    obj.R(1, :) = [];
                end
                obj.R(rR, :) = [obj.prev_state, obj.prev_action, rew];
                
                % Sample some elements of the replay set for learning
                cur_sample_size = min(obj.sample_size, rR);
                target = zeros(4, cur_sample_size);
                if cur_sample_size == rR
                    % Not enough samples so use all in Replay set
                    samples = 1:rR;
                else
                    % Generate random sample indices
                    samples = randi(rR, 1, cur_sample_size);
                end
                
                for i = 1:cur_sample_size
                    j = samples(i);
                    % Calculate the Greedy Q for the next state of jth state
                    sample_state = obj.R(j, 1:4)';
                    sample_action = obj.R(j, 5:6);
                    sample_rew = obj.R(j, 7);
                    if j == rR
                        next_state = cur_state';
                    else
                        next_state = obj.R(j+1, 1:4)';
                    end
                    Q = reshape(obj.net(sample_state), obj.action_size)';
                    greedy_next_Q = max(obj.net(next_state));
                    updated_reward = (1-obj.alpha) * Q(sample_action) + obj.alpha * (sample_rew + obj.gamma * greedy_next_Q);
                    expect = NaN .* ones(obj.action_size);
                    expect(sample_action) = updated_reward;
                    target(:, i) = expect(:);
                end
                
                % Perform learning updates
                obj.net = adapt(obj.net, obj.R(samples, 1:4)', target);
            end
            
            % Choose a new action
            if rand(obj.r_stream) > obj.epsilon
                % Greedy step
                [~, greedy_ij] = max(obj.net(cur_state'));
                [control1, control2] = ind2sub(obj.action_size, greedy_ij);
            else
                % Random step
                control1 = randi(obj.action_size(1));
                control2 = randi(obj.action_size(2));
            end
            r{1}.next_hop = control1;
            r{2}.next_hop = control2;
                
            % State current state as previous for next round
            obj.prev_state = cur_state;
            obj.prev_action = [control1, control2];
			obj.epsilon = max(obj.min_epsilon, obj.epsilon - obj.epsilon_step);
        end
    end
end