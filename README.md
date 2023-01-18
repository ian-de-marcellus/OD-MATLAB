# OD-MATLAB

# Opinion Dynamics MATLAB simulation
Code written by Ian de Marcellus during Summer 2022, under the guidance of Professor Heather Zinn-Brooks.

## Short feature summary
This code simulates a bounded confidence Hegselmann-Krause opinion dynamics model. Currently implemented are discrete time, discrete agent models, supporting any adjacency graph and with options for both homogeneous and heterogenous confidence bounds. The special case of a persuadable/zealot model is explicitly implemented, and the hk.Statics file provides a function for easier zealot model creation. The hk.Statics file also includes a simple function which generates a random gnp adjacency matrix and corresponding random opinions (optionally drawn from a provided distribution, otherwise uniform from 0 to 1).

## Longer explanation
I investigated the Hegselmann-Krause bounded confidence model of opinion dynamics. Every timestep, each agent's opinion is influenced by adjacent agent's opinions, provided those opinions are within a specified distance (the influenced agent's "confidence bound") of their own.

These models can be discrete time, where each agent *i*'s opinion *x<sub>i</sub><sup>t</sup>* updates after discete timesteps, or continuous time, where each agent *i*'s opinion *x<sub>i(t)* updates for continuous *t*. They can also take the limit of the number of agents to infinity and instead use a density-based model (which can also update in discrete or continuous time).

As previously mentioned, each agent has a "confidence bound" within which they are influenced by other agents' opinions. In homogeneous models, all agents have the same confidence bound. A more complicated model involves both agents (called "persuadables") with the same confidence bound as each other and also agents (called "zealots") who influence the persuadables but themselves are uninfluenced. This scenario can be modeled as a homogeneous model with additional static background opinions. However, it can also be modeled with a heterogeneous confidence bound, where some agents have bound *c* and some where the limit of the confidence bound approaches 0.

In the file Simulation_1/deprecated/HKModelDiscTimeDiscAgents.m (the first model I coded), I quickly simulate the zealot-free scenario. In Simulation_1/deprecated/HKModelDiscTimeDiscAgentsWithZealots.m, I quickly simulated the scenario including zealots, using the second approach. I then coded up quick visualizations comparing the two distributions, including a video showing their compared evolutions over time and images showing how each agent's opinion evolved.

I then tried to see how viable quickly modifying the code I'd written to use continuous timesteps would be. I ran into several difficulties in how the code was written (such as a particular quirk that made first-order Runge-Kutta easily doable but higher order require drastic revisions). I collected this information and what I'd learned from my quick simulations of the discrete cases—especially the general structure that would make the simulations maximally flexible. I then used that to plan a good general structure for the overall flexible code.

I moved the previous code to the "deprecated" folder. Somewhere in either that migration or the attempted coding of the continuous case, the previous quick visualizations script (Simulation_1/deprecated/testsimulations.m) broke, but this previous commit (https://github.com/ian-de-marcellus/OD-MATLAB/commit/4b19b0141f5cc163379a0fa442351f04da3f13ff) should have a working version.

I then rewrote the code in an object-oriented and hierarchical way. The highest level (hk.Model) is an abstract superclass for all of the other models, and it includes the variables and functions all models should have some concept of (whether they were implemented in that file or left abstract for implementation by subclasses). I considered then using multiple inheritance for agent-/density-based and discrete/continuous time simulations, but found very little that exclusively the discrete time models or exclusively the continuous time models would have in common, so it made sense to first differentiate between agent-based and density-based models (again, creating abstract superclasses) before creating discete time and continuous time subclasses of each. Depending on the directions of future work using the model, the choice to not use multiple inheritance here may be worth revisiting. (The current structure of the code should make implementating such a change fairly trivial.)

I create hk.discreteagents.discretetime.Model, a class that was not abstract and implemented the basic model with discrete time and discrete agents detailed above. That model has support for heterogeneous confidence bounds and adjacency graphs, but it could be trivially subclassed to enforce homogeneous confidence bounds and/or complete graphs, and then additional types of visualizations that rely on those properties could be implemented. Along similar lines, I implemented a zealot/persuadable subclass (hk.discreteagents.discretetime.ZealotModel.m) which makes creating and accessing properties of a zealot/persuadable model easier, and this class could be used to optimize calculations for specifically that special case and to create visualizations for that specific case.

The new code, besides the quick testing script for reporting on my progress and manually checking various aspects of models, is well-documented and should be relatively easy to understand and, once understood, very easy to extend. A few functions, especially those related to visualization, are currently unfinished (they are generally marked by TODOs), and currently only code for simulating various cases of discrete agents in discrete time is implemented.

Test cases can be created manually by the user or easily generated using the function hk.Statics.stochasticblockadjacency, which is thoroughly documented and allows for creation of highly customizable stochastic block adjacency matrices, as well as random opinion arrays, which can optionally be drawn from a provided/indicated distribution.


A note regarding testing:

Many pieces of the code have been manually tested and those that are currently complete seem to do what they claim to do, especially the more technically complicated ones. However, proper testing should be written (that can simply be run to check new models, double-check current models, and make sure nothing has accidentally broken). I had hoped to write them before I set down this project, but at the step where that would have started making sense, I was loathe to spend even more time doing invisible work (since from the perspective of someone not looking at the underlying code, the improvements to the underlying structure and commenting were not particularly visible).

To summarize, several jumping-off points from the current code:
- robust testing
- clear visualizations, especially those that make end behavior clear and allow easy study of behavior in various limits and transition points between them
- continuous time models with discrete agents, as well as density-based models in continuous and discrete time
- implementing a GUI and graphical documentation to allow users without coding proficiency to easily use the program


Please feel free to contact me at idemarcellus{at}hmc.edu with any questions, and anyone who picks up this project in the future is especially encouraged to do so.