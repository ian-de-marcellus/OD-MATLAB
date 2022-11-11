function testsimulations2()
    close all;
    
    bound = 0.2;
    nAgents = 100;
    probability = 0.2;
    random = rand(nAgents);

    % make adjacency matrix symmetric
    randomSymmetric = tril(random) + triu(random', 1);
    adjacency = randomSymmetric < probability;
    imagesc(adjacency,[0,1])

    opinions = rand(1, nAgents);
    
    model = hk.discreteagents.discretetime.Model(opinions, adjacency, bound, 0.25);

    model.simulateconvergence(0.005*nAgents, 100);
    model.plot()
end