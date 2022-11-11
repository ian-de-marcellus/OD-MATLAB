classdef (Abstract) Statics
    % STATICS - Static methods for hk models

    methods (Static, Access = public)
        function outputMatrix = forceselfadjacency(inputMatrix)
            % FORCESELFADJACENCY - sets main diagonal to 1s
            % Takes in matrix, sets main diagonal to 1s regardless of
            % previous values
            initialMainDiagonal = diag(inputMatrix);
            outputMatrix = inputMatrix - diag(initialMainDiagonal) + eye(size(inputMatrix));
        end

        function distMatr = distanceMatrix(array)
            % DISTANCE finds pairwise distances between array values
            % uses .' to transpose the opinion array
            distMatr = abs(array - array.');
        end

        function adjacency = gnpadjacency(nAgents, probability)
            random = rand(nAgents);
        
            % make adjacency matrix symmetric
            randomSymmetric = tril(random) + triu(random', 1);
            adjacency = randomSymmetric < probability;
        end

        function [adjacency, opinionArray] = stochasticblockadjacency(varargin)
            blockArray = cell(length(varargin),1);
            opinionArray = [];
            for i = 1:length(varargin)
                input = varargin{i};
                % celldisp(input)
                
                nAgents = input{1};
                probability = input{2};
                if (length(input) == 3)
                    dist = input{3};
                else
                    dist = makedist('Normal', 'mu', 0.5, 'sigma', 0.1);
                end

                % disp(nAgents)
                
                blockArray{i} = hk.Statics.gnpadjacency(nAgents,probability);
                opinions = random(dist,nAgents,1);
                disp(size(opinionArray));
                disp(size(opinions));
                opinionArray = cat(1, opinionArray, opinions);
            end
            
            adjacency = blkdiag(blockArray{:});
        end
    end
end