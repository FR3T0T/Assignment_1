function battleshipGUI()
% BATTLESHIPGUI - Grafisk brugergrænseflade til Battleship-spillet
% Dette er en GUI-version af battleship.m som bruger MATLAB's figure og
% uicontrol komponenter til at skabe en interaktiv spiloplevelse.
    
    % Initialiser spilledata
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
    
    % Opret hovedfigur
    fig = figure('Name', 'Battleship', 'Position', [100, 100, 1000, 600], ...
                 'MenuBar', 'none', 'NumberTitle', 'off', 'Color', [0.9 0.9 0.95], ...
                 'CloseRequestFcn', @closeGame);
    
    % Gem gameData i figure
    setappdata(fig, 'gameData', gameData);
    
    % Opret kontrolpanel
    controlPanel = uipanel('Position', [0.02, 0.02, 0.2, 0.96], 'Title', 'Kontrolpanel', ...
                          'BackgroundColor', [0.9 0.9 0.95]);
    
    % Opret sværhedsgrad-selector
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 520, 120, 20], ...
              'String', 'Sværhedsgrad:', 'BackgroundColor', [0.9 0.9 0.95]);
    difficultySelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                  'Position', [20, 490, 120, 25], ...
                                  'String', {'Let', 'Medium', 'Svær'}, ...
                                  'Callback', @setDifficulty);
    
    % Start spil-knap
    startButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                           'Position', [20, 440, 120, 40], ...
                           'String', 'Start Spil', 'Callback', @startGame);
    
    % Orientering-selector (til skibsplacering)
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 390, 120, 20], ...
              'String', 'Orientering:', 'BackgroundColor', [0.9 0.9 0.95]);
    orientationSelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                   'Position', [20, 360, 120, 25], ...
                                   'String', {'Vandret', 'Lodret'});
    
    % Instruktioner-knap
    instructionsButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                                 'Position', [20, 310, 120, 30], ...
                                 'String', 'Instruktioner', 'Callback', @showInstructions);
    
    % Statusfelt
    statusText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
                         'Position', [10, 50, 160, 250], ...
                         'String', 'Vælg sværhedsgrad og klik på Start Spil', ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.9 0.9 0.95]);
    
    % Opret spillebrætter som axes
    playerBoard = axes('Position', [0.25, 0.1, 0.35, 0.8]);
    title('Dit bræt');
    
    enemyBoard = axes('Position', [0.65, 0.1, 0.35, 0.8]);
    title('Modstanderens bræt');
    
    % Tegn grid for begge brætter
    drawGrid(playerBoard);
    drawGrid(enemyBoard);
    
    % Gem UI-referencer til senere brug
    handles = struct();
    handles.fig = fig;
    handles.controlPanel = controlPanel;
    handles.difficultySelector = difficultySelector;
    handles.orientationSelector = orientationSelector;
    handles.startButton = startButton;
    handles.statusText = statusText;
    handles.playerBoard = playerBoard;
    handles.enemyBoard = enemyBoard;
    setappdata(fig, 'handles', handles);
    
    % Deaktiver fjendebræt indtil spillet er startet
    set(enemyBoard, 'ButtonDownFcn', []);
    
    % Set playerBoard til at håndtere placeringen af skibe
    % Dette aktiveres efter spillet startes
    set(playerBoard, 'ButtonDownFcn', []);
    
    % Vis velkomstskærm
    showWelcomeScreen(fig);
end