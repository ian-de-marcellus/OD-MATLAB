classdef HKModelContTimeDiscAgentsWithZealots < HKModelDiscTimeDiscAgentsWithZealots
    %Hegselmann Krause model with zealots
    %   Variation on HK model with zealots who can change the opinions of
    %   others but their own opinions can't be changed

    properties (GetAccess = public, SetAccess = protected)

        % the adjacency matrix but square
        % adj_square(:,:);
    end

    properties (Access = protected)
        % used inside Runge-Kutta steps
        temporaryDistanceMatrix(:,:);
    end

    methods (Access = public)
        function self = HKModelContTimeDiscAgentsWithZealots(bound, nAgents, nZealots, agentAdjacencyMatrix, agentZealotAdjacencyMatrix, agentOpinionArray, zealotOpinionArray, timestep)
            self@HKModelDiscTimeDiscAgentsWithZealots(bound, nAgents, nZealots, agentAdjacencyMatrix, agentZealotAdjacencyMatrix, agentOpinionArray, zealotOpinionArray);
            self.timestep = timestep;
        end
    end

    methods (Access = protected)
        % Numerically integrate using 4th order Runge-Kutta
        % Modified from previous code I've written
        function newOpinionArray = step(self)
            h = self.timestep;
            previous = [self.currentOpinionArray self.zealotOpinionArray];

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

            newOpinionArray = previous + (h/6) * (k1 + 2*k2 + 2*k3 + k4);

            % remove zealots
            newOpinionArray = newOpinionArray(1:self.nAgents-self.nZealots);

            % update time
            self.iTime = self.iTime + self.timestep;
        end

        function dj_dt = update(self, old_opinions)
            % THIS DOES NOT WORK, FIX

            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
    
            % element-wise multiplication for matrix determining whether
            % any given node influences another

            influenceMatrix = self.modifiedAdjacencyMatrix.*self.indicatorMatrix;

            % zero out influence on zealots
            % identity = eye(size(influence_matrix));
            % influence_matrix = [ influence_matrix(1:num_agents,:);
            %                      identity(num_agents+1:num_zealots,:) ];
            
            % create denominator vector
            denominator = sum(influenceMatrix);

            % Attach magnitude to influence matrix
            % Negative sign because distances were backwards
            distances = -self.distanceMatrix.*influenceMatrix;

            % create numerator vector
            numerator = sum(distances);

            % zealots don't update
            zealots = zeros(1,self.nZealots);
    
            % return row vector from elementwise division
            dj_dt = [numerator./denominator zealots];
        end

        function newAdjacencyMatrix = fixadjacency(self, oldAdjacencyMatrix)
            % For this one I *don't* want nodes to automatically be
            % adjacent to themselves, so override this
            % Maybe make it square though? (pad with zeroes)
            % n = max(size(old_adj));
            % new_adj(n,n) = 0;

            % Later note: why?

            newAdjacencyMatrix = oldAdjacencyMatrix;
        end

        function distanceMatrix = distance(array1, array2)
            % distance for this one shouldn't be absolute value
            distanceMatrix = array1 - [array1 array2].';
            distanceMatrix = distanceMatrix(:, :);
        end
    end
end