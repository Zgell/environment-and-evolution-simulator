%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Course: ENCMP 100
% ENCMP 100 Programming Contest Entry (Winter 2020)
% Created by Zgell and C. Kotch
% For any inquiries, contact me at zgellner@ualberta.ca
%
% Description:
% This program will simulate an environment with different restraints that
% the user can customize in order to watch how the animals in the
% environment will react and evolve to overcome their obstacles.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The main body of code that initializes the whole program
function main
    clear;
    clc;
    
    % Create and name the interface
    gui = figure('Visible', 'off', 'color', 'white', 'Units', 'Normalized', 'Position', [0.25, 0.25, 0.5, 0.5], ... 
        'NumberTitle', 'off');
    gui.Name = 'Environment and Evolution Simulator';

    % Important Text in the GUI
    titletext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.15, 0.85, 0.7, 0.1], ...
    'String', 'Environment and Evolution Simulator', 'FontSize', 28); 
    errortext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.25, 0.75, 0.5, 0.1], ...
        'String', 'Please fill in each box with numbers only.', 'FontSize', 18, 'ForegroundColor', 'Red',...
        'BackgroundColor', 'White', 'Visible', 'off');

    % Set up all of the text in the GUI
    envsizetext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.75, 0.25, 0.04], ...
        'String', 'Enter environment size here:', 'FontSize', 12);
    ancounttext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.35, 0.75, 0.25, 0.04], ... %Height was 0.58
        'String', 'Enter number of animals here:', 'FontSize', 12);
    predcounttext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.65, 0.75, 0.25, 0.04], ...
        'String', 'Enter number of predators here:', 'FontSize', 12);
    stepnumbertext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.58, 0.25, 0.04], ... %Height was 0.41
        'String', 'Enter number of steps here:', 'FontSize', 12);
    foodmultitext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.35, 0.58, 0.25, 0.04], ...
        'String', 'Enter food multiplier here:', 'FontSize', 12);
    foodfreqtext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.65, 0.58, 0.25, 0.04], ... %Height was 0.58
        'String', 'Enter food frequency multiplier:', 'FontSize', 12);

    % Add in all of the text inputs
    envSizeInput = uicontrol('Style', 'edit', 'Units', 'Normalized', 'Position', [0.05, 0.66, 0.25, 0.075], ...
        'FontSize', 16, 'String', 96);
    animalCountInput = uicontrol('Style', 'edit', 'Units', 'Normalized', 'Position', [0.35, 0.66, 0.25, 0.075], ...
        'FontSize', 16, 'String', 28);
    predCountInput = uicontrol('Style', 'edit', 'Units', 'Normalized', 'Position', [0.65, 0.66, 0.25, 0.075], ...
        'FontSize', 16, 'String', 6);
    stepNumberInput = uicontrol('Style', 'edit', 'Units', 'Normalized', 'Position', [0.05, 0.49, 0.25, 0.075], ...
        'FontSize', 16, 'String', 750);
    foodMultiInput = uicontrol('Style', 'edit', 'Units', 'Normalized', 'Position', [0.35, 0.49, 0.25, 0.075], ...
        'FontSize', 16, 'String', 1);
    foodFreqInput = uicontrol('Style', 'edit', 'Units', 'Normalized', 'Position', [0.65, 0.49, 0.25, 0.075], ...
        'FontSize', 16, 'String', 1);

    % Add the start button and the credit text
    startButton = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Units', 'Normalized', 'Position', [0.6, 0.15, 0.3, 0.1],...
        'FontSize', 16, 'Callback',@cback);
    creditText = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0, 0.02, 0.2, 0.04], ... %Default: 0, 0.02, 0.3, 0.04
        'String', 'By Zgell and C. Kotch', 'FontSize', 12, 'backgroundcol', [1 1 1]);
    
    % Add the help menu button
    helpButton = uicontrol('Style', 'pushbutton', 'String', 'Help', 'Units', 'Normalized', 'Position', [0.1, 0.15, 0.3, 0.1],...
        'FontSize', 16, 'Callback',@help_menu);
    
    % Add the help menu stuff but make it invisible at the start
    backButton = uicontrol('Style', 'pushbutton', 'String', 'Back', 'Units', 'Normalized', 'Position', [0.1, 0.15, 0.3, 0.1],...
        'FontSize', 16, 'Callback',@back, 'Visible', 'off');
    helptitletext = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.34, 0.85, 0.3, 0.1], ...
    'String', 'Help', 'FontSize', 28, 'Visible', 'off');
    tip_envsize_header = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.75, 0.17, 0.04], ...
        'String', 'Environment Size', 'FontSize', 12, 'Visible', 'off');
    tip_envsize = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.25, 0.75, 0.5, 0.04], ...
        'String', 'Sets the size of the area that animals can roam. Animals move about 3-4 units/step.', ...
        'FontSize', 12, 'Visible', 'off', 'backgroundcol', [1 1 1]);
    tip_ancount_header = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.69, 0.17, 0.04], ...
        'String', 'Animal Count', 'FontSize', 12, 'Visible', 'off');
    tip_ancount = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.25, 0.69, 0.35, 0.04], ...
        'String', 'The number of animals initially in the simulation.', ...
        'FontSize', 12, 'Visible', 'off', 'backgroundcol', [1 1 1]);
    tip_prcount_header = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.63, 0.17, 0.04], ...
        'String', 'Predator Count', 'FontSize', 12, 'Visible', 'off');
    tip_prcount = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.25, 0.63, 0.36, 0.04], ...
        'String', 'The number of predators initially in the simulation.', ...
        'FontSize', 12, 'Visible', 'off', 'backgroundcol', [1 1 1]);
    tip_steps_header = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.57, 0.17, 0.04], ...
        'String', 'Step Number', 'FontSize', 12, 'Visible', 'off');
    tip_steps = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.23, 0.57, 0.33, 0.04], ...
        'String', 'The duration of the simulation, in steps.', ...
        'FontSize', 12, 'Visible', 'off', 'backgroundcol', [1 1 1]);
    tip_f1_header = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.51, 0.17, 0.04], ...
        'String', 'Food Multiplier', 'FontSize', 12, 'Visible', 'off');
    tip_f1 = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.23, 0.51, 0.53, 0.04], ...
        'String', 'A factor for multiplying the quantity of food that spawns periodically.', ...
        'FontSize', 12, 'Visible', 'off', 'backgroundcol', [1 1 1]);
    tip_f2_header = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.05, 0.45, 0.17, 0.04], ...
        'String', 'Food Frequency', 'FontSize', 12, 'Visible', 'off');
    tip_f2 = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [0.23, 0.45, 0.545, 0.04], ...
        'String', 'A factor for multiplying the frequency of food that spawns periodically.', ...
        'FontSize', 12, 'Visible', 'off', 'backgroundcol', [1 1 1]);
    

    movegui(gui, 'center');
    gui.Visible = 'on';

    % The function that activates when the start button is clicked
    function cback(hObject, eventdata)
        % Take all values from the text boxes and save them to the variables
        % here
        esize = str2double(envSizeInput.String);
        ancnt = str2double(animalCountInput.String);
        prcnt = str2double(predCountInput.String);
        numstep = str2double(stepNumberInput.String);
        fmulti = str2double(foodMultiInput.String);
        ffreq = str2double(foodFreqInput.String);
        if ((rem(esize, 1) ~= 0) || (rem(ancnt, 1) ~= 0) || (rem(prcnt, 1) ~= 0) || (rem(numstep, 1) ~= 0)) 
            %If an integer value is not an integer...
            % Correct the issue by rounding all values in question
            esize = round(esize);
            ancnt = round(ancnt);
            prcnt = round(prcnt);
            numstep = round(numstep);
        end
        % If all of the inputs are valid numbers...
        if ~isnan(esize) && ~isnan(ancnt) && ~isnan(prcnt) && ~isnan(numstep) && ~isnan(fmulti) && ~isnan(ffreq)
            %Erase the GUI
            titletext.Visible = 'off';
            errortext.Visible = 'off';
            
            envsizetext.Visible = 'off';
            ancounttext.Visible = 'off';
            predcounttext.Visible = 'off';
            stepnumbertext.Visible = 'off';
            foodmultitext.Visible = 'off';
            foodfreqtext.Visible = 'off';
            
            envSizeInput.Visible = 'off';
            animalCountInput.Visible = 'off';
            predCountInput.Visible = 'off';
            stepNumberInput.Visible = 'off';
            foodMultiInput.Visible = 'off';
            foodFreqInput.Visible = 'off';
            
            startButton.Visible = 'off';
            helpButton.Visible = 'off';
            backButton.Visible = 'off';
            creditText.Visible = 'off';
            
            close(gui);
            compute(esize, ancnt, prcnt, numstep, fmulti, ffreq);
        else %If one or more of the inputs are invalid...
            errortext.Visible = 'on'; %Show the user an error message
            pause(10);
            errortext.Visible = 'off'; %After 10 secs stop showing it
        end
    end

    function help_menu(hObject, eventdata)
        % Make everything but the help stuff invisible.
        titletext.Visible = 'off';
        errortext.Visible = 'off';
            
        envsizetext.Visible = 'off';
        ancounttext.Visible = 'off';
        predcounttext.Visible = 'off';
        stepnumbertext.Visible = 'off';
        foodmultitext.Visible = 'off';
        foodfreqtext.Visible = 'off';
            
        envSizeInput.Visible = 'off';
        animalCountInput.Visible = 'off';
        predCountInput.Visible = 'off';
        stepNumberInput.Visible = 'off';
        foodMultiInput.Visible = 'off';
        foodFreqInput.Visible = 'off';
            
        startButton.Visible = 'off';
        helpButton.Visible = 'off';
        creditText.Visible = 'off';
        
        % Make all of the help stuff visible
        backButton.Visible = 'on';
        helptitletext.Visible = 'on';
        tip_envsize_header.Visible = 'on';
        tip_envsize.Visible = 'on';
        tip_ancount_header.Visible = 'on';
        tip_ancount.Visible = 'on';
        tip_prcount_header.Visible = 'on';
        tip_prcount.Visible = 'on';
        tip_steps_header.Visible = 'on';
        tip_steps.Visible = 'on';
        tip_f1_header.Visible = 'on';
        tip_f1.Visible = 'on';
        tip_f2_header.Visible = 'on';
        tip_f2.Visible = 'on';
    end
    
    function back(hObject, eventdata)
        % Make all of the help stuff invisible
        backButton.Visible = 'off';
        helptitletext.Visible = 'off';
        tip_envsize_header.Visible = 'off';
        tip_envsize.Visible = 'off';
        tip_ancount_header.Visible = 'off';
        tip_ancount.Visible = 'off';
        tip_prcount_header.Visible = 'off';
        tip_prcount.Visible = 'off';
        tip_steps_header.Visible = 'off';
        tip_steps.Visible = 'off';
        tip_f1_header.Visible = 'off';
        tip_f1.Visible = 'off';
        tip_f2_header.Visible = 'off';
        tip_f2.Visible = 'off';
        
        % Make all of the main menu stuff visible again
        titletext.Visible = 'on';
        errortext.Visible = 'off';
            
        envsizetext.Visible = 'on';
        ancounttext.Visible = 'on';
        predcounttext.Visible = 'on';
        stepnumbertext.Visible = 'on';
        foodmultitext.Visible = 'on';
        foodfreqtext.Visible = 'on';
            
        envSizeInput.Visible = 'on';
        animalCountInput.Visible = 'on';
        predCountInput.Visible = 'on';
        stepNumberInput.Visible = 'on';
        foodMultiInput.Visible = 'on';
        foodFreqInput.Visible = 'on';
            
        startButton.Visible = 'on';
        helpButton.Visible = 'on';
        creditText.Visible = 'on';
    end
end