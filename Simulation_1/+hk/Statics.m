classdef (Abstract) Statics
    % STATICS - Abstract class that holds static methods for HK models
    % DEPENDENCY for stochasticblockadjacency: STATISTICS AND MACHINE LEARNING TOOLBOX
    %   Generating opinion arrays from distributions will not work without
    %   this toolbox installed.
    %
    % public/protected function implementations:
    %   -   forceselfadjacency(inputMatrix)
    %   -   distancematrix(array)
    %   -   zealotinput(persuadableOpinionArray, zealotOpinionArray,
    %           persuadableAdjacencyMatrix, zealotFollowingMatrix)
    %   -   gnpadjacency(nAgents, probability, opinionDistribution)
    %   -   stochasticblockadjacency(blocks, offDiagonal, opinionDistribution)
    %
    % public/protected variable implementations:

    methods (Static, Access = public)
        function outputMatrix = forceselfadjacency(inputMatrix)
            % FORCESELFADJACENCY - sets main diagonal to 1s
            % Takes in matrix, sets main diagonal to 1s regardless of
            % previous values
            initialMainDiagonal = diag(inputMatrix);
            outputMatrix = inputMatrix - diag(initialMainDiagonal) + eye(size(inputMatrix));
        end

        function distMatr = distancematrix(array)
            % DISTANCE - finds pairwise distances between array values
            % uses .' to transpose the opinion array
            distMatr = abs(array - array.');
        end

        function [adjacencyMatrix, opinionArray, zealotIDArray] = zealotinput( ...
                persuadableOpinionArray, zealotOpinionArray, persuadableAdjacencyMatrix, zealotFollowingMatrix)
            % ZEALOTINPUT - combines separate persuadable and zealot inputs
            % TODO

            nZealots = length(zealotOpinionArray);
            nPersuadables = length(persuadableOpinionArray);

            opinionArray = cat(1,persuadableOpinionArray,zealotOpinionArray);

            adjacencyMatrix = [persuadableAdjacencyMatrix zealotFollowingMatrix];
            adjacencyMatrix = [adjacencyMatrix, zeros(nZealots, nPersuadables+nZealots)];

            zealotIDArray = [zeros([1,nPersuadables]), ones([1,nZealots])];
        end

        function [adjacency, opinionArray] = gnpadjacency(nAgents, probability, ...
                opinionDistribution)
            % GNPADJACENCY - create (symmetric) GNP adjacency matrix
            % Each agent has probability 'probability' of being adjacent to
            % any other agent
            
            % make random symmetic (binary) adjacency matrix
            random = rand(nAgents);
            randomSymmetric = tril(random) + triu(random', 1);
            adjacency = randomSymmetric < probability;

            % generate corresponding opinion array
            if (exist('opinionDistribution', 'var') && ~isempty(opinionDistribution))
                % use given distribution if provided
                opinionArray = random(opinionDistribution,nAgents,1);
            else
                % by default, draw opinions randomly from standard
                % uniform distribution
                opinionArray = rand(nAgents, 1);
            end
        end

        function [adjacency, opinionArray] = stochasticblockadjacency(blocks, ...
                offDiagonal, opinionDistribution)
            % STOCHASTICBLOCKADJACENCY - create stochastic block adjacency
            % matrix with m blocks and corresponding opinion array
            %
            % blocks: m by 2 cell array, where each of the m rows
            % corresponds to a block, with column 1: number of agents in
            % block, column 2: intra-block adjacency probability.
            %
            %   ex:
            %
            %   [   [n1, p1],
            %       [n2, p2],
            %       [n3, p3]    ]
            %   corresponds to a matrix with three blocks: one with n1
            %   agents who each have probability p1 of being adjacent to
            %   each other, one with n2 agents with probability p2, and one
            %   with n3 agents with probability p3.
            %
            % offDiagonal: scalar or m x m matrix determining inter-block
            % adjacency probability.
            %   If off_diagonal is a scalar, all off-diagonal blocks use
            %   that probability. If off_diagonal is an m by m matrix, the
            %   off-diagonal blocks use the corresponding probabilities to
            %   determine adjacency. Entries on or below the main diagonal
            %   are ignored.
            %
            %   ex:
            %
            %   If there are three blocks, given the off-diagonal matrix
            %       |   0       0.4     0.3     |
            %       |   0        0      0.2     |
            %       |   0        0       0      |
            %   then agents in blocks 1 and 2 would have a 40% probability
            %   of being adjacent, those in blocks 1 and 2 would have a 30%
            %   adjacency probability, and those in blocks 2 and 3 would have a 20%
            %   adjacency probability.
            %
            % opinionDistribution (optional): underlying agent opinion distribution(s)
            %   NOTE: REQUIRES STATISTICS & MACHINE LEARNING TOOLBOX
            %   Distribution may be passed as
            %       -   a distribution object (as is typically generated by
            %           'makedist' or 'fitdist' functions), all of which
            %           have the common superclass
            %           'prob.ToolboxFittableParametricDistribution'
            %
            %       -   an array of distribution objects (as described
            %           above) with length m (the number of blocks)
            %
            %       -   a 1-by-2 cell array, where the first element is the
            %           character vector name of the distribution
            %           (e.g. 'norm') and the second element is a vector
            %           containing the parameters of the distribution
            %           (e.g. [0, 1]), so the cell array determines a
            %           distribution.
            %               ex:
            %                   ['norm', [0, 1]]
            %               would draw opinions from a normal distribution
            %               with mean 0 and standard deviation 1.
            %
            %       -   an m-by-2 cell array, where m is the number of
            %           blocks, where the first element of each row is the
            %           character vector name of the distribution
            %           (e.g. 'norm'), and where the second element is a
            %           vector containing the parameters of the
            %           distribution (e.g. [0, 1], and where each row
            %           determines a distribution for the corresponding
            %           block
            %               ex:
            %               For m=2:
            %                   [   ['
            %                   ['norm', [0, 1]]
            %               would draw opinions from a normal distribution
            %               with mean 0 and standard deviation 1.
            %
            %       If one distribution is specified, opinions for all
            %       agents are drawn from that distribution.
            %
            %       If multiple distributions are specified, opinions for
            %       agents in each block are drawn from the distribution
            %       corresponding to that block; e.g. opinions for agents
            %       in the third block are drawn from the distribution
            %       specified by the third distribution given.

            % validate 'blocks' argument
            blockShape = size(blocks);
            if (blockShape(2) == 2)
                nBlocks = blockShape(1);

                % cast each of the n's to an (unsigned) int, then sum them
                nTotalAgents = sum(cellfun(@uint16, blocks(:,1)));

            else
                throw(MException('hk:stochasticblockadjacency:InvalidBlockShape', ...
                    "'blocks' argument should be a cell array with two columns."))
            end

            % validate 'offDiagonal' argument, check if given offDiagonal
            % argument is either a scalar or a square matrix with side
            % length equal to the number of blocks
            offDiagonalShape = size(offDiagonal);
            expectedShape = [nBlocks, nBlocks];
            if ~(isscalar(offDiagonal) || isequal(offDiagonalShape, expectedShape))
                throw(MException('hk:stochasticblockadjacency:InvalidOffDiagonalShape', ...
                    "'offDiagonal' argument should be a scalar or a square" + ...
                    "matrix with the dimensions of the number of blocks."))
            elseif (isscalar(offDiagonal))
                % given scalar value, create corresponding symmetric matrix
                offDiagonal = offDiagonal * ones([nBlocks, nBlocks]);
            end


            % validate 'opinionDistribution' argument, use it to create
            % vector of Distribution objects 'distributions' of length nBlocks

            % default case when 'opinionDistribution' argument missing
            % no opinion distribution provided, use GNP matrix default by
            % passing an empty object
            distributions = repmat([],1,nBlocks);

            % case with distribution(s) provided
            if exist('opinionDistribution','var')

                % Here we need to check if the Statistics and Machine
                % Learning toolbox is installed. However, this is not a
                % trivial check, so we wrap the first call to it in a
                % try-catch and prompt the user to double-check
                % installation of the toolbox is they are running into
                % exceptions using this functionality.

                try
                    % case where opinionDistribution is one or more distribution objects
                    if isa(opinionDistribution, ...
                            'prob.ToolboxFittableParametricDistribution')
        
                        % make sure opinionDistribution is a vector
                        if isvector(opinionDistribution)
        
                            % if only one distribution is given, apply it
                            if isscalar(opinionDistribution)
                                distributions = repmat(opinionDistribution,1,nBlocks);
        
                            % if there is a distribution for each
                            % block, find adjacency and opinions for
                            % this block using the corresponding
                            % distribution
                            elseif length(opinionDistribution) == nBlocks
                                distributions = opinionDistribution;
        
                            % throw exception if length is neither 1 nor nBlocks
                            else
                                throw(MException('hk:stochasticblockadjacency:invalidDistributionArgument', ...
                                    'Argument ''opinionDistribution'' must be a cell array, a scalar, or '+ ...
                                    'a vector with length  equal to the number of blocks, but argument '+ ...
                                    'is vector with length '+ length(opinionDistribution)+'.'));
                            end
        
                        % throw exception if distribution array has more than
                        % one dimension
                        else
                            throw(MException('hk:stochasticblockadjacency:invalidDistributionArgument', ...
                                'Argument ''opinionDistribution'' must be a cell array, a scalar, or '+ ...
                                'a vector with length  equal to the number of blocks, but argument '+ ...
                                'has dimensions '+size(opinionDistribution)+'.'));
                        end
        
                    % check if input is cell array
                    elseif iscell(opinionDistribution)
                        % get dimensions of cell array
                        argShape = size(opinionDistribution);
        
                        % check if given parameters for one distribution
                        if isequal(argShape, [1,2])
                            distName = opinionDistribution(1,1);
                            distOptions = opinionDistribution(1,2);
                            dist = makedist(distName, distOptions(:));
                            distributions = repmat(dist, 1, nBlocks);
        
                        % check if given distribution parameters for each block
                        elseif isequal(argShape, [nBlocks,2])
                            for i = 1:nBlocks
                                distName = opinionDistribution(i,1);
                                distOptions = opinionDistribution(i,2);
                                distributions(i) = makedist(distName, distOptions(:));
                            end
        
                        % cell array argument doesn't have valid dimensions
                        else
                            throw(MException('hk:stochasticblockadjacency:invalidDistributionArgument', ...
                                'Argument ''opinionDistribution'' must be a vector of distribution '+...
                                'objects, a cell array with size (1,2), or a cell array with size '+...
                                '(n,2), where n is the number of blocks, but argument given has size '+...
                                size(opinionDistribution)+'.'));
                        end
        
                    % argument is not a cell array or array of distributions
                    else
                        throw(MException('hk:stochasticblockadjacency:invalidDistributionArgument', ...
                            'Argument ''opinionDistribution'' must be a cell array '+...
                            'or an array of distribution objects, but argument has '+...
                            'class '+class(opinionDistribution)+'.'));
                    end

                catch exception
                    % If something goes wrong, use default distribution and
                    % notify user.
                    warning('Problem using custom opinion distribution:\n'+...
                        exception.getReport()+'\nUsing default distribution. '+ ...
                        'Please run "ver stats" to verify that you have the '+...
                        'Statistics & Machine Learning toolbox installed.')

                    distributions = repmat([],1,nBlocks);
                end
            end


            % initialize empty adjacency matrix and opinion array
            adjacency = zeros([nTotalAgents, nTotalAgents]);
            opinionArray = zeros([1, nTotalAgents]);

            iAgentRows = 1;
            % iterate through block rows
            for i = 1:nBlocks
                % how many agents in adjacency matrix has already been initialized
                iAgentColumns = iAgentRows;

                % iterate through each block in row that hasn't already
                % been completed
                for j = i:nBlocks

                    % what size block of matrix to replace
                    nRowAgents = blocks(i, 1);
                    nColumnAgents = blocks(j, 1);

                    % flatten 1x1 cell arrays
                    nRowAgents = nRowAgents{:};
                    nColumnAgents = nColumnAgents{:};


                    % if block is on the diagonal
                    if (i == j)
                        % validate symmetry
                        if (iAgentRows ~= iAgentColumns)
                            throw(MException('hk:stochasticblockadjacency:updateIndexingError', ...
                                'Something went wrong iteratively updating opinion array,' + ...
                                'row agents updated and column agents updated are not equal' + ...
                                'on block diagonal.'))
                        end

                        % flatten arguments
                        nAgents = blocks(i, 1);
                        nAgents = nAgents{:};  % extract from cell array
                        probability = blocks(i, 2);
                        probability = probability{:};

                        % create submatrix using GNP adjacency matrix,
                        % depending on whether distributions were provided

                        if (distributions)
                            [blockAdjacencyMatrix, blockOpinionArray] = ...
                                gnpadjacency(nAgents, probability, ...
                                distributions(i));
                        else
                            [blockAdjacencyMatrix, blockOpinionArray] = ...
                                hk.Statics.gnpadjacency(nAgents, probability);
                        end

                        % check adjacency matrix partion and opinion vector
                        % slice to be updated are currently all zeros
                        if (adjacency(iAgentRows:iAgentRows+nRowAgents-1, ...
                            iAgentColumns:iAgentColumns+nColumnAgents-1) ~= zeros( ...
                            [nRowAgents,nColumnAgents]))
                            throw(MException('stochasticblockadjacency:adjacencyUpdateError', ...
                                'Attempting to set non-zero region in adjacency block (%d, %d) partition.', i, j));
                        elseif (opinionArray(iAgentRows:(iAgentRows+nRowAgents-1)) ~= ...
                                zeros(1, nRowAgents))
                            throw(MException('stochasticblockadjacency:opinionUpdateError', ...
                                'Attempting to set non-zero region in opinion array slice for block %d.',i));
                        end

                        % update adjacency matrix partition and opinion
                        % array slice corresponding to block (i, j)
                        adjacency(iAgentRows:iAgentRows+nRowAgents-1, ...
                            iAgentColumns:iAgentColumns+nColumnAgents-1) = blockAdjacencyMatrix;
                        opinionArray(iAgentRows:iAgentRows+nRowAgents-1) = ...
                                blockOpinionArray;

                    % block is off of main diagonal
                    else

                        % retrieve off-diagonal probability
                        offDiagonalProbability = offDiagonal(i, j);

                        % make binary adjacency matrix
                        randomBlockMatrix = rand(nRowAgents, nColumnAgents);
                        blockAdjacencyMatrix = randomBlockMatrix < ...
                            offDiagonalProbability;

                        % make sure off-diagonal upper block is zeros
                        if (adjacency(iAgentRows:iAgentRows+nRowAgents-1, ...
                            iAgentColumns:iAgentColumns+nColumnAgents-1) ~= zeros( ...
                            [nRowAgents, nColumnAgents]))

                            throw(MException('stochasticblockadjacency:adjacencyUpdateError', ...
                                'attempting to set non-zero region in'+...
                                'adjacency block ('+i+', '+j+') partition.'));
                        
                        % for lower block
                        elseif (adjacency(iAgentColumns:iAgentColumns+nColumnAgents-1, ...
                            iAgentRows:iAgentRows+nRowAgents-1) ~= zeros( ...
                            [nColumnAgents, nRowAgents]))
                            throw(MException('stochasticblockadjacency:adjacencyUpdateError', ...
                                'attempting to set non-zero region in'+...
                                'adjacency block ('+j+', '+i+') partition.'));

                        end

                        % update upper off-diagonal block
                        adjacency(iAgentRows:iAgentRows+nRowAgents-1, ...
                            iAgentColumns:iAgentColumns+nColumnAgents-1) = blockAdjacencyMatrix;

                        % update lower off-diagonal block
                        adjacency(iAgentColumns:iAgentColumns+nColumnAgents-1, ...
                            iAgentRows:iAgentRows+nRowAgents-1) = transpose(blockAdjacencyMatrix);

                    end

                    iAgentColumns = iAgentColumns + nColumnAgents;

                end

                iAgentRows = iAgentRows + nRowAgents;
            end
        end
    end
end