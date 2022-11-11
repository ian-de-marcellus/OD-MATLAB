classdef Model < hk.discreteagents.Model
    % MODEL - HK model with discrete agents, discrete time
    % Uses heterogeneous confidence bound, is superclass to homogeneous and
    % zealot models

    properties (Access = protected)
        enforceSelfAdjacency = true;
    end
    
    methods
        function step(self)
            self.frame = self.frame + 1;

            opinions = self.currentOpinionArray;
            distanceMatrix = hk.Statics.distanceMatrix(opinions);

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

        function self = Model(opinionArray, adjacencyMatrix, bound, timestep)
            % MODEL - HK model with discrete agents, discrete time
            % Uses heterogeneous confidence bound, is superclass to homogeneous and
            % zealot models
            self@hk.discreteagents.Model(opinionArray, ...
                adjacencyMatrix, bound, timestep);
        end
        
        function img = plot(self, varargin)
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

