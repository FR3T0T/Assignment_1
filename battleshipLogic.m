function varargout = battleshipLogic(command, varargin)
% BATTLESHIPLOGIC - Spillogik funktioner til Battleship-spillet
%
% Kommandoer:
%   'placeShip'       - Håndterer placering af skibe
%   'fireShot'        - Håndterer skud fra spilleren
%   'computerTurn'    - Håndterer computerens tur
%   'validatePlacement' - Validerer om et skib kan placeres
%
% Se hver specifik funktion for flere detaljer om input parametre.

    switch command
        case 'placeShip'
            placeShip(varargin{:});
        case 'fireShot'
            fireShot(varargin{:});
        case 'computerTurn'
            computerTurn(varargin{:});
        case 'validatePlacement'
            varargout{1} = validateShipPlacement(varargin{:});
        otherwise
            error('Ugyldig kommando: %s', command);
    end
end

function placeShip(src, ~)
    % Komplet skibsplaceringsfunktion
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Debug info
    disp('Klik registreret på brættet');
    disp(['GameState: ' gameData.gameState]);
    
    % Tjek om vi er i placeringsfasen
    if ~strcmp(gameData.gameState, 'placing')
        disp('Fejl: Spillet er ikke i placeringsfasen');
        return;
    end
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    disp(['Klik koordinater: (' num2str(row) ',' num2str(col) ')']);
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        disp('Ugyldigt klik: Uden for brættet');
        return;
    end
    
    % Hent orientering og skibslængde
    orientation = get(handles.orientationSelector, 'Value');
    currentShip = gameData.currentShip;
    shipLength = gameData.ships(currentShip).length;
    
    % Tjek om placeringen er gyldig
    valid = validateShipPlacement(gameData.playerGrid, row, col, orientation, shipLength);
    
    if valid
        disp('Gyldig placering: Placerer skib');
        % Placer skibet
        if orientation == 1  % Vandret
            for i = 0:(shipLength-1)
                gameData.playerGrid(row, col+i) = currentShip;
            end
        else  % Lodret
            for i = 0:(shipLength-1)
                gameData.playerGrid(row+i, col) = currentShip;
            end
        end
        
        % Marker skibet som placeret og opdater visning
        gameData.ships(currentShip).placed = true;
        battleshipGrid('updateDisplay', handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Fortsæt til næste skib eller start spillet
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            shipName = gameData.ships(gameData.currentShip).name;
            shipLength = gameData.ships(gameData.currentShip).length;
            
            % Opdater instruktioner og titel
            set(handles.statusText, 'String', sprintf('Placer dit %s\n(%d felter)\nVælg orientering og \nklik på dit bræt.', ...
                                                   shipName, shipLength));
            title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', shipName, shipLength), ...
                'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
            
            disp(['Næste skib: ' shipName]);
        else
            disp('Alle skibe placeret. Starter spillet!');
            gameData.gameState = 'playing';
            
            % Opdater UI for spillefasen
            set(handles.statusText, 'String', 'Alle skibe placeret!\nKlik på modstanderens bræt for at skyde.');
            set(handles.gameStatusBar, 'String', 'DIN TUR: Klik på modstanderens bræt for at skyde');
            title(handles.playerBoard, 'Dit bræt', 'FontWeight', 'bold', 'FontSize', 12);
            
            % Aktiver fjendebræt til at modtage skud
            set(handles.enemyBoard, 'ButtonDownFcn', @(src,event) battleshipLogic('fireShot', src, event));
            set(handles.playerBoard, 'ButtonDownFcn', []);
        end
    else
        disp('Ugyldig placering');
    end
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function fireShot(src, ~)
    % Håndter klik på fjendens bræt for at skyde
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Tjek om spillet er i gang
    if ~strcmp(gameData.gameState, 'playing') || ~gameData.playerTurn
        return;
    end
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        return;
    end
    
    % Tjek om feltet allerede er beskudt
    if gameData.playerShots(row, col) > 0
        set(handles.statusText, 'String', 'Du har allerede skudt her!\nVælg et andet felt.');
        
        % Vis advarsel
        warningPanel = uipanel('Parent', fig, 'Position', [0.65, 0.45, 0.3, 0.1], ...
                              'BackgroundColor', [1 0.9 0.9], ...
                              'HighlightColor', [0.8 0 0], 'BorderWidth', 2);
        
        uicontrol('Parent', warningPanel, 'Style', 'text', ...
                 'Position', [10, 35, 280, 25], 'String', 'Du har allerede skudt her!', ...
                 'FontSize', 12, 'FontWeight', 'bold', 'ForegroundColor', [0.8 0 0], ...
                 'BackgroundColor', [1 0.9 0.9]);
        
        % Fjern advarsel efter 1.5 sekunder
        t = timer('ExecutionMode', 'singleShot', 'StartDelay', 1.5, ...
                 'TimerFcn', @(~,~) delete(warningPanel));
        start(t);
        return;
    end
    
    % Vis koordinater
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', sprintf('Du skyder på %s', coordStr));
    
    % Registrer spillerens skud med visuel feedback
    if gameData.computerGrid(row, col) > 0
        % Hit
        shipType = gameData.computerGrid(row, col);
        gameData.playerShots(row, col) = 2; % Mark as hit
        
        % Opdater status
        set(handles.statusText, 'String', sprintf('TRÆFFER!\nDu ramte et %s på %s!', gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.computerHits(shipType) = gameData.computerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.computerHits(shipType) == gameData.ships(shipType).length
            % Vis besked om sænket skib
            sunkPanel = uipanel('Parent', fig, 'Position', [0.65, 0.5, 0.3, 0.15], ...
                               'BackgroundColor', [0.9 0.95 1], ...
                               'HighlightColor', [0 0.5 0.8], 'BorderWidth', 2);
            
            uicontrol('Parent', sunkPanel, 'Style', 'text', ...
                     'Position', [10, 40, 280, 40], 'String', sprintf('Du sænkede modstanderens %s!', gameData.ships(shipType).name), ...
                     'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', [0 0.5 0.8], ...
                     'BackgroundColor', [0.9 0.95 1]);
            
            % Fjern besked efter 2 sekunder
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                     'TimerFcn', @(~,~) delete(sunkPanel));
            start(t);
            
            set(handles.statusText, 'String', sprintf('SKIBET SÆNKET!\nDu sænkede modstanderens %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.playerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('FORBI!\nDit skud på %s ramte ingenting.', coordStr));
    end
    
    % Opdater visning med animation
    hitEffect = [];
    if gameData.playerShots(row, col) == 2
        % Effekt ved træffer
        axes(handles.enemyBoard);
        hitEffect = rectangle('Position', [col-1, row-1, 1, 1], 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'red', 'LineWidth', 2);
    else
        % Effekt ved forbi
        axes(handles.enemyBoard);
        hitEffect = plot(col-0.5, row-0.5, 'ko', 'MarkerSize', 25, 'LineWidth', 2, 'MarkerFaceColor', [0.8 0.8 0.8]);
    end
    
    % Opdater brætvisning efter kort forsinkelse
    pause(0.3);
    if ~isempty(hitEffect) && isvalid(hitEffect)
        delete(hitEffect);
    end
    battleshipGrid('updateDisplay', handles.enemyBoard, zeros(10,10), gameData.playerShots, false);
    
    % Check for win
    if sum(gameData.computerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'SEJR! Du sænkede alle modstanderens skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        set(handles.gameStatusBar, 'String', 'SPILLET ER SLUT: Du har vundet!', 'ForegroundColor', [0 0.6 0]);
        setappdata(fig, 'gameData', gameData);
        
        % Vis sejrbesked
        battleshipUI('showGameResult', fig, true);
        return;
    end
    
    % Skift tur
    gameData.playerTurn = false;
    setappdata(fig, 'gameData', gameData);
    
    % Opdater UI før computerens tur
    set(handles.gameStatusBar, 'String', 'MODSTANDERENS TUR: Computeren skyder...', 'ForegroundColor', [0.8 0 0]);
    
    % Computerens tur - med lille forsinkelse så spilleren kan se hvad der sker
    pause(0.8);
    computerTurn(fig);
end

function computerTurn(fig)
    % Håndter computerens tur
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Check if game is still active
    if ~strcmp(gameData.gameState, 'playing')
        return;
    end
    
    % Get computer shot based on difficulty
    [row, col] = battleshipAI('getComputerShot', gameData.computerShots, gameData.playerGrid, gameData.difficulty);
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Update status to show computer's move
    set(handles.statusText, 'String', sprintf('Computeren skyder på %s', coordStr));
    set(handles.gameStatusBar, 'String', sprintf('Computeren skyder på %s', coordStr));
    
    % Vis indikator for computerens skud
    axes(handles.playerBoard);
    targetMarker = plot(col-0.5, row-0.5, 'ro', 'MarkerSize', 15, 'LineWidth', 2);
    pause(0.5);
    delete(targetMarker);
    
    % Process shot
    if gameData.playerGrid(row, col) > 0
        % Hit
        shipType = gameData.playerGrid(row, col);
        gameData.computerShots(row, col) = 2; % Mark as hit
        
        % Visuelt fremhæv ramt felt
        axes(handles.playerBoard);
        hitEffect = rectangle('Position', [col-1, row-1, 1, 1], 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'red', 'LineWidth', 2);
        pause(0.3);
        delete(hitEffect);
        
        set(handles.statusText, 'String', sprintf('RAMT! Computeren ramte dit %s på %s!', ...
                                                gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.playerHits(shipType) = gameData.playerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.playerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('SKIBET SÆNKET! Computeren sænkede dit %s!', gameData.ships(shipType).name));
            
            % Vis besked om sænket skib
            sunkPanel = uipanel('Parent', fig, 'Position', [0.25, 0.5, 0.3, 0.15], ...
                              'BackgroundColor', [1 0.9 0.9], ...
                              'HighlightColor', [0.8 0 0], 'BorderWidth', 2);
            
            uicontrol('Parent', sunkPanel, 'Style', 'text', ...
                    'Position', [10, 40, 280, 40], 'String', sprintf('Computeren sænkede dit %s!', gameData.ships(shipType).name), ...
                    'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', [0.8 0 0], ...
                    'BackgroundColor', [1 0.9 0.9]);
            
            % Fjern besked efter 2 sekunder
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                    'TimerFcn', @(~,~) delete(sunkPanel));
            start(t);
        end
    else
        % Miss
        gameData.computerShots(row, col) = 1; % Mark as miss
        
        % Visuelt fremhæv forbiskud
        axes(handles.playerBoard);
        missEffect = plot(col-0.5, row-0.5, 'ko', 'MarkerSize', 20, 'LineWidth', 2);
        pause(0.3);
        delete(missEffect);
        
        set(handles.statusText, 'String', sprintf('FORBI! Computerens skud på %s ramte ingenting.', coordStr));
    end
    
    % Update display
    battleshipGrid('updateDisplay', handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
    
    % Check for loss
    if sum(gameData.playerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'NEDERLAG! Computeren sænkede alle dine skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        set(handles.gameStatusBar, 'String', 'SPILLET ER SLUT: Computeren har vundet', 'ForegroundColor', [0.8 0 0]);
        setappdata(fig, 'gameData', gameData);
        
        % Vis nederlagsbesked
        battleshipUI('showGameResult', fig, false);
        return;
    end
    
    % Switch turns back to player
    gameData.playerTurn = true;
    pause(0.5);
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', 'DIN TUR: Klik på modstanderens bræt for at skyde', 'ForegroundColor', [0 0 0]);
    
    % Prompt player for next move
    set(handles.statusText, 'String', sprintf('%s\nDin tur - klik på modstanderens bræt for at skyde.', ...
                                            get(handles.statusText, 'String')));
    
    setappdata(fig, 'gameData', gameData);
end

function valid = validateShipPlacement(grid, row, col, orientation, shipLength)
    % Valider om et skib kan placeres på det angivne sted
    
    % Tjek om skibet passer på brættet
    if orientation == 1 && col + shipLength - 1 > 10  % Vandret
        valid = false;
        return;
    elseif orientation == 2 && row + shipLength - 1 > 10  % Lodret
        valid = false;
        return;
    end
    
    % Tjek om felterne er ledige
    valid = true;
    if orientation == 1  % Vandret
        for i = 0:(shipLength-1)
            if grid(row, col+i) ~= 0
                valid = false;
                return;
            end
        end
    else  % Lodret
        for i = 0:(shipLength-1)
            if grid(row+i, col) ~= 0
                valid = false;
                return;
            end
        end
    end
end