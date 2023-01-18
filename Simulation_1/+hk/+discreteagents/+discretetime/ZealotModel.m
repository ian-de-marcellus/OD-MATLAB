classdef ZealotModel < hk.discreteagents.discretetime.Model
    % ZEALOTMODEL - HK model with discrete agents, discrete time
    % Uses zealot/persuadable model
    %
    % public/protected function implementations:
    %   -   hk.discreteagents.discretetime.ZealotModel(adjacencyMatrix,
    %           opinionArray, zealotIDArray, persuadableBound, timestep)
    %
    % public/protected variable implementations:
    %   -   nZealots
    %   -   nPersuadables

    properties (Access = protected)
        nZealots {mustBeNonnegative, mustBeInteger}
        nPersuadables {mustBeNonnegative, mustBeInteger}
    end

    methods
        function self = ZealotModel(adjacencyMatrix, opinionArray, zealotIDArray, ...
                persuadableBound, timestep)
            % ZEALOTMODEL - Build opinion dynamics model with zealots and
            % homogeneous persuadable agents

            % If agent is a zealot, their confidence bound is 0.
            % If agent is persuadable, their confidence bound is given.
            bound = (1-zealotIDArray) * persuadableBound;

            self@hk.discreteagents.discretetime.Model(adjacencyMatrix,opinionArray,bound,timestep);
        end
    end
end
