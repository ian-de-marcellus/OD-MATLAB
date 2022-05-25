classdef Hegselmann_Krause_Model < handle
    %Base Hegselmann-Krause model
    %   acts as superclass for other models
    properties (SetAccess = protected, GetAccess = public)
        time = 1  % time starts at 1 cuz 1-indexing
        timestep = 1

        n_agents {mustBePositive, mustBeInteger}  % number of agents
        c {mustBeNonnegative}  % confidence bound

        adjacency(:,:) % {mustBeA(adjacency,'logical')}  % original adjacency matrix
        original_opinions(1,:)  % original array matrix
        
        path = fullfile('.')  % path to save location for simulations
    end

    properties (Access = public)
        % color map for displaying simulations
        displayColors

        % video settings
        videoFormat = 'mp4'
        videoName = 'output_media'
        nbins = 20
        frameRate = 2
    end

    properties (Access = protected)
        dist_matr(:,:)

        % modified adjacency matrix between agents
        % sets diagonal to 1 if all 0s
        adj_agents_matr(:,:)

        ind_matr(:,:) % {mustBeA(ind_matr,'logical')} % indicator matrix
        opinion_values(1,:)  % opinion values at current timestep
        simulation_data(:,:)  % opinion values at all timesteps
    end

    methods (Access = public)
        function self = Hegselmann_Krause_Model(bound, num_agents, adjacency, opinions)
            %constructor
            %   all vectors should be given as row vectors
            self.validate_input(adjacency,opinions); % TODO: fix

            % set initial conditions
            self.c = bound;
            self.n_agents = num_agents;
            self.adjacency = adjacency;
            self.adj_agents_matr = self.fix_adjacency(adjacency);
            
            % opinions at t=0
            self.original_opinions = opinions;
            self.opinion_values = opinions;
            self.simulation_data(1,:) = opinions;
        end

        function simulate_steps(self, steps)
            for i = 2:steps
                % set distance and indicator matrices
                self.update_coefficients();
                
                self.opinion_values = step(self);
                self.simulation_data(i,:) = self.opinion_values;
            end

        end

        function simulate_duration(self, duration)
            simulate_steps(self, duration/self.timestep);
        end

        function data = get_data(self)
            data = self.simulation_data;
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

            for t = start_step:end_step
                h.Data = self.simulation_data(t,:);
                writeVideo(v,getframe(f));
            end

            close(v);

        end

        function setPath(self, path)
            self.path = fullfile(path);
        end
    end

    methods (Access = protected)
        function new_opinions = step(self)
            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
            old_opinions = self.opinion_values;

            % element-wise multiplication for matrix determining whether
            % any given node influences another
            influence_matrix = self.adj_agents_matr.*self.ind_matr;

            % sum over columns (return row vector)
            new_opinions = (old_opinions*influence_matrix)./sum(influence_matrix);

            self.time = self.time + self.timestep;
        end

        function validate_input(self, adjacency, opinions)
            % TODO: make this work without the "self" (and in general)
            % assert(size(adjacency) == [num_agents num_agents], "Adjacency matrix incompatible size.");
            % assert(size(opinions) == [1, num_agents], "Opinion matrix incompatible size; all vectors should be given as row vectors.");
        end

        function update_coefficients(self)
            % calculate opinion distance between all agents
            dist = distance(self);

            self.dist_matr = dist;
            self.ind_matr = dist <= self.c;
        end

        function dist = distance(self)
            dist = abs(self.opinion_values - self.opinion_values.');
        end

        function new_adj = fix_adjacency(self, old_adj)
            % TODO: make it work without the "self"
            new_adj = old_adj + eye(size(old_adj));
        end

    end

end
