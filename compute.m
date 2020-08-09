% Environment Simulator - Computational/Visual File

function compute(envsize, animalcount, predatorcount, stepcount, foodmultiplier, foodfrequency)
    % Copy over all inputs as their own variables
    env_size = envsize;
    ancount = animalcount;
    initial_animal_population_size = animalcount;
    initial_predator_population_size = predatorcount;
    steps = stepcount;
    
    isFigureClosed = 0; %A boolean for determining the continuity of the program
    
    % Initialize the environment class
    ENV = Environment(0, env_size, ancount, predatorcount, foodmultiplier);
    
    envmat = zeros(env_size);
    
    % Create a series of vectors used for plotting information at the end
    % of the simulation.
    gene_plot = zeros(ENV.animal_gene_count, steps); %Each row represents a different gene over time
    pgene_plot = zeros(ENV.predator_gene_count, steps);
    population_size_plot = zeros(1, steps);
    predator_population_size_plot = zeros(1, steps);
    total_births_plot = zeros(1, steps);
    total_deaths_plot = zeros(1, steps);
    food_over_time_plot = zeros(1, steps);
    
    % Generate a colormap for the visualization matrix
    cmap = [0.0, 0.0, 0.0; % [0] Black for empty space
            1.0, 1.0, 1.0; % [1] White for the animals
            0.0, 0.0, 1.0; % [2] Blue for the resources (food/water)
            1.0, 0.0, 0.0; % [3] Red for the predators
            1.0, 0.5, 1.0; % [4] Pink for the fertile animals
            0.5, 0.0, 0.0; % [5] Dark red for the fertile predators
            0.0, 0.0, 0.0]; % Finally, black again for a special buffer colour
        
    im = image(envmat);
    set(gcf, 'Position', [960-500, 0, 1000, 1000]); %Default is 100, 100, 500, 500 (this fixes window size)
    set(gca, 'CLim', [0, 3]); 
    colormap(cmap);
    for i = 1:steps
        
