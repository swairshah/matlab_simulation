classdef control_q < handle
    % CONTROL_Q Central contoller class to make NW control decisions using Q-learning
    
    properties
        Q; % Q table : matrix of dimentsions |states + actions|
        state_size;
        action_size;
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
        function obj = control_q(buffer_size, pkt_size, action_size, eps_step, seed)
            obj.state_size = [buffer_size, pkt_size] + 1;
            obj.action_size = action_size;
            obj.Q = zeros([obj.state_size, obj.action_size], 'uint8');
            obj.prev_state = ones(1, length(obj.state_size));
            obj.prev_action = ones(1, length(obj.action_size));
            obj.epsilon_step = eps_step;
            obj.r_stream = RandStream('mt19937ar', 'Seed', seed);
        end
        
        function obj = reward(obj, r, t)
            rew = reward(r, t) + .98 * obj.cum_reward(end);
            obj.cum_reward = [obj.cum_reward, rew];
        end
        
        function cur_state = current_state(obj, r)
            cur_state = ones(1, length(obj.state_size));
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
            cur_index = num2cell(cur_state + 1);
            % Reward for the previous state & action
            reward = obj.cum_reward(end) - 0.98 * obj.cum_reward(end-1);
            
            % Compute the Q update using the previous reward
            if obj.learn == 1
                prev_index = num2cell([obj.prev_state+1, obj.prev_action]);
                current_Q = obj.Q(cur_index{:}, :, :, :, :, :, :);
                greedy_Q = max(current_Q(:));
                update = (1-obj.alpha) * obj.Q(prev_index{:}) + obj.alpha * (reward + obj.gamma*greedy_Q);
                obj.Q(prev_index{:}) = update;
            end
            
            % Choose a new action
            if rand(obj.r_stream) > obj.epsilon
                % Greedy step
                current_Q = obj.Q(cur_index{:}, :, :, :, :, :, :);
                [~, greedy_ij] = max(current_Q(:));
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
            obj.prev_action = [c1, c2, c3, c4, c5, c6];
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