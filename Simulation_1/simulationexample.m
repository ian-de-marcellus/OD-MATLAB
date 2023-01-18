function simulationexample()
    close all;
    
    % adjust persuadable agents' confidence bound here
    bound = 0.2;

    % generate agents and opinions
    [adjacency, opinions] = hk.Statics.stochasticblockadjacency({20, 0.5; 15, 0.2; 30, 0.3},0.05);
    zealotID = [zeros([1,15]) ones([1, 5]) zeros([1,14]) 1 zeros([1,27]) ones([1,3])];
   
    %% this block sorts the agents by opinion, comment out to remove sorting
    oldAdjacency = adjacency;   % save original agency matrix for debugging
    oldOpinions = opinions;     % save original opinions
    [opinions, index] = sort(opinions);
    adjacency = adjacency(index,:);

    %% continue with tests

    modelHomo = hk.discreteagents.discretetime.Model(adjacency, opinions, bound, 0.25);
    modelZealot = hk.discreteagents.discretetime.ZealotModel(adjacency, opinions, ...
        zealotID, bound, 0.25);

    modelHomo.simulateconvergence(0.005, 100);
    modelZealot.simulateconvergence(0.005, 100);

    % shows adjacency matrix, with zealots in a different color
    zealotAdjacency = adjacency .* (1-(0.5*zealotID));

    % plot agents' opinions over time
    modelHomo.plot();
    modelZealot.plot();

    % shows adjacency matrices with and without zealots
    figure;
    imagesc(adjacency);
    figure;
    imagesc(zealotAdjacency);

    % NOTE:
    % to compare with & without zealots, adjust the dimensions of the
    % smaller one by copying the last row until they're the same size, then
    % subtract them

    % signifies which agents are zealots
    figure;
    imagesc([zealotID' zealotID']);

    %% Ignore:

%     nAgents = 100;
%     probability = 0.2;
%     random = rand(nAgents);
% 
%     % make symmetric adjacency matrix
%     randomSymmetric = tril(random) + triu(random', 1);
%     adjacency = randomSymmetric < probability;
% 
%     % display adjacency matrix
%     imagesc(adjacency,[0,1])
% 
%     opinions = rand(1, nAgents);
%     
%     model = hk.discreteagents.discretetime.Model(opinions, adjacency, bound, 0.25);
% 
%     model.simulateconvergence(0.005, 100);
%     model.plot()
end