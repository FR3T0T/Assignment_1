function displayInstructions()
    % DISPLAYINSTRUCTIONS - Display game instructions
    
    fprintf('\n==== HOW TO PLAY BATTLESHIP ====\n\n');
    
    fprintf('OBJECTIVE:\n');
    fprintf('  Sink all of the computer''s ships before it sinks yours!\n\n');
    
    fprintf('GRID COORDINATES:\n');
    fprintf('  - Rows are labeled with letters (A, B, C, ...)\n');
    fprintf('  - Columns are labeled with numbers (1, 2, 3, ...)\n');
    fprintf('  - Enter coordinates as letter+number (e.g., A1, B5, C10)\n\n');
    
    fprintf('GAME SYMBOLS:\n');
    fprintf('  - "~" - Water (unknown or empty)\n');
    fprintf('  - "S" - Your ship\n');
    fprintf('  - "O" - Miss (you fired here and hit nothing)\n');
    fprintf('  - "X" - Hit (you hit an enemy ship here)\n\n');
    
    fprintf('GAMEPLAY:\n');
    fprintf('  1. Place your ships on your grid\n');
    fprintf('  2. Take turns with the computer firing shots\n');
    fprintf('  3. First to sink all enemy ships wins!\n\n');
    
    fprintf('Press any key to continue...\n');
    pause;
end