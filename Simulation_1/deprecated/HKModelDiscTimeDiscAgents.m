classdef HKModelDiscTimeDiscAgents < handle
    % Base Hegselmann-Krause model
    % This model simulates interactions between nAgents agents, who
    % mutually affect each other based on adjacent, an adjacency matrix,
    % with all agents adjusting their opinions at each timestep using a
    % homogeneous bounded confidence function with bound c.
    %
    % Acts as superclass for other models

    properties (SetAccess = protected, GetAccess = public)
        iTime = 1  % time starts at 1 because of 1-indexing
        timestep = 1  % increase in time per update iteration

        nAgents {mustBePositive, mustBeInteger}  % number of agents
        bound {mustBeNonnegative}  % confidence bound

        % adjacencyMatrix- 

        originalAdjacencyMatrix(:,:) % {mustBeA(adjacency,'logical')}  % original adjacency matrix
        originalOpinionArray(1,:)  % original array matrix
        
        path = fullfile('.')  % path to save location for simulations
    end

    properties (Access = public)
        % color map for displaying simulations
        displayColors

        % video settings
        videoFormat = 'mp4'
        videoName = 'output_media'
        nBins = 20
        frameRate = 2
    end

    properties (Access = protected)
        distanceMatrix(:,:)

        % modified adjacency matrix between agents
        % sets diagonal to 1 if all 0s
        modifiedAdjacencyMatrix(:,:)

        indicatorMatrix(:,:) % {mustBeA(ind_matr,'logical')} % indicator matrix
        currentOpinionArray(1,:)  % opinion values at current timestep
        simulationDataMatrix(:,:)  % opinion values at all timesteps
    end

    methods (Access = public)
        function self = HKModelDiscTimeDiscAgents(bound, nAgents, adjacencyMatrix, opinionMatrix)
            % HEGSELMANNKRAUSEMODEL
            % all vectors should be given as row vectors
            % self.validateinput(adjacency,opinions); % TODO: fix

            % set initial conditions
            self.bound = bound;
            self.nAgents = nAgents;
            self.originalAdjacencyMatrix = adjacencyMatrix;
            self.modifiedAdjacencyMatrix = self.fixadjacency(adjacencyMatrix);
            
            % opinions at t=1
            self.originalOpinionArray = opinionMatrix;
            self.currentOpinionArray = opinionMatrix;
            self.simulationDataMatrix(1,:) = opinionMatrix;
        end

        function simulatesteps(self, steps)
            for i = 2:steps
                % set distance and indicator matrices
                self.updatecoefficients();
                
                self.currentOpinionArray = step(self);
                self.simulationDataMatrix(i,:) = self.currentOpinionArray;
            end

        end

        function simulateduration(self, duration)
            simulatesteps(self, duration/self.timestep);
        end

        % NOTE TO SELF: TODO WRITE A FUNCTION TO GO BACK TO A TIME WITH
        % DIFFERENT OPINION VALUES AND EVOLVE FROM THERE (POTENTIALLY WITH
        % DIFFERENT PARAMETERS)

        function data = getdata(self)
            data = self.simulationDataMatrix;
        end

        function writevideo(self, startStep, endStep)
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

            for t = startStep:endStep
                h.Data = self.simulationDataMatrix(t,:);
                writeVideo(v,getframe(f));
            end

            close(v);

        end

        function setPath(self, path)
            %Set for where to save created media
            self.path = fullfile(path);
        end

        function distanceMatrix = distance(array)
            % DISTANCE finds pairwise distances between agents' opinion
            % values
            % uses .' to transpose the opinion array
            distanceMatrix = abs(array - array.');
        end
    end

    methods (Access = protected)
        function newOpinionArray = step(self)
            % Kronecker delta at end of equation is already encoded in
            % modified adjacency matrix
            oldOpinionArray = self.currentOpinionArray;

            % element-wise multiplication for matrix determining whether
            % any given node influences another
            influenceMatrix = self.modifiedAdjacencyMatrix.*self.indicatorMatrix;

            % sum over columns because of how multiplying array by matrix
            % works, sum over columns of influence matrix, then elementwise
            % divide for new opinion array
            newOpinionArray = (oldOpinionArray*influenceMatrix)./sum(influenceMatrix);

            self.iTime = self.iTime + self.timestep;
        end

        function validateinput(self, adjacency, opinions)
            % TODO: make this work without the "self" (and in general)
            % Note to self: perhaps it doesn't work because it's protected?
            % assert(size(adjacency) == [num_agents num_agents], "Adjacency matrix incompatible size.");
            % assert(size(opinions) == [1, num_agents], "Opinion matrix incompatible size; all vectors should be given as row vectors.");
        end

        function updatecoefficients(self)
            % calculate opinion distance between all agents
            self.distanceMatrix = distance(self.currentOpinionArray);

            % sets indicator matrix to TRUE/FALSE matrix with TRUE only where
            % the corresponding agents are close enough to affect each
            % other
            self.indicatorMatrix = abs(self.distanceMatrix) <= self.bound;
        end

        function newAdjacencyMatrix = fixadjacency(self, oldAdjacencyMatrix)
            % TODO: make it work without the "self"
            % ensure that each node is considered to be adjacent to itself
            % for the mathematical purposes of this calculation
            newAdjacencyMatrix = oldAdjacencyMatrix + eye(size(oldAdjacencyMatrix));
        end

    end

end
