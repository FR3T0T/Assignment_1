function battleshipGUI()
% BATTLESHIPGUI - Grafisk brugergrænseflade til Battleship-spillet
% Dette er hovedfunktionen der starter spillet og opsætter GUI.
    
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
    
    % Opret hovedfigur med moderne styling
    fig = figure('Name', 'Battleship', 'Position', [100, 100, 1100, 650], ...
                 'MenuBar', 'none', 'NumberTitle', 'off', 'Color', [0.95 0.95 0.98], ...
                 'CloseRequestFcn', @closeGame);
    
    % Gem gameData i figure
    setappdata(fig, 'gameData', gameData);
    
    % Opret kontrolpanel
    controlPanel = uipanel('Position', [0.02, 0.02, 0.2, 0.96], 'Title', 'Kontrolpanel', ...
                          'BackgroundColor', [0.95 0.95 0.98], ...
                          'FontWeight', 'bold', 'FontSize', 11);
    
    % Lav pænere sektioner i kontrolpanelet
    uipanel('Parent', controlPanel, 'Title', 'Indstillinger', ...
          'Position', [0.05, 0.7, 0.9, 0.25], 'FontSize', 10, ...
          'BackgroundColor', [0.95 0.95 0.98]);
    
    % Opret sværhedsgrad-selector med mere beskrivende tekst
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 520, 120, 20], ...
              'String', 'Sværhedsgrad:', 'BackgroundColor', [0.95 0.95 0.98], ...
              'FontWeight', 'bold');
    
    difficultySelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                  'Position', [20, 490, 120, 25], ...
                                  'String', {'Let (tilfældige skud)', 'Medium (målrettet)', 'Svær (avanceret)'}, ...
                                  'Callback', @setDifficulty);
    
    % Start spil-knap med tydeligere design
    startButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                           'Position', [20, 440, 120, 40], ...
                           'String', 'Start Spil', 'FontWeight', 'bold', ...
                           'BackgroundColor', [0.3 0.6 0.3], 'ForegroundColor', 'white', ...
                           'Callback', @startGame);
    
    % Skibsplaceringssektion
    shipPanel = uipanel('Parent', controlPanel, 'Title', 'Skibsplacering', ...
          'Position', [0.05, 0.4, 0.9, 0.25], 'FontSize', 10, ...
          'BackgroundColor', [0.95 0.95 0.98]);
    
    % Orientering-selector med forklarende ikon
    uicontrol('Parent', shipPanel, 'Style', 'text', 'Position', [10, 60, 120, 20], ...
              'String', 'Orientering:', 'BackgroundColor', [0.95 0.95 0.98], ...
              'FontWeight', 'bold');
    
    orientationSelector = uicontrol('Parent', shipPanel, 'Style', 'popupmenu', ...
                                   'Position', [10, 35, 120, 25], ...
                                   'String', {'Vandret →', 'Lodret ↓'});
    
    % Visuelt hjælpepanel til skibsplacering
    uicontrol('Parent', shipPanel, 'Style', 'text', 'Position', [10, 10, 150, 20], ...
             'String', 'Klik på dit bræt for at placere', ...
             'BackgroundColor', [0.95 0.95 0.98], ...
             'HorizontalAlignment', 'left');
    
    % Hjælpe-sektion
    uipanel('Parent', controlPanel, 'Title', 'Hjælp', ...
          'Position', [0.05, 0.2, 0.9, 0.15], 'FontSize', 10, ...
          'BackgroundColor', [0.95 0.95 0.98]);
    
    % Instruktioner-knap med bedre placering
    instructionsButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                                 'Position', [20, 220, 120, 30], ...
                                 'String', 'Spilleregler', 'BackgroundColor', [0.4 0.5 0.8], ...
                                 'ForegroundColor', 'white', ...
                                 'Callback', @showInstructions);
    
    % Symbolforklaring
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 190, 120, 20], ...
             'String', 'Symbolforklaring:', 'FontWeight', 'bold', ...
             'BackgroundColor', [0.95 0.95 0.98], ...
             'HorizontalAlignment', 'left');
    
    % Symboler med farvekoder
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 90, 130, 95], ...
             'String', {'■ Blå: Dit skib', ...
                       'X Rød: Ramt', ...
                       'O Sort: Forbi', ...
                       '~ Vand (ikke ramt)'}, ...
             'BackgroundColor', [0.95 0.95 0.98], ...
             'HorizontalAlignment', 'left');
    
    % Statusfelt med bedre styling
    statusText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
                         'Position', [10, 10, 160, 70], ...
                         'String', 'Vælg sværhedsgrad og klik på "Start Spil"', ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.95 0.95 0.98], ...
                         'FontWeight', 'bold');
    
    % Opret spillebrætter som axes
    playerBoard = axes('Position', [0.25, 0.1, 0.35, 0.8], 'XColor', 'none', 'YColor', 'none', 'PickableParts', 'all');
    title('Dit bræt', 'FontWeight', 'bold', 'FontSize', 12);
    
    enemyBoard = axes('Position', [0.65, 0.1, 0.35, 0.8], 'XColor', 'none', 'YColor', 'none', 'PickableParts', 'all');
    title('Modstanderens bræt', 'FontWeight', 'bold', 'FontSize', 12);
    
    % Tilføj spillestatus-linje øverst
    gameStatusBar = uicontrol('Style', 'text', 'Position', [400, 620, 300, 25], ...
                             'String', 'Vælg indstillinger og start spillet', ...
                             'FontWeight', 'bold', 'FontSize', 11, ...
                             'BackgroundColor', [0.95 0.95 0.98]);
    
    % Tegn grid for begge brætter
    battleshipGrid('drawGrid', playerBoard);
    battleshipGrid('drawGrid', enemyBoard);
    
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
    handles.gameStatusBar = gameStatusBar;
    setappdata(fig, 'handles', handles);
    
    % Deaktiver fjendebræt indtil spillet er startet
    set(enemyBoard, 'ButtonDownFcn', []);
    
    % Set playerBoard til at håndtere placeringen af skibe
    % Dette aktiveres efter spillet startes
    set(playerBoard, 'ButtonDownFcn', []);
    
    % Vis velkomstskærm
    battleshipUI('showWelcomeScreen', fig);
