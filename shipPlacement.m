function placeShipsInteractive(fig)
% PLACESHIPS - Interaktiv funktion til placering af skibe ved hjælp af plot
%
% Denne funktion åbner et nyt vindue, hvor brugeren kan placere skibe
% ved hjælp af MATLAB's plot-funktioner og museklik.

    % Hent spilledata
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Opret et nyt figure-vindue til skibsplacering
    placeFig = figure('Name', 'Placer dine skibe', 'Position', [300, 200, 500, 600], ...
                     'MenuBar', 'none', 'NumberTitle', 'off');
    
    % Opret axes til brættet
    ax = axes('Position', [0.1, 0.2, 0.8, 0.7]);
    hold(ax, 'on');
    
    % Tegn grid
    for i = 0:10
        line([i i], [0 10], 'Color', [0.7 0.7 0.8]);
        line([0 10], [i i], 'Color', [0.7 0.7 0.8]);
    end
    
    % Baggrundsfarve
    fill([0 10 10 0], [0 0 10 10], [0.96 0.98 1], 'EdgeColor', 'none');
    
    % Tilføj koordinatlabels
    for i = 1:10
        text(i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        text(-0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Indstil akser
    axis([0 10 0 10]);
    axis square;
    set(ax, 'XTick', [], 'YTick', []);
    
    % Opret skibsplacerings-panel
    uipanel('Position', [0.1, 0.05, 0.8, 0.1], 'Title', 'Orientering');
    
    % Opret orienteringsknapper
    orientationGrp = uibuttongroup('Position', [0.3, 0.06, 0.4, 0.08]);
    uicontrol('Parent', orientationGrp, 'Style', 'radiobutton', 'String', 'Vandret →', ...
             'Position', [10, 25, 80, 20], 'Tag', 'horiz');
    uicontrol('Parent', orientationGrp, 'Style', 'radiobutton', 'String', 'Lodret ↓', ...
             'Position', [100, 25, 80, 20], 'Tag', 'vert');
    
    % Farver til forskellige skibe
    shipColors = {[0.2 0.4 0.8], [0.3 0.5 0.8], [0.4 0.6 0.9]};
    
    % Nulstil spillerens bræt
    gameData.playerGrid = zeros(10, 10);
    for i = 1:length(gameData.ships)
        gameData.ships(i).placed = false;
    end
    
    % Placer skibe et efter et
    for shipIndex = 1:length(gameData.ships)
        currentShip = gameData.ships(shipIndex);
        title(ax, sprintf('Placer dit %s (%d felter)', currentShip.name, currentShip.length), ...
             'FontWeight', 'bold', 'FontSize', 12);
        
        % Vent på gyldig placering
        validPlacement = false;
        while ~validPlacement
            % Få et klik fra brugeren
            title(ax, sprintf('Klik for at placere %s (%d felter)', currentShip.name, currentShip.length), ...
                 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
            [x, y] = ginput(1);
            
            % Konverter til grid-koordinater
            col = floor(x) + 1;
            row = floor(y) + 1;
            
            % Tjek om koordinater er inden for brættet
            if col < 1 || col > 10 || row < 1 || row > 10
                title(ax, 'Ugyldigt klik - uden for brættet. Prøv igen.', ...
                     'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
                continue;
            end
            
            % Få orientering
            horizBtn = findobj(orientationGrp, 'Tag', 'horiz');
            isHorizontal = get(horizBtn, 'Value') == 1;
            
            % Tjek om skibet passer på brættet
            if isHorizontal && col + currentShip.length - 1 > 10
                title(ax, 'Skibet går ud over brættet. Prøv igen.', ...
                     'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
                continue;
            elseif ~isHorizontal && row + currentShip.length - 1 > 10
                title(ax, 'Skibet går ud over brættet. Prøv igen.', ...
                     'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
                continue;
            end
            
            % Tjek om pladsen er ledig
            occupied = false;
            if isHorizontal
                for j = 0:currentShip.length-1
                    if gameData.playerGrid(row, col+j) ~= 0
                        occupied = true;
                        break;
                    end
                end
            else
                for j = 0:currentShip.length-1
                    if gameData.playerGrid(row+j, col) ~= 0
                        occupied = true;
                        break;
                    end
                end
            end
            
            if occupied
                title(ax, 'Feltet er allerede optaget. Prøv igen.', ...
                     'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
                continue;
            end
            
            % Placer skibet på grid og vis det grafisk
            if isHorizontal
                for j = 0:currentShip.length-1
                    gameData.playerGrid(row, col+j) = shipIndex;
                    rectangle('Position', [col+j-1, row-1, 1, 1], 'FaceColor', shipColors{shipIndex}, ...
                             'EdgeColor', [0.1 0.2 0.5]);
                end
            else
                for j = 0:currentShip.length-1
                    gameData.playerGrid(row+j, col) = shipIndex;
                    rectangle('Position', [col-1, row+j-1, 1, 1], 'FaceColor', shipColors{shipIndex}, ...
                             'EdgeColor', [0.1 0.2 0.5]);
                end
            end
            
            validPlacement = true;
        end
        
        % Marker skibet som placeret
        gameData.ships(shipIndex).placed = true;
    end
    
    % Alle skibe er placeret
    title(ax, 'Alle skibe placeret! Klik på "Start Spil" for at begynde.', ...
         'FontWeight', 'bold', 'FontSize', 12, 'Color', 'green');
    
    % Tilføj knap til at starte spillet
    uicontrol('Style', 'pushbutton', 'String', 'Start Spil', ...
             'Position', [200, 10, 100, 30], 'FontWeight', 'bold', ...
             'BackgroundColor', [0.3 0.6 0.3], 'ForegroundColor', 'white', ...
             'Callback', @(~,~) startGameCallback(fig, gameData, placeFig));
end

function startGameCallback(gameFig, gameData, placeFig)
    % Opdater gameData i hovedfiguren
    handles = getappdata(gameFig, 'handles');
    
    % Skift spiltilstand til 'playing'
    gameData.gameState = 'playing';
    gameData.currentShip = 1;
    gameData.playerTurn = true;
    
    % Opdater UI for spillefasen
    set(handles.statusText, 'String', 'Alle skibe placeret!\nKlik på modstanderens bræt for at skyde.');
    set(handles.gameStatusBar, 'String', 'DIN TUR: Klik på modstanderens bræt for at skyde');
    title(handles.playerBoard, 'Dit bræt', 'FontWeight', 'bold', 'FontSize', 12);
    
    % Opdater brætvisning
    battleshipGrid('updateDisplay', handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
    
    % Lav en korrekt callback til fjende-brættet
    set(handles.enemyBoard, 'ButtonDownFcn', @(src,event) battleshipLogic('fireShot', src, event));
    set(handles.playerBoard, 'ButtonDownFcn', []);
    
    % Gem opdateret spilledata
    setappdata(gameFig, 'gameData', gameData);
    
    % Luk placeringsfiguren
    close(placeFig);
end

% Modificer startGame funktionen til at bruge den interaktive placering
function fixedStartGame(src, ~)
    disp('startGame aktiveret');
    
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
    
    % Opdater brætterne
    battleshipGrid('drawGrid', handles.playerBoard);
    battleshipGrid('drawGrid', handles.enemyBoard);
    
    % Placer computerens skibe
    gameData.computerGrid = battleshipAI('placeComputerShips', gameData.computerGrid, gameData.ships);
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
    
    % Start den interaktive placering
    placeShipsInteractive(fig);
end