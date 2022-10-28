classdef HKModelContTimeDiscAgentsWithZealots < HKModelDiscTimeDiscAgentsWithZealots
    %Hegselmann Krause model with zealots
    %   Variation on HK model with zealots who can change the opinions of
    %   others but their own opinions can't be changed

    properties (GetAccess = public, SetAccess = protected)

        % the adjacency matrix but square
        adj_square(:,:);
    end

    methods (Access = public)
        function self = HKModelContTimeDiscAgentsWithZealots(bound, num_agents, num_zealots, agent_adjacency, following, agent_opinions, zealot_opinions, timestep)
            self@HKModelDiscTimeDiscAgentsWithZealots(bound, num_agents, num_zealots, agent_adjacency, following, agent_opinions, zealot_opinions);
            self.timestep = timestep;
        end
    end

    methods (Access = protected)
        % Numerically integrate using 4th order Runge-Kutta
        % Modified from previous code I've written
        function new_opinions = step(self)
            h = self.timestep;
            previous = [self.opinion_values self.zealot_opinions];

            % populate k1
            k1 = self.update(previous);

            % populate k2
            values2 = previous + (h/2 * k1);
            k2 = self.update(values2);

            % populate k3
            values3 = previous + (h/2 * k2);
            k3 = self.update(values3);

            % populate k4
            values4 = previous + (h * k3);
            k4 = self.update(values4);

            new_opinions = previous + (h/6) * (k1 + 2*k2 + 2*k3 + k4);

            % remove zealots
            new_opinions = new_opinions(1:self.n_agents-self.n_zealots);

            % update time
            self.time = self.time + self.timestep;
        end

        function dj_dt = update(self, old_opinions)
            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
    
            % element-wise multiplication for matrix determining whether
            % any given node influences another

            influence_matrix = self.adj_agents_matr.*self.ind_matr;

            % zero out influence on zealots
            % identity = eye(size(influence_matrix));
            % influence_matrix = [ influence_matrix(1:num_agents,:);
            %                      identity(num_agents+1:num_zealots,:) ];
            
            % create denominator vector
            denominator = sum(influence_matrix);

            % Attach magnitude to influence matrix
            % Negative sign because distances were backwards
            distances = -self.dist_matr.*influence_matrix;

            % create numerator vector
            numerator = sum(distances);

            % zealots don't update
            zealots = zeros(1,self.n_zealots);
    
            % return row vector from elementwise division
            dj_dt = [numerator./denominator zealots];
        end

        function new_adj = fix_adjacency(self, old_adj)
            % For this one I *don't* want nodes to automatically be
            % adjacent to themselves, so override this
            % Maybe make it square though? (pad with zeroes)
            % n = max(size(old_adj));
            % new_adj(n,n) = 0;

            new_adj = old_adj;
        end

        function dist = distance(self)
            % distance for this one shouldn't be absolute value
            dist = self.opinion_values - [self.opinion_values self.zealot_opinions].';
            dist = dist(:, :);
        end
    end
end