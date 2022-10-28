classdef HKModelDiscTimeDiscAgentsWithZealots < HKModelDiscTimeDiscAgentsWithZealots
    % Hegselmann Krause model with zealots
    % Variation on HK model with zealots who can change the opinions of
    % others but their own opinions can't be changed

    properties (GetAccess = public, SetAccess = protected)
        n_zealots {mustBePositive, mustBeInteger}  % number of zealots
        zealot_opinions(1,:)

        % TODO: make extracting original agent vs zealot opinions more
        % intuitive
    end

    methods (Access = public)
        function self = HKModelDiscTimeDiscAgentsWithZealots(bound, num_agents, num_zealots, agent_adjacency, following, agent_opinions, zealot_opinions)
            adjacency = [agent_adjacency; following];
            opinions = agent_opinions;

            self@HKModelDiscTimeDiscAgentsWithZealots(bound, num_agents+num_zealots, adjacency, opinions);

            self.n_zealots = num_zealots;
            self.zealot_opinions = zealot_opinions;
        end

        function data = get_data(self)
            data = self.simulation_data();
        end

        function writeVideo(self, start_step, end_step)
            %Write simulation
            % Create .avi at given location with video of bar graph of
            % simulation evolving over time

            % TODO: validate start_step and end_step are integers, set up
            % support for default arguments

            v = VideoWriter(self.path + self.videoName);
            % TODO: fix to support multiple formats
            % v.FileFormat = self.videoFormat; 
            v.FrameRate = self.frameRate;

            open(v);

            f = figure;
            h = histogram(self.simulation_data(1,:), self.nbins);
            h.Normalization = 'probability';
            hold on;
            z = histogram(self.zealot_opinions, self.nbins);
            z.Normalization = 'probability';

            for t = start_step:end_step
                h.Data = self.simulation_data(t,:);
                writeVideo(v,getframe(f));
            end

            close(v);

        end
    end

    methods (Access = protected)
        function new_opinions = step(self)
            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
            old_opinions = [self.opinion_values self.zealot_opinions];
    
            % element-wise multiplication for matrix determining whether
            % any given node influences another

            influence_matrix = self.adj_agents_matr.*self.ind_matr;

            % zero out influence on zealots
            % identity = eye(size(influence_matrix));
            % influence_matrix = [ influence_matrix(1:num_agents,:);
            %                      identity(num_agents+1:num_zealots,:) ];
    
            % sum over columns (return row vector)
            new_opinions = (old_opinions*influence_matrix)./sum(influence_matrix);
    
            self.time = self.time + self.timestep;
        end

        function validate_input(self, adjacency, opinions)
            % TODO: add assertions later
            % assert(size(opinions) == [1, n_agents], "Opinion matrix incompatible size; all vectors should be given as row vectors.");
        end

        function dist = distance(self)
            dist = abs(self.opinion_values - [self.opinion_values self.zealot_opinions].');
            dist = dist(:, :);
        end
    end
end