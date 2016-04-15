classdef control_nn < handle
    % CONTROL_NN Central contoller class to make NW control decisions using a NN to approximate the Q-function
    
    properties
        net; % Neural NW
        state_size;
        action_size;
        input_size;
        output_size;
		action_length;
        prev_state;
        prev_action;
        cum_reward = [0, 0];
        alpha = 0.9; % Learning rate
        gamma = 0.8; % Discount factor
        epsilon = 1; % Epsilon value for greedy decisions
        min_epsilon = 0.1; % Minimum upto which epsilon is decremented
        epsilon_step; % Epsilon step size
        r_stream; % Stream of random numbers
        learn = 1; % Flag for the state of the learner : 1-learning phase, 0-greedy phase
        R; % Replay set
        replay_size; % Max size of the replay set
        sample_size; % Max number of samples used per adapt() call
    end

	methods (Static)
		function dest = destination(pkt)
			dest = 0;
			if ~isempty(pkt)
				dest = pkt(2);
			end
		end
	end
    
    methods
        function obj = control_nn(hiddenLayerSize, buffer_size, pkt_size, action_size, eps_step, seed, replay_size, sample_size)
            obj.state_size = [buffer_size, pkt_size];
            obj.action_size = action_size;
			obj.input_size = length(obj.state_size);
			obj.output_size = prod(action_size);
			obj.action_length = length(action_size);

            % Create a Curve Fitting Network with a single hidden layer of size 10 by
            % default. The Neural NW is used in place of the Q(s,a) function
            nn = fitnet(hiddenLayerSize);
            nn.inputs{1}.size = obj.input_size;
            nn.layers{size(hiddenLayerSize,2)+1}.size = obj.output_size; % Output layer size
            %net.layers{3}.transferFcn = 'logsig';
            %net.adaptParam.passes = duration;
            nn = setwb(nn, ones(1, 1200));
            nn = init(nn);
            nn.trainParam.showWindow=0;
            nn.performParam.regularization = 0.5;
            obj.net = nn;

            obj.prev_state = ones(obj.input_size, 1);
            obj.prev_action = ones(obj.action_length, 1);
            obj.epsilon_step = eps_step;
            obj.r_stream = RandStream('mt19937ar', 'Seed', seed);
            obj.R = zeros(obj.input_size+obj.action_length+1, 0);
            obj.replay_size = replay_size;
            obj.sample_size = sample_size;
        end

        function obj = reward(obj, r, t)
            rew = reward(r, t) + .98 * obj.cum_reward(end);
            obj.cum_reward = [obj.cum_reward, rew];
        end

		function cur_state = current_state(obj, r)
            cur_state = ones(obj.input_size, 1);
			j = 1;
            for i = 1:4
				% 2 output queues each for routers r1 through r4
                cur_state(j:j+1) = r{i}.ocp_size();
				j = j + 2;
            end
            for i = 5:6
				% 1 output queue each for routers r5 & r6
                cur_state(j) = size(r{i}.outport1_q, 2);
				j = j + 1;
            end
            for i = 1:2
				% 1 input link each for routers r1 & r2
                cur_state(j) = obj.destination(r{i}.inport1_pkt);
				j = j + 1;
            end
            for i = 3:4
				% 2 input links each for routers r3 & r4
                cur_state(j) = obj.destination(r{i}.inport1_pkt);
                cur_state(j+1) = obj.destination(r{i}.inport2_pkt);
				j = j + 2;
            end
		end

        function obj = control(obj, r)
			% Current state of the routers
            cur_state = obj.current_state(r);
            % Reward for the previous state & action
            rew = obj.cum_reward(end) - 0.98 * obj.cum_reward(end-1);
            
            % Compute the Q update using the previous reward
            if obj.learn == 1
                % Add the previous state, action and reward to the replay set
                [~, cR] = size(obj.R);
                if cR < obj.replay_size
                    cR = cR + 1;
                else
                    % When the Replay set gets too big forget the oldest sample
                    obj.R(:, 1) = [];
                end
                obj.R(:, cR) = [obj.prev_state; obj.prev_action; rew];
                
                % Sample some elements of the replay set for learning
                cur_sample_size = min(obj.sample_size, cR);
                target = zeros(obj.output_size, cur_sample_size);
                if cur_sample_size == cR
                    % Not enough samples so use all in Replay set
                    samples = 1:cR;
                else
                    % Generate random sample indices
                    samples = randi(cR, 1, cur_sample_size);
                end
                
				
                for i = 1:cur_sample_size
                    j = samples(i);
                    % Calculate the Greedy Q for the next state of jth state
                    sample_state = obj.R(1:obj.input_size, j);
                    sample_action_cell = num2cell(obj.R(obj.input_size+(1:obj.action_length), j));
                    sample_action_index = sub2ind(obj.action_size, sample_action_cell{:});
                    sample_rew = obj.R(end, j);
                    if j == cR
                        next_state = cur_state;
                    else
                        next_state = obj.R(1:obj.input_size, j+1);
                    end
                    Q = obj.net(sample_state);
                    greedy_next_Q = max(obj.net(next_state));
                    updated_reward = (1-obj.alpha) * Q(sample_action_index) + obj.alpha * (sample_rew + obj.gamma * greedy_next_Q);
                    expect = NaN .* ones(obj.output_size, 1);
                    expect(sample_action_index) = updated_reward;
                    target(:, i) = expect;
                end
                
                % Perform learning updates
                obj.net = adapt(obj.net, obj.R(1:obj.input_size, samples), target);
            end
            
            % Choose a new action
            if rand(obj.r_stream) > obj.epsilon
                % Greedy step
                [~, greedy_ij] = max(obj.net(cur_state));
                [c1, c2, c3, c4, c5, c6] = ind2sub(obj.action_size, greedy_ij);
            else
                % Random step
                c1 = randi(obj.action_size(1));
                c2 = randi(obj.action_size(2));
                c3 = randi(obj.action_size(3));
                c4 = randi(obj.action_size(4));
                c5 = randi(obj.action_size(5));
                c6 = randi(obj.action_size(6));
            end
            r{1}.inport1_control = c1;
            r{2}.inport1_control = c2;
            r{3}.inport1_control = c3;
            r{3}.inport2_control = c4;
            r{4}.inport1_control = c5;
            r{4}.inport2_control = c6;
            for i = 5:6
                obj.forward_dst(r{i});
            end

            % State current state as previous for next round
            obj.prev_state = cur_state;
            obj.prev_action = [c1; c2; c3; c4; c5; c6];
			obj.epsilon = max(obj.min_epsilon, obj.epsilon - obj.epsilon_step);
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