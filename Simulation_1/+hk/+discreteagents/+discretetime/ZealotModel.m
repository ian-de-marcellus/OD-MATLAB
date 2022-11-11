classdef ZealotModel < hk.discreteagents.discretetime.Model
    % ZEALOTMODEL - HK model with discrete agents, discrete time
    % Uses zealot/persuadable model
    properties (Access = protected)
        nZealots {mustBeNonnegative, mustBeInteger}
        nPersuadables {mustBeNonnegative, mustBeInteger}
    end

    methods
        function self = ZealotModel(persuadableOpinionArray, zealotOpinionArray, persuadableAdjacencyMatrix, zealotFollowingMatrix, bound, timestep)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            nZealots = length(zealotOpinionArray);
            nPersuadables = length(persuadableOpinionArray);

            opinionArray = cat(1,persuadableOpinionArray,zealotOpinionArray);

            adjacencyMatrix = [persuadableAdjacencyMatrix zealotFollowingMatrix];
            adjacencyMatrix = [adjacencyMatrix, zeros(nZealots, nPersuadables+nZealots)];

            self@hk.discreteagents.discretetime.Model(opinionArray,adjacencyMatrix,bound,timestep);

            self.nZealots = length(zealotOpinionArray);
            self.nPersuadables = length(persuadableOpinionArray);
        end
    end
end
