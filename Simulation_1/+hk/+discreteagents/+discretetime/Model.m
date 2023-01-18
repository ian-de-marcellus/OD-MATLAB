classdef Model < hk.discreteagents.Model
    % MODEL - HK model with discrete agents, discrete time
    % Uses heterogeneous confidence bound, is superclass to homogeneous and
    % zealot models
    %
    % public/protected function implementations:
    %   -   hk.discreteagents.discretetime.Model(adjacencyMatrix,
    %           opinionArray, bound, timestep)
    %   -   step(self)
    %   -   plot(self, varargin)
    %   -   laststephistogram(self)
    %   -   updateopinions(oldOpinions, influenceMatrix)
    %
    % public/protected variable implementations:
    %   -   enforceSelfAdjacency

    properties (Access = protected)
        enforceSelfAdjacency = true;
    end
    
    methods
        function step(self)
            % STEP - evolve simulation one timestep
            
            self.frame = self.frame + 1;

            opinions = self.currentOpinionArray;
            distanceMatrix = hk.Statics.distancematrix(opinions);

            % INDICATORMATRIX - true/false matrix based on whether one
            % agent is close enough to influence another
            % NOTE: each row has its own confidence bound in hetero model
            indicatorMatrix = abs(distanceMatrix) <= self.bound;

            % INFLUENCEMATRIX - element-wise multiplication for matrix
            % determining whether any given node influences another
            influenceMatrix = self.adjacencyMatrix.*indicatorMatrix;

            self.currentOpinionArray = hk.discreteagents.discretetime.Model.updateopinions(opinions, influenceMatrix);
            self.simulationDataMatrix(:,self.frame) = self.currentOpinionArray;
            self.time = self.time + self.timestep;
        end

        function self = Model(adjacencyMatrix, opinionArray, bound, timestep)
            % MODEL - HK model with discrete agents, discrete time
            % Uses heterogeneous confidence bound, is superclass to homogeneous and
            % zealot models
            self@hk.discreteagents.Model(adjacencyMatrix, opinionArray, ...
                bound, timestep);
        end
        
        function img = plot(self, varargin)
            % PLOT - plot this model
            % Currently returns a figure showing the distribution over time
            % and the distribution on the last timestep (the steady-state
            % distribution if run to equilibrium)
            img = figure;
            tiledlayout(2,1);
            
            nexttile
            imagesc(self.simulationDataMatrix,[0,1]);
            colorbar;
            titletext = self.nAgents + " Agents";
            title(titletext);
            
            nexttile
            histogram(self.currentOpinionArray, ceil(sqrt(self.nAgents)))
            title('Last Step Histogram')

            % TODO:
            % last step histogram
            % simulation information
            % adjacency imagesc
            % opinions over time
            % histogram video
            % graph over time of average opinion w SD error bars for each
            % maybe image over time of adjacency matrix except at each
            % timestep, the row corresponding to any given agent is the
            % color of that agent's opinion IN ONLY THE COLUMNS THAT ARE
            % TRUE IN THE ADJACENCY MATRIX (so looking down each column, we
            % see the opinion of each agent potentially influencing that agent during
            % that timestep)
            % ALSO IMPLEMENT FOR ZEALOT (in simulationexample.m write code
            % that compares the two)
        end

        function img = laststephistogram(self)
            % LASTSTEPHISTOGRAM - plot agent ending opinion histogram
            % Plot a histogram with the agents opinions on the last step
            % simulated
            img = figure;
            histogram(self.currentOpinionArray, ceil(sqrt(self.nAgents)))
            title('Last Step Histogram')
        end
    end

    methods (Static, Access = protected)
        function newOpinions = updateopinions(oldOpinions, influenceMatrix)
            % UPDATEOPINIONS - find opinions with old opinions, influence
            % Use influence matrix to update old opinions

            % sum over columns because of how multiplying array by matrix
            % works, sum over columns of influence matrix, then elementwise
            % divide for new opinion array
            newOpinions = (oldOpinions*influenceMatrix)./sum(influenceMatrix);
        end
    end
end

