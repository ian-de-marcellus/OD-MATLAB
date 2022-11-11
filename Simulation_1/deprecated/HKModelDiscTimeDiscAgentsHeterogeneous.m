classdef HKModelDiscTimeDiscAgentsHeterogeneous < HKModelDiscTimeDiscAgents
    %Base Hegselmann-Krause model
    %   acts as superclass for other models
    properties (SetAccess = protected, GetAccess = public)
        bounds;
    end

    methods (Access = public)
        function self = HKModelDiscTimeDiscAgentsHeterogeneous(bounds, num_agents, adjacency, opinions)
            %constructor
            %   all vectors should be given as row vectors
            % self.validate_input(adjacency,opinions); % TODO: fix
            self@HKModelDiscTimeDiscAgents(bounds(1), num_agents, adjacency, opinions);

            % set initial conditions
            self.bounds = bounds;
            self.n_agents = num_agents;
            self.adjacency = adjacency;
            self.adj_agents_matr = self.fix_adjacency(adjacency);
            
            % opinions at t=0
            self.original_opinions = opinions;
            self.opinion_values = opinions;
            self.simulation_data(1,:) = opinions;
        end
    end

    methods (Access = protected)
        function new_opinions = step(self)
            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
            old_opinions = self.opinion_values;

            size(self.adj_agents_matr)
            size(self.ind_matr)

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
            % assert(size(opinions) == [1, nu m_agents], "Opinion matrix incompatible size; all vectors should be given as row vectors.");
        end

        function update_coefficients(self)
            % calculate opinion distance between all agents
            dist = distance(self);

            self.dist_matr = dist;
            bound_test = repmat(self.bounds', [1, 21]);
            self.ind_matr = dist <= bound_test;
        end

        function dist = distance(self)
            dist = abs(self.opinion_values - self.opinion_values.');
        end

        function new_adj = fix_adjacency(self, old_adj)
            % TODO: make it work without the "self"
            % ensure that each node is considered to be adjacent to itself
            % for the mathematical purposes of this calculation
            new_adj = old_adj + eye(size(old_adj));
        end

    end

end