end

function setDifficulty(src, ~)
    % Opdater sværhedsgrad
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    gameData.difficulty = get(src, 'Value');
    setappdata(fig, 'gameData', gameData);
end

function startGame(src, ~)
    disp('startGame aktiveret');  % Debug log

    % Start et nyt spil
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Nulstil spildatastrukturen
    gameData.playerGrid = zeros(10, 10);
    gameData.computerGrid = zeros(10, 10);
    gameData.playerShots = zeros(10, 10);
    gameData.computerShots = zeros(10, 10);
    gameData.gameState = 'placing';
    gameData.currentShip = 1;
    gameData.playerTurn = true;
    gameData.playerHits = [0, 0, 0];
    gameData.computerHits = [0, 0, 0];
    for i = 1:length(gameData.ships)
        gameData.ships(i).placed = false;
    end

    % Sæt placeShip funktion på brættet
    disp('Sætter placeShip funktion på brættet med anonymous function');
    set(handles.playerBoard, 'ButtonDownFcn', @(src,event) battleshipLogic('placeShip', src, event));
    disp('ButtonDownFcn sat med wrapper');
    
    % Opdater status
    shipName = gameData.ships(1).name;
    shipLength = gameData.ships(1).length;
    set(handles.statusText, 'String', sprintf('Placer dit %s\n(%d felter)\nVælg orientering og \nklik på dit bræt.', ...
                                           shipName, shipLength));
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', 'PLACER SKIBE: Vælg orientering og placer dine skibe');
    
    % Opdater brætterne
    battleshipGrid('drawGrid', handles.playerBoard);
    battleshipGrid('drawGrid', handles.enemyBoard);
    
    % Fremhæv hvilket skib der skal placeres
    title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', shipName, shipLength), 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
    
    % Placer computerens skibe
    gameData.computerGrid = battleshipAI('placeComputerShips', gameData.computerGrid, gameData.ships);
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function closeGame(src, ~)
    % Bekræft afslutning af spil
    choice = questdlg('Er du sikker på, at du vil afslutte spillet?', ...
        'Afslut Battleship', 'Ja', 'Nej', 'Nej');
    
    if strcmp(choice, 'Ja')
        delete(src);
    end
end