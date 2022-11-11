classdef HKModelDiscTimeDiscAgentsWithZealots < HKModelDiscTimeDiscAgents
    % Hegselmann Krause model with zealots
    % Variation on HK model with zealots who can change the opinions of
    % others but their own opinions can't be changed
    %
    % Treats zealots as an add-on influence rather than as agents with
    % confidence bound 0.

    properties (GetAccess = public, SetAccess = protected)
        nZealots {mustBePositive, mustBeInteger}  % number of zealots
        zealotOpinionArray(1,:)

        % TODO: make extracting original agent vs zealot opinions more
        % intuitive
    end

    methods (Access = public)
        function self = HKModelDiscTimeDiscAgentsWithZealots(bound, nAgents, nZealots, agentAdjacencyMatrix, agentZealotAdjacencyMatrix, agentOpinionArray, zealotOpinionArray)
            originalAdjacencyMatrix = [agentAdjacencyMatrix; agentZealotAdjacencyMatrix];
            opinions = agentOpinionArray;

            self@HKModelDiscTimeDiscAgents(bound, nAgents+nZealots, originalAdjacencyMatrix, opinions);
            % NOTE: creating modified adjacency matrix so each persuadable agent
            % influences themself does work through this constructor call,
            % because the superclass method adds matrix constructed using
            % eye() which adds 1s only on the main diagonal, and the matrix
            % passed is not square

            self.nZealots = nZealots;
            self.zealotOpinionArray = zealotOpinionArray;
        end

        function data = getdata(self)
            data = self.simulationDataMatrix();
        end

        function writeVideo(self, startStep, endStep)
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
            h = histogram(self.simulationDataMatrix(1,:), self.nBins);
            h.Normalization = 'probability';
            hold on;
            z = histogram(self.zealotOpinionArray, self.nBins);
            z.Normalization = 'probability';

            for t = startStep:endStep
                h.Data = self.simulationDataMatrix(t,:);
                writeVideo(v,getframe(f));
            end

            close(v);

        end
    end

    methods (Access = protected)
        function newOpinionArray = step(self)
            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
            oldOpinionArray = [self.currentOpinionArray self.zealotOpinionArray];
    
            % element-wise multiplication for matrix determining whether
            % any given node influences another

            influenceMatrix = self.modifiedAdjacencyMatrix.*self.indicatorMatrix;
    
            % sum over columns (return row vector)
            newOpinionArray = (oldOpinionArray*influenceMatrix)./sum(influenceMatrix);
    
            self.iTime = self.iTime + self.timestep;
        end

        function validateinput(self, adjacency, opinions)
            % TODO: add assertions later
            % assert(size(opinions) == [1, n_agents], "Opinion matrix incompatible size; all vectors should be given as row vectors.");
        end

        function distanceMatrix = distance(array1, array2)
            distanceMatrix = abs(array1 - [array1 array2].');
            distanceMatrix = distanceMatrix(:, :);
        end
    end
end