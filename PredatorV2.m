classdef PredatorV2 < handle %Now with the new movement system that checks for bounds
    properties
        xy = []; %2-element vector for x-y coordinates
        dest_xy = []; %Destination coordinates that override regular motion (only used for boolean checks)
        destx; %X-coordinate of destination
        desty; %Y-coordinate of destination
        env_size; %Size of the environment, used to restrain motion
        state_machine; %CHANGE THIS TO "STATE_MACHINE" LATER
        move_dir = []; %2-element vector for movement direction
        move_duration; %Number of steps for which an animal will continue in a certain direction
        move_speed; %The speed at which the animal moves per step
        genes = []; %The gene vector
        % A Quick Guide to the Genes
        % [1]: Lifespan Modifier (higher gene = higher lifespan)
        % [2]: Movement Speed Modifier (higher gene = higher speed)
        % [3]: Movement Variance Modifier (higher gene = more varied speed)
        % [4]: Movement Duration Modifier (higher gene = more persistent)
        % [5]: Hunger Modifier (higher gene = go longer without food)
        % [6]: Fertility Modifier (higher gene = mature faster)
        % [7]: Awareness Modifier (higher gene = see prey better)
        GENECOUNT = 7; % A constant value of genes used for initialization.
        saturation; %A measure of how hungry an animal is
        max_saturation; %A value affected by gene 5
        lifespan; %How long an animal will live (in steps)
        isDead; %A true/false value for checking if an animal has died
        initial_lifespan; %Used for age-based modifiers
        fertility_countdown; %Number of steps until the age is of the right age
        isFertile; %A true/false value for checking if an animal can breed
        waitTimer; %A value used for reproduction
        awareness;
    end
    
    methods
        function obj = PredatorV2(~, envsize) %Constructor
           rng('shuffle');
           % Compute genes first as they're used for other calculations
           % shortly afterwards
           r = randn(1,obj.GENECOUNT, 'single');
           obj.genes = (exp(r)./(exp(r)+1));
           
           obj.xy = envsize * rand(1,2, 'single'); %"env_size" is the size of the environment specified by the user
           obj.env_size = envsize;
           obj.state_machine = "Roaming";
           
           uvec = [(2*rand)-1, (2*rand)-1]; %Unit vector for direction
           obj.move_dir = uvec/norm(uvec);
           obj.move_speed = 2 + (obj.genes(2)); %SET THIS LATER TO BE DETERMINED BY GENETICS
           obj.move_duration = randi([5, 10]);
           
           obj.lifespan = round(500 + (500 * obj.genes(1)));
           obj.initial_lifespan = obj.lifespan;
           obj.isDead = 0; %A boolean value that indicates if an animal is dead
           obj.awareness = 15 + (15*obj.genes(7)); %awareness radius of predator
           
           obj.saturation = 90+round(20*obj.genes(5)); %Percentages of hunger and thirst respectively.
           obj.max_saturation = obj.saturation;
           
           obj.destx = 0;
           obj.desty = 0;
           obj.dest_xy = [obj.destx obj.desty];
           obj.fertility_countdown = round(obj.initial_lifespan/(4+(2*obj.genes(6))));
           obj.isFertile = 0; % A boolean value that controls whether or not the animal can reproduce
           obj.waitTimer = 0; % A step timer for preventing animals from moving
           
        end
        
        function findDirection(obj,animal_pos)
            dir_x = animal_pos(1) - obj.xy(1);
            dir_y = animal_pos(2) - obj.xy(2);
            u_vec = [dir_x, dir_y];
            obj.move_dir = u_vec/norm(u_vec);
            
        end
        
        function step(obj)
           % The main function for movement, status checks, state machine switches, etc.
           if ((obj.saturation <= 0) || (obj.lifespan == 0))
               obj.lifespan = 0;
               obj.isDead = 1;
           end
           if (obj.fertility_countdown == 0)
              % The animal is now ready to mate
              obj.isFertile = 1;
           end
           switch obj.state_machine
               case "Roaming"
                   obj.updatePosition;
           end
           obj.fertility_countdown = obj.fertility_countdown - 1; %Decrease fertility countdown by 1
        end
        function updatePosition(obj)
            if (isempty(obj.dest_xy) || ~any(obj.dest_xy)) %If the animal has no preset destination
                sv = round(50*obj.genes(3)); %Speed variance, in percentage
                ms = obj.move_speed; %Save the object's normal speed to a variable
                effective_speed = ((ms * randi([100-sv, 100+sv]))+(100-obj.saturation))/100;
                if ((obj.lifespan/obj.initial_lifespan) < 0.2) %If the animal is in the last 20% of its life
                    effective_speed = 0.8*effective_speed;
                end
                obj.xy = obj.xy + (obj.move_dir * effective_speed);
                coordinates = obj.xy;
                obj.move_duration = obj.move_duration - 1;
                esize = obj.env_size;
                if (obj.move_duration == 0)
                    % Shuffle direction and reset counter
                    uvec = [(2*rand)-1, (2*rand)-1];
                    obj.move_dir = uvec/norm(uvec);
                    obj.move_duration = randi([3+round(obj.genes(4)*4), 8+round(obj.genes(4)*4)]);
                end
                %checks if it is time and gives a predator a new direction
                %to wander in
                
                if (coordinates(1) < 0) %If x-value is negative
                    coordinates(1) = 0;
                    obj.xy = coordinates;
                    uvec = [rand*0.2, (rand*2)-1]; %Deflect the animal away
                    obj.move_dir = uvec/norm(uvec);
                    obj.move_duration = obj.move_duration + randi([3, 5]);
                end
                %checks if an predator is outside the the environment, and if
                %they are, places them back inside it and directs them away
                %from the boundry
                
                if (coordinates(2) < 0)
                    coordinates(2) = 0;
                    obj.xy = coordinates;
                    uvec = [(rand*2)-1, rand*0.2];
                    obj.move_dir = uvec/norm(uvec);
                    obj.move_duration = obj.move_duration + randi([3, 5]);
                end
                %checks if an predator is outside the the environment, and if
                %they are, places them back inside it and directs them away
                %from the boundry
                
                if (coordinates(1) > esize) %If the animal exceeds the boundary
                    coordinates(1) = esize;
                    obj.xy = coordinates;
                    uvec = [-0.2*rand, (rand*2)-1];
                    obj.move_dir = uvec/norm(uvec);
                    obj.move_duration = obj.move_duration + randi([3, 5]);
                end
                %checks if an predator is outside the the environment, and if
                %they are, places them back inside it and directs them away
                %from the boundry
                
                if (coordinates(2) > esize)
                    coordinates(2) = esize;
                    obj.xy = coordinates;
                    uvec = [(rand*2)-1, -0.2*rand];
                    obj.move_dir = uvec/norm(uvec);
                    obj.move_duration = obj.move_duration + randi([3, 5]);
                end
                %checks if an predator is outside the the environment, and if
                %they are, places them back inside it and directs them away
                %from the boundry
            end
            if (~isempty(obj.dest_xy) && any(obj.dest_xy)) %If the animal has a preset destination
                sv = round(50*obj.genes(3)); %Speed variance, in percentage
                ms = obj.move_speed; %Save the object's normal speed to a variable
                effective_speed = (ms * randi([100-sv, 100+sv]))/100;
                if ((obj.lifespan/obj.initial_lifespan) < 0.2) %If the animal is in the last 20% of its life
                    effective_speed = 0.8*effective_speed;
                end
                direction = [obj.dest_xy(1)-obj.xy(1), obj.dest_xy(2)-obj.xy(2)]; %Get direction to target
                direction = direction/norm(direction); %Convert it to a unit vector
                obj.xy = obj.xy + (direction * effective_speed);
                if (distToPoint(obj.xy, obj.dest_xy) < effective_speed/2) %If it's close enough to the point...
                    obj.dest_xy = []; %Remove destination
                    obj.waitTimer = 10; %Set a 10-step wait for reproduction
                end
            end
            obj.lifespan = obj.lifespan - 1;
            obj.saturation = obj.saturation - (1 + (obj.genes(2))^2);
            if (obj.waitTimer ~= 0) %If it's not yet 0 (aka the animal is not moving)
               obj.waitTimer = obj.waitTimer - 1; %Subtract timer by 1 to get it closer to moving
            end
        end
        function goto(obj, coordinate)
           %Makes the animal go towards something, used for hunger and mating purposes
           selfcoord = obj.xy;
           direction_vec = coordinate - selfcoord; %placeholder vector
           obj.move_dir = direction_vec/norm(direction_vec); %creates a unit vector for direction
           obj.move_duration = randi([10, 15]); %duration of the animals movement in this direction
        end
        
        function closest = findClosest(obj, animal_list)
            coords = obj.xy;
            anlength = length(animal_list);
            xlist = zeros(1, anlength);
            ylist = zeros(1, anlength);
            k = 1;
            while (k <= anlength) %Has to be a while loop in order to skip animals w/ same coords
                if (animal_list(k).xy == coords)
                    xlist(k) = 1000000; %Make the difference big enough that it's ignored
                    ylist(k) = 1000000;
                    k = k + 1;
                else
                    a = animal_list(k).xy;
                    xlist(k) = abs(a(1)-coords(1)); %Gives change in x
                    ylist(k) = abs(a(2)-coords(2)); %Gives change in y
                    k = k + 1;
                end
            end
            hypotenuse = sqrt(xlist.^2+ylist.^2);
            [~, closest] = min(hypotenuse);
        end
        function c = cross(~, a, b)
            ab = a.*b;
            r = rand;
            c = (1/(1+sqrt((1-a-b+ab)./ab))) + 0.01*((-1)^(round(rand)))*(log(r)-log(1-r));
        end
        function s_out = sig(~, x)
           s_out = (1./(1+exp(-x))); 
        end
        function as_out = antisigmoid(~, x)
           as_out = log(x)-log(1-x); 
        end
        function d = distToPoint(~, x, y)
           yx = [y(1)-x(1), y(2)-x(2)];
           d = sqrt((yx(1)^2)+(yx(2)^2));
        end
    end
end