%         fprintf("Step %d\n", i);
        %Reset the graphics matrix
        envmat = zeros(env_size);
        
        % Compute all of the next steps and save the genes
        ENV.iterate(i);
        for j = 1:ENV.animal_gene_count
            gene_plot(j, i) = ENV.getAverageGenes(j);
        end
        for jj = 1:ENV.predator_gene_count
            pgene_plot(jj, i) = ENV.getAveragePredatorGenes(jj); 
        end
        
        % Check if it's time to spawn in food (every 50 steps by default)
        if (round(rem(i, 50/foodfrequency)) == 0) && (~isempty(ENV.animals)) %Every 50 steps if there's animals...
            foodquantity = size(ENV.food, 1);
            foodquantity = sqrt(foodquantity);
            ENV.spawnFood(env_size/(foodquantity + 1), 0);
        end
        food_over_time_plot(i) = size(ENV.food, 1);
        
        % Randomly delete some food to prevent buildup
        
        % Visualize all animals
        animal_coordinates = ENV.getAnimalCoords;
        for k = 1:length(ENV.animals) %For each animal...
            % Save coordinates to a variable and round it
            coords = animal_coordinates(k,:);
            coords = round(coords);
            
            % Check coordinates to avoid matrix boundary errors
            if (coords(1) <= 0)
                coords(1) = 1; 
            end
            if (coords(2) <= 0)
                coords(2) = 1;
            end
            if (coords(1) > env_size)
               coords(1) = env_size; 
            end
            if (coords(2) > env_size)
                coords(2) = env_size;
            end
            
            % Add it to the matrix
            envmat(coords(1), coords(2)) = 1;
            if (ENV.animals(k).isFertile == 1)
               envmat(coords(1), coords(2)) = 4; 
            end
        end
        
        % Visualize all predators
        predator_coordinates = ENV.getPredatorCoords;
        for m = 1:length(ENV.predators) %For each animal...
            % Save coordinates to a variable and round it
            coords = predator_coordinates(m,:);
            coords = round(coords);
            
            % Check coordinates to avoid matrix boundary errors
            if (coords(1) <= 0)
                coords(1) = 1; 
            end
            if (coords(2) <= 0)
                coords(2) = 1;
            end
            if (coords(1) > env_size)
               coords(1) = env_size; 
            end
            if (coords(2) > env_size)
                coords(2) = env_size;
            end
            
            % Add it to the matrix
            envmat(coords(1), coords(2)) = 3;
            if (ENV.predators(m).isFertile == 1)
                envmat(coords(1), coords(2)) = 5;
            end
        end
        
        % Visualize all food items
        if (size(ENV.food, 1) > 0)
            for n = 1:size(ENV.food, 1)
                food_item = ENV.food(n,:); %Save each row as a variable for easier use
                food_item = round(food_item); %Round everything so it can be displayed
                %Prevent matrix rounding issues
                if (food_item(1) < 1)
                    food_item(1) = 1; 
                end
                if (food_item(2) < 1)
                    food_item(2) = 1;
                end
                if (food_item(1) > env_size)
                    food_item(1) = env_size;
                end
                if (food_item(2) > env_size)
                    food_item(2) = env_size;
                end
                envmat(food_item(1), food_item(2)) = 2;
            end
        end
        
        envmat(env_size,env_size) = size(cmap, 1)-1; % Add buffer colour to prevent visual glitches
        
        % Check if the simulation has been closed
        if ~ishghandle(im) %If window is closed...
            isFigureClosed = 1; %The figure is now closed
            break; %Stop the program
        end
        
        % Update the environment plot
        im = image(envmat, 'CDataMapping', 'scaled'); %Update plot
        set(gcf, 'Name', 'Simulation in Progress...', 'NumberTitle', 'off');
        t = "Environment Simulation [" + i + " / " + steps + "]"; %Create a title string
        title(['\fontsize{16}',t]);
        pause(0.005);
        
        % Finally, save the population's genes to the gene plot vector
        for y = 1:ENV.animal_gene_count
            gene_plot(y, i) = ENV.getAverageGenes(y);
        end
        for yy = 1:ENV.predator_gene_count
            pgene_plot(yy, i) = ENV.getAveragePredatorGenes(yy); 
        end
        population_size_plot(i) = length(ENV.animals);
        predator_population_size_plot(i) = length(ENV.predators);
        total_births_plot(i) = ENV.total_births;
        total_deaths_plot(i) = ENV.total_deaths;
    end
    
    %After the calculations, close the matrix and display the plot results
    if (isFigureClosed == 0 || ~ishghandle(im))
        close;
        tiledlayout(2, 2);
        set(gcf, 'Position', [960-840, 540-360, 1680, 720]);
        set(gcf, 'Name', 'Results', 'NumberTitle', 'off');
    
        nexttile;
        hold on;
        for z = 1:ENV.animal_gene_count %For each gene...
            plot(1:steps, gene_plot(z, :)); %Plot each column
        end
        title("Average Value of Genes over Time");
        legend("Lifespan", "Movement Speed", "Speed Variance", "Directional Continuity", "Hunger Modifier", ...
            "Rate of Maturity", "Awareness");
        legend('Location', 'eastoutside'); %Move legend off of plot to make it cleaner
        axis([1, steps, 0, 1]);
        xlabel("Step Number");
        ylabel("Gene Value");
    
        nexttile;
        hold on;
        for zz = 1:ENV.predator_gene_count %For each gene...
            plot(1:steps, pgene_plot(zz, :)); %Plot each column
        end
        title("Average Value of Predator Genes over Time");
        legend("Lifespan", "Movement Speed", "Speed Variance", "Directional Continuity", "Hunger Modifier", ...
            "Rate of Maturity", "Awareness");
        legend('Location', 'eastoutside'); %Move legend off of plot to make it cleaner
        axis([1, steps, 0, 1]);
        xlabel("Step Number");
        ylabel("Gene Value");
    
        nexttile;
        plot(1:steps, population_size_plot, 'b', 1:steps, predator_population_size_plot, 'r');
        title("Population Size over Time");
        xlabel("Step Number");
        ylabel("Number of Animals");
        legend('Animals', 'Predators');
        legend('Location', 'eastoutside');
        
        nexttile;
        plot(1:steps, total_births_plot, 'm', 1:steps, total_deaths_plot, 'r', 1:steps, food_over_time_plot, 'g');
        title("Miscellaneous Stats over Time");
        xlabel("Step Number");
        ylabel("Quantity");
        legend('Total Births', 'Total Deaths', 'Food Quantity');
        legend('Location', 'eastoutside');
    end    
end