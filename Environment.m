classdef Environment < handle
   properties
      % User specified properties
      env_size;
      food_multiplier;
      % Other properties
      animals = [];
      predators = [];
      food = []; %A list of food for animals to eat
      animal_gene_count;
      predator_gene_count;
      animal_reproduction_queue = []; %A vector for queuing offspring
      predator_reproduction_queue = [];
      
      total_births; %For plotting the data of total births
      total_deaths; %For plotting the data of total deaths
   end
   % Have functions for iteration (running step functions of all animals
   % and checking if anything's died/changed), reproduction, death, changes
   % in resources, etc.
   methods
       function obj = Environment(~, envsize, animalcount, predatorcount, foodmultiplier)
           obj.env_size = envsize;
           obj.food_multiplier = foodmultiplier;
           obj.food = rand(4,2) * envsize;
           obj.animals = BetaAnimal.empty(0, animalcount);
           obj.predators = PredatorV2.empty(0, predatorcount);
           for i = 1:animalcount
              obj.animals(i) = BetaAnimal(0, obj.env_size);
           end
           for j = 1:predatorcount
              obj.predators(j) = PredatorV2(0, obj.env_size); 
           end
           obj.animal_gene_count = obj.animals(1).GENECOUNT; %Get the quantity of the genes, save it to variable
           obj.predator_gene_count = obj.predators(1).GENECOUNT;
           obj.total_births = 0;
           obj.total_deaths = 0;
       end
       
       
       
       function iterate(obj, stepnum)
          % Update all step functions of each animal + regular checks for things
          
          prlength = length(obj.predators);        
          anlength = length(obj.animals);
          %find number of animals and predators
          
          for i = 1:anlength
              should_run = 1;
              %determines if an animal should run or not (only here because
              %of a weird crash where if an animal tried to evade a
              %predator in specific conditions, a crash would occur
              foodsize = size(obj.food, 1); %number of food items on the field
              a = obj.animals(i);
              axy = a.xy;
              distances = zeros(1,foodsize);
              %preallocates the distances array for food
              if foodsize > 0 %only calls if food is present to prevent crashes
                  for j = 1:foodsize
                      foodxy = [obj.food(j,1), obj.food(j,2)];
                      distances(j) = obj.getDistance(axy,foodxy);
                      %finds the distance from the animal to each food item
                  end
                  [dist_food, food_num] = min(distances);
                  %finds the closest food item, and how far it is
              end
              
              distances = zeros(1,prlength);
              %preallocates distances for predators
              
              for j = 1:prlength
                  p = obj.predators(j);
                  pxy = p.xy;
                  distances(j) = obj.getDistance(axy,pxy);
                  %checks the distance from the animal to each predator
              end
              
              [dist_threat, threat] = min(distances);
              %finds the closest predator and how far away it is
              if foodsize > 0 && dist_food <= 2 && a.saturation <= 70
                   a.saturation = 100;
                   obj.food(food_num,:) = [];
                   %foodsize check prevents crashes from dist_food
                   %potentially not existing
                   %if food is close enough and the animal is hungry it
                   %will eat
              end
              
                if (axy(1) <= 0 && axy(2) <= 0) || (axy(1) <= a.env_size && axy(2) >= a.env_size) || (axy(1) >= a.env_size && axy(2) <= 0) || (axy(1) >= a.env_size && axy(2) >= a.env_size)
                    should_run = 0;
                    %for an unknown reason if an animal ended up exactly in
                    % a corner of the environment, a crash would occur if
                    % it was running from a predator, this fixes that
                end
                
                if dist_threat <= a.awareness && should_run == 1
                    p = obj.predators(threat);
                    pxy = p.xy;
                    a.runAway(pxy)
                    a.move_duration = 3;
                    %if runs away from the nearest predator in awareness
                elseif foodsize > 0 && dist_food <= a.awareness && a.saturation <= 60 && foodsize > 0 
                   foodxy = [obj.food(food_num,1), obj.food(food_num,2)];
                   a.goto(foodxy);
                   a.move_duration = 2;
                   %foodsize check prevents crashes, if it was = 0, then
                   %dist_food does not exist = crash
                   %if would is in awarness and animal is hungry and the
                   %animal is not too close to a predator
               end
          end
          
          
          for i = 1:prlength
              anlength = length(obj.animals); 
              %initalized each time due to potential changes in size
              p = obj.predators(i);
              pxy = p.xy;
              distances = zeros(1, anlength);
              if anlength > 0
                  for j = 1:anlength
                      a = obj.animals(j);
                      axy = a.xy;
                      distances(j) = obj.getDistance(axy,pxy);
                      %finds the distance to each animal
                  end

                  [dist,target] = min(distances);
                  %find the closest animal and distance to it
                  
                  if dist <= 2 && p.saturation <= 80
                      obj.animals(target) = [];
                      p.saturation = 100;
                      %if close to animal and hungry enough, animal gets eaten
                  elseif dist <= p.awareness && p.saturation <= 80
                    a = obj.animals(target);
                    axy = a.xy;
                    p.findDirection(axy)
                    %if an animal is within awareness and predator is
                    %hungry, it will target the animal
                  end
              end
             
          end
          
          for i = 1:length(obj.animals)
              a = obj.animals(i);
              a.step;
          end
          % every animal has the step function executed, moving to new
          % positions and making all their checks
          
          for j = 1:length(obj.predators)
              p = obj.predators(j);
              p.step;
          end
          % every predator has the step function executed, moving to new
          % positions and making all their checks
          
          obj.checkMortality; %Check if any animals died after walking
          obj.checkPredatorMortality; %check if predators died
    
                    
          
          fert = obj.findFertileAnimals;
          
          
          o = 1;
          while (o <= length(fert))
              choices = 1:length(fert); %1, 2, 3, ...
              choices = choices(choices~=o); %Remove self from list
              selfxy = obj.animals(fert(o)).xy;
              dist_to_self = zeros(1, length(choices));
              for p = 1:length(choices) %For every fertile non-self animal...
                  % Build matrix of coordinate differences
                  otheranimal = obj.animals(fert(choices(p)));
                  dist_to_self(p) = obj.getDistance(otheranimal.xy, selfxy); 
              end        
              dist_to_candidate = min(dist_to_self);
              closest_candidate = 0; %Closest candidate within "choices" list
              if (dist_to_candidate < 8)
                 
                 [~, closest_candidate] = min(dist_to_self); %Save index to a variable
                  
                 obj.reproduce(o, fert(choices(closest_candidate)), stepnum); %IS THIS GOOD???
              end
              o = o + 1;
          end
          
          % Check the reproduction queue to see if it's time to spawn in a
          % baby
          if (~isempty(obj.animal_reproduction_queue) && any(stepnum==obj.animal_reproduction_queue(:,1))) %If a baby should be born...
    

              index = find(stepnum==obj.animal_reproduction_queue(:,1)); %Index of the baby in the queue
                if (length(index) > 1) % if there's an overlapping animal..
                    index = index(1);   % Take only the first one
                end

              obj.animals = [obj.animals BetaAnimal(0, obj.env_size)]; %CREATE THE BABY!
              obj.total_births = obj.total_births + 1; %Increase total birth count by 1

              alength = length(obj.animals);
              obj.animals(alength).xy = [obj.animal_reproduction_queue(index, 2), obj.animal_reproduction_queue(index, 3)];
              queue_width = size(obj.animal_reproduction_queue, 2); %Width of the reproduction queue matrix
              for i = 4:queue_width
                  
 
                  
                  if (any(size(obj.animal_reproduction_queue(index, i)) ~= 1))
                     queuegenes = obj.animal_reproduction_queue(index, i);
                     obj.animals(alength).genes(i-3) = queuegenes(1);
                  end
                  obj.animals(alength).genes(i-3) = obj.animal_reproduction_queue(index, i);
              end
          end
          
          o = 1;
          pfert = obj.findFertilePredators;
          while (o <= length(pfert))
              choices = 1:length(pfert); %1, 2, 3, ...
              choices = choices(choices~=o); %Remove self from list
              selfxy = obj.predators(pfert(o)).xy;
              dist_to_self = zeros(1, length(choices));
          
              
              for p = 1:length(choices) %For every fertile non-self animal...
                  % Build matrix of coordinate differences
                  otherpredator = obj.predators(pfert(choices(p)));
                  dist_to_self(p) = obj.getDistance(otherpredator.xy, selfxy); 
              end
              dist_to_candidate = min(dist_to_self);
              closest_candidate = 0; %Closest candidate within "choices" list
              if (dist_to_candidate < 8)
                 [~, closest_candidate] = min(dist_to_self); %Save index to a variable
                 obj.reproducePredators(o, pfert(choices(closest_candidate)), stepnum); %IS THIS GOOD???
              end
              o = o + 1;
          end
          
          if (~isempty(obj.predator_reproduction_queue) && any(stepnum==obj.predator_reproduction_queue(:,1))) %If a baby should be born...
               
              index = find(stepnum==obj.predator_reproduction_queue(:,1)); %Index of the baby in the queue
              if (length(index) > 1) %if there's an overlapping predator
                  index = index(1);  %Take only the first one
              end

              obj.predators = [obj.predators PredatorV2(0, obj.env_size)]; %CREATE THE BABY!
              obj.total_births = obj.total_births + 1; %Increase total birth count by 1
               
              plength = length(obj.predators);
              obj.predators(plength).xy = [obj.predator_reproduction_queue(index, 2), obj.predator_reproduction_queue(index, 3)];
              queue_width = size(obj.predator_reproduction_queue, 2); %Width of the reproduction queue matrix
              for i = 4:queue_width
                  if (any(size(obj.predator_reproduction_queue(index, i)) ~= 1))
                     queuegenes = obj.predator_reproduction_queue(index, i);
                     obj.predators(plength).genes(i-3) = queuegenes(1);
                  end
                  obj.predators(plength).genes(i-3) = obj.predator_reproduction_queue(index, i);
              end
          end
          
       end
       
       
       
       
       function spawnFood(obj, foodcount, ignoreMultiplier)
          switch ignoreMultiplier
              case 0
                  quantity = round(foodcount * obj.food_multiplier);
              case 1
                  quantity = round(foodcount);
          end
          obj.food = [obj.food; rand(quantity,2)*obj.env_size]; %Just concatenate x amount of food to the variable
       end
       function coords = getAnimalCoords(obj)
          coordslist = zeros(length(obj.animals), 2);
          for i = 1:length(obj.animals)
              a = obj.animals(i);
              coordslist(i,:) = a.xy;
          end
          coords = coordslist;
       end
       function pcoords = getPredatorCoords(obj)
          %fprintf("Predator Length: %d\n", length(obj.predators));
          coordslist = zeros(length(obj.predators), 2);
          for i = 1:length(obj.predators)
              p = obj.predators(i);
              coordslist(i,:) = p.xy;
          end
          pcoords = coordslist;
       end
       function checkMortality(obj)
          i = 1;
          while (i < length(obj.animals))
             % Check each animal individually if they are dead, remove them if so
             a = obj.animals(i);
             if (a.isDead == 1)
                % The animal died, remove it from the loop
                obj.animals(i) = [];
                obj.total_deaths = obj.total_deaths + 1; %Increase total deaths by 1
                i = i - 1; %Add this to prevent a potentially dead animal from being skipped
             end
             i = i + 1;
          end
       end
       function checkPredatorMortality(obj)
          i = 1;
          while (i < length(obj.predators))
             % Check each animal individually if they are dead, remove them if so
             a = obj.predators(i);
             if (a.isDead == 1)
                % The animal died, remove it from the loop
                obj.predators(i) = [];
                obj.total_deaths = obj.total_deaths + 1;
                i = i - 1; %Add this to prevent a potentially dead animal from being skipped
             end
             i = i + 1;
          end
       end
       function g = getAverageGenes(obj, gene_index)
          % Get the average value of a certain gene for a population
          if (~isempty(obj.animals))
              gsum = zeros(1,length(obj.animals)); %A value for summing up the genes to average them all
          else
              gsum = 0;
          end
          switch (isempty(obj.animals))
              case 0
                  for i = 1:length(obj.animals)
                    gsum(i) = obj.animals(i).genes(gene_index);
                  end
              case 1
                  gsum = 0;
          end
          g = mean(gsum);
       end
       
       function p = getAveragePredatorGenes(obj, gene_index)
          % Get the average value of a certain gene for a population
          if (~isempty(obj.predators))
              gsum = zeros(1,length(obj.predators)); %A value for summing up the genes to average them all
          else
              gsum = 0;
          end
          switch (isempty(obj.predators))
              case 0
                  for i = 1:length(obj.predators)
                    gsum(i) = obj.predators(i).genes(gene_index);
                  end
              case 1
                  gsum = 0;
          end
          p = mean(gsum);
       end
       
       function d = getDistance(~, A, B)
          % Point A and B are 2-element vectors
          pointdiff = [B(1)-A(1), B(2)-A(2)];
          d = sqrt((pointdiff(1)^2)+(pointdiff(2)^2));
       end
       
       function f = findFertileAnimals(obj)
           fertile_animals = zeros(length(obj.animals));
           for i = 1:length(obj.animals)
              if (obj.animals(i).isFertile == 1)
                  fertile_animals(i) = i;
              end
           end
           f = fertile_animals(fertile_animals~=0);
       end
       
       function fp = findFertilePredators(obj)
           fertile_predators = zeros(length(obj.predators));
           for i = 1:length(obj.predators)
              if (obj.predators(i).isFertile == 1)
                  fertile_predators(i) = i;
              end
           end
           fp = fertile_predators(fertile_predators~=0);
       end
       
       function reproduce(obj, a, b, current_step)
          % A and B are indices of the two animals that are going to reproduce
          % This function instructs animals to meet at a certain
          % coordinate, wait and reproduce
          xya = obj.animals(a).xy;
          xyb = obj.animals(b).xy;
          xydest = [0.5*(xya(1)+xyb(1)), 0.5*(xya(2)+xyb(2))]; %Get average of both coordinates
          separation_distance = round(norm(xydest));
          %Make both animals go to a common point

          step_for_birth = current_step + separation_distance + 10; %This is the step when the baby should be born

          
          offspring_genes = obj.genecross(obj.animals(a).genes, obj.animals(b).genes);
          % Check if there's any other offspring being born on the step (a
          % bug-fixing check)
%           disp(size(obj.animal_reproduction_queue));
          if (~isempty(obj.animal_reproduction_queue))
              if any(step_for_birth==obj.animal_reproduction_queue(:,1))
                  step_for_birth = step_for_birth + 1;
              end
          end
          obj.animal_reproduction_queue = [obj.animal_reproduction_queue; step_for_birth, xydest, offspring_genes]; %Add baby + genes to queue
          % Reset the fertility and fertility countdowns to prevent a flood
          % of babies in the environment
          obj.animals(a).isFertile = 0;
          obj.animals(a).fertility_countdown = obj.animals(a).initial_lifespan/5;
          obj.animals(b).isFertile = 0;
          obj.animals(b).fertility_countdown = obj.animals(b).initial_lifespan/5;
       end
       function reproducePredators(obj, a, b, current_step)
          % A and B are indices of the two animals that are going to reproduce
          % This function instructs animals to meet at a certain
          % coordinate, wait and reproduce
          xya = obj.predators(a).xy;
          xyb = obj.predators(b).xy;
          xydest = [0.5*(xya(1)+xyb(1)), 0.5*(xya(2)+xyb(2))]; %Get average of both coordinates
          separation_distance = round(norm(xydest));
          step_for_birth = current_step + separation_distance + 10; %This is the step when the baby should be born
          offspring_genes = obj.genecross(obj.predators(a).genes, obj.predators(b).genes);
          % Check if there's any other offspring being born on the step (a
          % bug-fixing check)
          if (~isempty(obj.predator_reproduction_queue))
              if any(step_for_birth==obj.predator_reproduction_queue(:,1))
                  step_for_birth = step_for_birth + 1;
              end
          end
          obj.predator_reproduction_queue = [obj.predator_reproduction_queue; step_for_birth, xydest, offspring_genes]; %Add baby + genes to queue
          % Reset the fertility and fertility countdowns to prevent a flood
          % of babies in the environment
          obj.predators(a).isFertile = 0;
          obj.predators(a).fertility_countdown = obj.predators(a).initial_lifespan/5;
          obj.predators(b).isFertile = 0;
          obj.predators(b).fertility_countdown = obj.predators(b).initial_lifespan/5;
       end
       function c = genecross(~, a, b)
            ab = a.*b;
            r = rand;
            c = (1./(1+sqrt((1-a-b+ab)./ab))) + 0.01*((-1)^(round(rand)))*(log(r)-log(1-r));
       end
   end
end