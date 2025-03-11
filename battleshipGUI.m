function battleshipGUI()
% BATTLESHIPGUI - Graphical user interface for the Battleship game
% This is a GUI version of battleship.m that uses MATLAB's figure and
% uicontrol components to create an interactive game experience.
    
    % Initialize game data
    gameData = struct();
    gameData.playerGrid = zeros(10, 10);
    gameData.computerGrid = zeros(10, 10);
    gameData.playerShots = zeros(10, 10);
    gameData.computerShots = zeros(10, 10);
    gameData.gameState = 'setup'; % setup, placing, playing, gameover
    gameData.difficulty = 1;
    gameData.currentShip = 1;
    gameData.ships = struct('name', {'Battleship', 'Cruiser', 'Destroyer'}, ...
                           'length', {4, 3, 2}, 'placed', {false, false, false});
    gameData.playerHits = [0, 0, 0];  % Hits on each player ship
    gameData.computerHits = [0, 0, 0]; % Hits on each computer ship
    gameData.playerTurn = true;
    
    % Create main figure
    fig = figure('Name', 'Battleship', 'Position', [100, 100, 1000, 600], ...
                 'MenuBar', 'none', 'NumberTitle', 'off', 'Color', [0.9 0.9 0.95], ...
                 'CloseRequestFcn', @closeGame);
    
    % Save gameData in figure
    setappdata(fig, 'gameData', gameData);
    
    % Create control panel
    controlPanel = uipanel('Position', [0.02, 0.02, 0.2, 0.96], 'Title', 'Control Panel', ...
                          'BackgroundColor', [0.9 0.9 0.95]);
    
    % Create difficulty selector
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 520, 120, 20], ...
              'String', 'Difficulty:', 'BackgroundColor', [0.9 0.9 0.95]);
    difficultySelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                  'Position', [20, 490, 120, 25], ...
                                  'String', {'Easy', 'Medium', 'Hard'}, ...
                                  'Callback', @setDifficulty);
    
    % Start game button
    startButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                           'Position', [20, 440, 120, 40], ...
                           'String', 'Start Game', 'Callback', @startGame);
    
    % Orientation selector (for ship placement)
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 390, 120, 20], ...
              'String', 'Orientation:', 'BackgroundColor', [0.9 0.9 0.95]);
    orientationSelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                   'Position', [20, 360, 120, 25], ...
                                   'String', {'Horizontal', 'Vertical'});
    
    % Instructions button
    instructionsButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                                 'Position', [20, 310, 120, 30], ...
                                 'String', 'Instructions', 'Callback', @showInstructions);
    
    % Simulation button (NEW ELEMENT)
    simulationButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                               'Position', [20, 260, 120, 30], ...
                               'String', 'Run Simulation', 'Callback', @runSimulation);
    
    % Status field
    statusText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
                         'Position', [10, 50, 160, 200], ...
                         'String', 'Select difficulty and click Start Game', ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.9 0.9 0.95]);
    
    % Create game boards as axes
    playerBoard = axes('Position', [0.25, 0.1, 0.35, 0.8]);
    title('Your Board');
    
    enemyBoard = axes('Position', [0.65, 0.1, 0.35, 0.8]);
    title('Opponent''s Board');
    
    % Draw grid for both boards
    drawGrid(playerBoard);
    drawGrid(enemyBoard);
    
    % Save UI references for later use
    handles = struct();
    handles.fig = fig;
    handles.controlPanel = controlPanel;
    handles.difficultySelector = difficultySelector;
    handles.orientationSelector = orientationSelector;
    handles.startButton = startButton;
    handles.statusText = statusText;
    handles.playerBoard = playerBoard;
    handles.enemyBoard = enemyBoard;
    handles.simulationButton = simulationButton; % NEW ELEMENT
    setappdata(fig, 'handles', handles);
    
    % Disable enemy board until game is started
    set(enemyBoard, 'ButtonDownFcn', []);
    
    % Set playerBoard to handle ship placement
    % This is activated after the game starts
    set(playerBoard, 'ButtonDownFcn', []);
    
    % Show welcome screen
    showWelcomeScreen(fig);
end