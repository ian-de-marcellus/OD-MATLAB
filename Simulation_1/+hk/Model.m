classdef (Abstract) Model < handle
    % MODEL - HK Model superclass
    % Abstract superclass for all HK bounded confidence models, including
    % continuous and discrete time, agent-based and density-based, and
    % homogeneous / heterogeneous / zealot confidence bounds
    
    properties (SetAccess = protected, GetAccess = public)
        time = 0
        frame {mustBePositive,mustBeInteger}

        % TIMESTEP - increase in time per update iteration
        timestep {mustBePositive} 

        % media save options
        path = fullfile('.')  % default save location
    end
    
    methods
        function self = Model(timestep)
            % MODEL - Superclass constructor
            self.timestep = timestep;
            self.frame = 1;  % frame starts at 1 because of 1-indexing
        end
    end

    methods (Abstract, Access = public)
        % abstract methods to be implemented by subclasses
        data = getdata(self)
        img = plot(self, varargin)

        step(self)

        % TODO: implement video
    end

    methods (Abstract, Access = protected)
        diff = lastopiniondifferential(self)
    end

    methods (Access = public)
        function setpath(self, path)
            % SETPATH - Change path for automatically saving media
            self.path = fullfile(path);
        end

        function simulatesteps(self, steps)
            % SIMULATESTEPS - run simulation for STEPS (more) steps
            for i = 2:steps
                self.step()
            end
        end

        function simulateduration(self, duration)
            % SIMULATEDURATION - Evolves simulation by given amount of time
            simulatesteps(self, duration/self.timestep);
        end

        function simulateconvergence(self, tolerance, maxIter)
            % SIMULATECONVERGENCE - Evolve simulation until either reaching
            % the maximum number of iterations or until 
            self.step();
            i = 1;

            while ((self.lastopiniondifferential > tolerance) && i < maxIter)
                self.step();
                i = i + 1;
            end
        end
    end
end

