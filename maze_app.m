function maze_app
% MAZE_APP Maze generator and solver app for a university course project.
% The app lets the user choose maze Length, Height, Difficulty, and a
% solving algorithm (DFS, A*, or BFS). Generate Maze creates a new maze,
% Solve animates exploration and the final path, and Clear restores the
% startup state. Usage: run maze_app, generate a maze, choose an
% algorithm, and click Solve.

MIN_MAZE_SIZE = 2;
MAX_MAZE_SIZE = 60;
DEFAULT_LENGTH = 20;
DEFAULT_HEIGHT = 20;
DEFAULT_DIFFICULTY = 1;
DEFAULT_ALGORITHM = 'DFS';
DEFAULT_STATUS = 'Ready. Configure the maze and click Generate Maze.';

app = struct();
app.currentMaze = [];
app.currentSolutionPath = [];
app.ui = struct();

app = createUI(app);
resetAppState();

    function app = createUI(app)
        % Build the main UI and store component handles in app.ui.
        app.ui.Figure = uifigure( ...
            'Name', 'Maze Generator and Solver', ...
            'Position', [100 100 980 620], ...
            'Color', [0.97 0.97 0.97]);

        app.ui.MainGrid = uigridlayout(app.ui.Figure, [1 2]);
        app.ui.MainGrid.ColumnWidth = {260, '1x'};
        app.ui.MainGrid.RowHeight = {'1x'};
        app.ui.MainGrid.Padding = [14 14 14 14];
        app.ui.MainGrid.ColumnSpacing = 14;

        app.ui.ControlPanel = uipanel(app.ui.MainGrid, 'Title', 'Controls');
        app.ui.ControlPanel.Layout.Row = 1;
        app.ui.ControlPanel.Layout.Column = 1;

        app.ui.ControlGrid = uigridlayout(app.ui.ControlPanel, [14 1]);
        app.ui.ControlGrid.RowHeight = { ...
            22, 36, ...
            22, 36, ...
            22, 36, ...
            22, 36, ...
            40, 40, ...
            60, ...
            40, ...
            '1x', ...
            8};
        app.ui.ControlGrid.ColumnWidth = {'1x'};
        app.ui.ControlGrid.Padding = [12 12 12 12];
        app.ui.ControlGrid.RowSpacing = 8;

        app.ui.LengthLabel = uilabel(app.ui.ControlGrid, ...
            'Text', sprintf('Length (%d-%d)', MIN_MAZE_SIZE, MAX_MAZE_SIZE));
        app.ui.LengthLabel.Layout.Row = 1;

        app.ui.LengthField = uieditfield(app.ui.ControlGrid, 'numeric');
        app.ui.LengthField.Layout.Row = 2;
        app.ui.LengthField.Value = DEFAULT_LENGTH;
        app.ui.LengthField.Limits = [MIN_MAZE_SIZE MAX_MAZE_SIZE];
        app.ui.LengthField.RoundFractionalValues = true;

        app.ui.HeightLabel = uilabel(app.ui.ControlGrid, ...
            'Text', sprintf('Height (%d-%d)', MIN_MAZE_SIZE, MAX_MAZE_SIZE));
        app.ui.HeightLabel.Layout.Row = 3;

        app.ui.HeightField = uieditfield(app.ui.ControlGrid, 'numeric');
        app.ui.HeightField.Layout.Row = 4;
        app.ui.HeightField.Value = DEFAULT_HEIGHT;
        app.ui.HeightField.Limits = [MIN_MAZE_SIZE MAX_MAZE_SIZE];
        app.ui.HeightField.RoundFractionalValues = true;

        app.ui.DifficultyLabel = uilabel(app.ui.ControlGrid, 'Text', 'Difficulty (1-10)');
        app.ui.DifficultyLabel.Layout.Row = 5;

        app.ui.DifficultyField = uislider(app.ui.ControlGrid);
        app.ui.DifficultyField.Layout.Row = 6;
        app.ui.DifficultyField.Limits = [1 10];
        app.ui.DifficultyField.MajorTicks = 1:10;
        app.ui.DifficultyField.MinorTicks = [];
        app.ui.DifficultyField.Value = DEFAULT_DIFFICULTY;

        app.ui.AlgorithmLabel = uilabel(app.ui.ControlGrid, 'Text', 'Algorithm');
        app.ui.AlgorithmLabel.Layout.Row = 7;

        app.ui.AlgorithmDropdown = uidropdown(app.ui.ControlGrid);
        app.ui.AlgorithmDropdown.Layout.Row = 8;
        app.ui.AlgorithmDropdown.Items = {'DFS', 'A*', 'BFS'};
        app.ui.AlgorithmDropdown.Value = DEFAULT_ALGORITHM;

        app.ui.GenerateButton = uibutton(app.ui.ControlGrid, 'push');
        app.ui.GenerateButton.Layout.Row = 9;
        app.ui.GenerateButton.Text = 'Generate Maze';
        app.ui.GenerateButton.ButtonPushedFcn = @generateMazeCallback;

        app.ui.SolveButton = uibutton(app.ui.ControlGrid, 'push');
        app.ui.SolveButton.Layout.Row = 10;
        app.ui.SolveButton.Text = 'Solve';
        app.ui.SolveButton.ButtonPushedFcn = @solveMazeCallback;

        app.ui.StatusLabel = uilabel(app.ui.ControlGrid);
        app.ui.StatusLabel.Layout.Row = 11;
        app.ui.StatusLabel.Text = '';
        app.ui.StatusLabel.WordWrap = 'on';
        app.ui.StatusLabel.VerticalAlignment = 'top';

        app.ui.ClearButton = uibutton(app.ui.ControlGrid, 'push');
        app.ui.ClearButton.Layout.Row = 12;
        app.ui.ClearButton.Text = 'Clear';
        app.ui.ClearButton.ButtonPushedFcn = @clearCallback;

        app.ui.MazePanel = uipanel(app.ui.MainGrid, 'Title', 'Maze Display');
        app.ui.MazePanel.Layout.Row = 1;
        app.ui.MazePanel.Layout.Column = 2;

        app.ui.MazeGrid = uigridlayout(app.ui.MazePanel, [1 1]);
        app.ui.MazeGrid.Padding = [10 10 10 10];

        app.ui.MazeAxes = uiaxes(app.ui.MazeGrid);
        app.ui.MazeAxes.Layout.Row = 1;
        app.ui.MazeAxes.Layout.Column = 1;
        app.ui.MazeAxes.Box = 'on';
        app.ui.MazeAxes.Toolbar.Visible = 'off';
        app.ui.MazeAxes.Interactions = [];
        app.ui.MazeAxes.XTick = [];
        app.ui.MazeAxes.YTick = [];
        app.ui.MazeAxes.XColor = [0.3 0.3 0.3];
        app.ui.MazeAxes.YColor = [0.3 0.3 0.3];
        app.ui.MazeAxes.DataAspectRatio = [1 1 1];
        app.ui.MazeAxes.PlotBoxAspectRatio = [1 1 1];
        title(app.ui.MazeAxes, 'Maze Preview');
    end

    function resetAppState()
        % Restore the app to its startup state.
        app.currentMaze = [];
        app.currentSolutionPath = [];
        app.ui.LengthField.Value = DEFAULT_LENGTH;
        app.ui.HeightField.Value = DEFAULT_HEIGHT;
        app.ui.DifficultyField.Value = DEFAULT_DIFFICULTY;
        app.ui.AlgorithmDropdown.Value = DEFAULT_ALGORITHM;
        drawMaze(app.ui.MazeAxes, []);
        app.ui.StatusLabel.Text = DEFAULT_STATUS;
    end

    function generateMazeCallback(~, ~)
        lengthValue = app.ui.LengthField.Value;
        heightValue = app.ui.HeightField.Value;
        difficultyValue = round(app.ui.DifficultyField.Value);
        app.ui.DifficultyField.Value = difficultyValue;

        [isValid, message] = validateInputs(lengthValue, heightValue, difficultyValue, MIN_MAZE_SIZE, MAX_MAZE_SIZE);
        if ~isValid
            app.ui.StatusLabel.Text = message;
            uialert(app.ui.Figure, message, 'Invalid Input');
            return;
        end

        app.currentMaze = generateMazeMatrix(lengthValue, heightValue, difficultyValue);
        app.currentSolutionPath = [];
        drawMaze(app.ui.MazeAxes, app.currentMaze);
        app.ui.StatusLabel.Text = sprintf( ...
            'Maze generated: %d x %d, difficulty %d.', ...
            lengthValue, heightValue, difficultyValue);
    end

    function solveMazeCallback(~, ~)
        % Solve the current maze and animate exploration + final path.
        if isempty(app.currentMaze)
            message = 'Generate a maze before solving.';
            app.ui.StatusLabel.Text = message;
            uialert(app.ui.Figure, message, 'No Maze');
            return;
        end

        algorithm = app.ui.AlgorithmDropdown.Value;
        startPos = [1, 2];
        goalPos = [size(app.currentMaze, 1), size(app.currentMaze, 2) - 1];

        [pathRowCol, exploredRowCol] = solveMazeByAlgorithm(app.currentMaze, algorithm, startPos, goalPos);
        drawMaze(app.ui.MazeAxes, app.currentMaze);

        if isempty(pathRowCol)
            app.currentSolutionPath = [];
            message = sprintf('%s could not find a path.', algorithm);
            app.ui.StatusLabel.Text = message;
            uialert(app.ui.Figure, message, 'No Path Found');
            return;
        end

        app.currentSolutionPath = pathRowCol;
        animateExploration(app.ui.MazeAxes, exploredRowCol);
        animateSolutionPath(app.ui.MazeAxes, pathRowCol);
        app.ui.StatusLabel.Text = sprintf( ...
            '%s solve complete. Path length: %d. Explored nodes: %d.', ...
            algorithm, size(pathRowCol, 1), size(exploredRowCol, 1));
    end

    function clearCallback(~, ~)
        resetAppState();
    end
end

function [isValid, message] = validateInputs(lengthValue, heightValue, difficultyValue, minMazeSize, maxMazeSize)
isValid = true;
message = '';

if ~isscalar(lengthValue) || ~isfinite(lengthValue) || ...
        lengthValue < minMazeSize || lengthValue > maxMazeSize || floor(lengthValue) ~= lengthValue
    isValid = false;
    message = sprintf('Length must be an integer between %d and %d.', minMazeSize, maxMazeSize);
    return;
end

if ~isscalar(heightValue) || ~isfinite(heightValue) || ...
        heightValue < minMazeSize || heightValue > maxMazeSize || floor(heightValue) ~= heightValue
    isValid = false;
    message = sprintf('Height must be an integer between %d and %d.', minMazeSize, maxMazeSize);
    return;
end

if ~isscalar(difficultyValue) || ~isfinite(difficultyValue) || difficultyValue < 1 || difficultyValue > 10
    isValid = false;
    message = 'Difficulty must be between 1 and 10.';
end
end

function maze = generateMazeMatrix(lengthValue, heightValue, difficultyValue)
% 1 = wall, 0 = open path.
maze = generateMazeDFS(lengthValue, heightValue);
maze = openExtraPassages(maze, lengthValue, heightValue, difficultyValue);

maze(1, 2) = 0;
maze(2, 2) = 0;
maze(end, end - 1) = 0;
maze(end - 1, end - 1) = 0;
end

function maze = generateMazeDFS(lengthValue, heightValue)
% Generate a perfect maze using iterative DFS backtracking.
rows = 2 * heightValue + 1;
cols = 2 * lengthValue + 1;

maze = ones(rows, cols);
visited = false(heightValue, lengthValue);

stack = [1, 1];
visited(1, 1) = true;
[startRow, startCol] = logicalCellToMatrix(1, 1);
maze(startRow, startCol) = 0;

while ~isempty(stack)
    currentCell = stack(end, :);
    neighbors = getUnvisitedNeighbors(currentCell(1), currentCell(2), visited);

    if isempty(neighbors)
        stack(end, :) = [];
        continue;
    end

    nextIndex = randi(size(neighbors, 1));
    nextCell = neighbors(nextIndex, :);

    [currentRow, currentCol] = logicalCellToMatrix(currentCell(1), currentCell(2));
    [nextRow, nextCol] = logicalCellToMatrix(nextCell(1), nextCell(2));

    wallRow = (currentRow + nextRow) / 2;
    wallCol = (currentCol + nextCol) / 2;

    maze(nextRow, nextCol) = 0;
    maze(wallRow, wallCol) = 0;

    visited(nextCell(1), nextCell(2)) = true;
    stack(end + 1, :) = nextCell; %#ok<AGROW>
end
end

function neighbors = getUnvisitedNeighbors(cellRow, cellCol, visited)
cellCountRows = size(visited, 1);
cellCountCols = size(visited, 2);

candidateOffsets = [-1 0; 1 0; 0 -1; 0 1];
neighbors = zeros(0, 2);

for idx = 1:size(candidateOffsets, 1)
    neighborRow = cellRow + candidateOffsets(idx, 1);
    neighborCol = cellCol + candidateOffsets(idx, 2);

    if neighborRow < 1 || neighborRow > cellCountRows || neighborCol < 1 || neighborCol > cellCountCols
        continue;
    end

    if ~visited(neighborRow, neighborCol)
        neighbors(end + 1, :) = [neighborRow, neighborCol]; %#ok<AGROW>
    end
end
end

function maze = openExtraPassages(maze, lengthValue, heightValue, difficultyValue)
% Lower difficulty opens more extra walls, creating an easier maze.
if lengthValue < 2 && heightValue < 2
    return;
end

maxExtraOpenings = floor((lengthValue * heightValue) / 3);
extraOpenings = round(((10 - difficultyValue) / 9) * maxExtraOpenings);

if extraOpenings <= 0
    return;
end

candidateWalls = zeros(0, 2);
for cellRow = 1:heightValue
    for cellCol = 1:lengthValue
        [matrixRow, matrixCol] = logicalCellToMatrix(cellRow, cellCol);

        if cellCol < lengthValue && maze(matrixRow, matrixCol + 1) == 1
            candidateWalls(end + 1, :) = [matrixRow, matrixCol + 1]; %#ok<AGROW>
        end

        if cellRow < heightValue && maze(matrixRow + 1, matrixCol) == 1
            candidateWalls(end + 1, :) = [matrixRow + 1, matrixCol]; %#ok<AGROW>
        end
    end
end

if isempty(candidateWalls)
    return;
end

randomOrder = randperm(size(candidateWalls, 1));
openCount = min(extraOpenings, numel(randomOrder));

for idx = 1:openCount
    wallPosition = candidateWalls(randomOrder(idx), :);
    maze(wallPosition(1), wallPosition(2)) = 0;
end
end

function [pathRowCol, exploredRowCol] = solveMazeByAlgorithm(maze, algorithm, startPos, goalPos)
switch algorithm
    case 'DFS'
        [pathRowCol, exploredRowCol] = solveMazeDFS(maze, startPos, goalPos);
    case 'BFS'
        [pathRowCol, exploredRowCol] = solveMazeBFS(maze, startPos, goalPos);
    case 'A*'
        [pathRowCol, exploredRowCol] = solveMazeAStar(maze, startPos, goalPos);
    otherwise
        error('Unsupported algorithm: %s', algorithm);
end
end

function [pathRowCol, exploredRowCol] = solveMazeDFS(maze, startPos, goalPos)
% DFS explores one branch deeply before backtracking.
[rows, cols] = size(maze);
startIdx = sub2ind([rows, cols], startPos(1), startPos(2));
goalIdx = sub2ind([rows, cols], goalPos(1), goalPos(2));

stack = startIdx;
visited = false(rows, cols);
visited(startIdx) = true;
parents = zeros(rows * cols, 1);
parents(startIdx) = startIdx;
exploredIdx = zeros(rows * cols, 1);
exploredCount = 0;

pathRowCol = zeros(0, 2);

while ~isempty(stack)
    currentIdx = stack(end);
    stack(end) = [];

    exploredCount = exploredCount + 1;
    exploredIdx(exploredCount) = currentIdx;

    if currentIdx == goalIdx
        pathRowCol = reconstructPath(parents, startIdx, goalIdx, [rows, cols]);
        exploredRowCol = indicesToRowCol(exploredIdx(1:exploredCount), [rows, cols]);
        return;
    end

    [currentRow, currentCol] = ind2sub([rows, cols], currentIdx);
    neighbors = getOpenNeighbors(maze, currentRow, currentCol);

    for idx = size(neighbors, 1):-1:1
        neighborRow = neighbors(idx, 1);
        neighborCol = neighbors(idx, 2);
        neighborIdx = sub2ind([rows, cols], neighborRow, neighborCol);

        if visited(neighborIdx)
            continue;
        end

        visited(neighborIdx) = true;
        parents(neighborIdx) = currentIdx;
        stack(end + 1) = neighborIdx; %#ok<AGROW>
    end
end

exploredRowCol = indicesToRowCol(exploredIdx(1:exploredCount), [rows, cols]);
end

function [pathRowCol, exploredRowCol] = solveMazeBFS(maze, startPos, goalPos)
% BFS guarantees the shortest path in this unweighted grid.
[rows, cols] = size(maze);
startIdx = sub2ind([rows, cols], startPos(1), startPos(2));
goalIdx = sub2ind([rows, cols], goalPos(1), goalPos(2));

queue = zeros(rows * cols, 1);
queueHead = 1;
queueTail = 1;
queue(queueTail) = startIdx;

visited = false(rows, cols);
visited(startIdx) = true;
parents = zeros(rows * cols, 1);
parents(startIdx) = startIdx;
exploredIdx = zeros(rows * cols, 1);
exploredCount = 0;

pathRowCol = zeros(0, 2);

while queueHead <= queueTail
    currentIdx = queue(queueHead);
    queueHead = queueHead + 1;

    exploredCount = exploredCount + 1;
    exploredIdx(exploredCount) = currentIdx;

    if currentIdx == goalIdx
        pathRowCol = reconstructPath(parents, startIdx, goalIdx, [rows, cols]);
        exploredRowCol = indicesToRowCol(exploredIdx(1:exploredCount), [rows, cols]);
        return;
    end

    [currentRow, currentCol] = ind2sub([rows, cols], currentIdx);
    neighbors = getOpenNeighbors(maze, currentRow, currentCol);

    for idx = 1:size(neighbors, 1)
        neighborRow = neighbors(idx, 1);
        neighborCol = neighbors(idx, 2);
        neighborIdx = sub2ind([rows, cols], neighborRow, neighborCol);

        if visited(neighborIdx)
            continue;
        end

        visited(neighborIdx) = true;
        parents(neighborIdx) = currentIdx;
        queueTail = queueTail + 1;
        queue(queueTail) = neighborIdx;
    end
end

exploredRowCol = indicesToRowCol(exploredIdx(1:exploredCount), [rows, cols]);
end

function [pathRowCol, exploredRowCol] = solveMazeAStar(maze, startPos, goalPos)
% A* uses Manhattan distance to guide the search toward the goal.
[rows, cols] = size(maze);
startIdx = sub2ind([rows, cols], startPos(1), startPos(2));
goalIdx = sub2ind([rows, cols], goalPos(1), goalPos(2));

gScore = inf(rows * cols, 1);
fScore = inf(rows * cols, 1);
parents = zeros(rows * cols, 1);
openSet = false(rows * cols, 1);
closedSet = false(rows * cols, 1);
exploredIdx = zeros(rows * cols, 1);
exploredCount = 0;

gScore(startIdx) = 0;
fScore(startIdx) = manhattanDistance(startPos, goalPos);
parents(startIdx) = startIdx;
openSet(startIdx) = true;

pathRowCol = zeros(0, 2);

while any(openSet)
    candidateScores = fScore;
    candidateScores(~openSet) = inf;
    [bestScore, currentIdx] = min(candidateScores);

    if isinf(bestScore)
        break;
    end

    openSet(currentIdx) = false;
    closedSet(currentIdx) = true;

    exploredCount = exploredCount + 1;
    exploredIdx(exploredCount) = currentIdx;

    if currentIdx == goalIdx
        pathRowCol = reconstructPath(parents, startIdx, goalIdx, [rows, cols]);
        exploredRowCol = indicesToRowCol(exploredIdx(1:exploredCount), [rows, cols]);
        return;
    end

    [currentRow, currentCol] = ind2sub([rows, cols], currentIdx);
    neighbors = getOpenNeighbors(maze, currentRow, currentCol);

    for idx = 1:size(neighbors, 1)
        neighborRow = neighbors(idx, 1);
        neighborCol = neighbors(idx, 2);
        neighborIdx = sub2ind([rows, cols], neighborRow, neighborCol);

        if closedSet(neighborIdx)
            continue;
        end

        tentativeG = gScore(currentIdx) + 1;
        if tentativeG >= gScore(neighborIdx)
            continue;
        end

        parents(neighborIdx) = currentIdx;
        gScore(neighborIdx) = tentativeG;
        fScore(neighborIdx) = tentativeG + manhattanDistance([neighborRow, neighborCol], goalPos);
        openSet(neighborIdx) = true;
    end
end

exploredRowCol = indicesToRowCol(exploredIdx(1:exploredCount), [rows, cols]);
end

function neighbors = getOpenNeighbors(maze, row, col)
[rows, cols] = size(maze);
candidateOffsets = [-1 0; 1 0; 0 -1; 0 1];
neighbors = zeros(0, 2);

for idx = 1:size(candidateOffsets, 1)
    nextRow = row + candidateOffsets(idx, 1);
    nextCol = col + candidateOffsets(idx, 2);

    if nextRow < 1 || nextRow > rows || nextCol < 1 || nextCol > cols
        continue;
    end

    if maze(nextRow, nextCol) == 0
        neighbors(end + 1, :) = [nextRow, nextCol]; %#ok<AGROW>
    end
end
end

function pathRowCol = reconstructPath(parents, startIdx, goalIdx, mazeSize)
% Rebuild the path by following parent pointers from goal back to start.
if parents(goalIdx) == 0
    pathRowCol = zeros(0, 2);
    return;
end

currentIdx = goalIdx;
pathIndices = currentIdx;

while currentIdx ~= startIdx
    currentIdx = parents(currentIdx);
    if currentIdx == 0
        pathRowCol = zeros(0, 2);
        return;
    end
    pathIndices(end + 1) = currentIdx; %#ok<AGROW>
end

pathIndices = fliplr(pathIndices);
[rowValues, colValues] = ind2sub(mazeSize, pathIndices);
pathRowCol = [rowValues(:), colValues(:)];
end

function rowCol = indicesToRowCol(indices, mazeSize)
if isempty(indices)
    rowCol = zeros(0, 2);
    return;
end

[rowValues, colValues] = ind2sub(mazeSize, indices(:));
rowCol = [rowValues, colValues];
end

function [xValues, yValues] = pathRowColToXY(pathRowCol)
% Convert matrix coordinates [row, col] to plotting coordinates [x, y].
xValues = pathRowCol(:, 2);
yValues = pathRowCol(:, 1);
end

function drawMaze(ax, maze)
% Draw the maze with white paths and black walls.
cla(ax);

if isempty(maze)
    placeholder = 0.94 * ones(21, 21);
    imagesc(ax, placeholder);
    colormap(ax, gray(256));
    caxis(ax, [0 1]);
    axis(ax, 'image');
    ax.XTick = [];
    ax.YTick = [];
    ax.YDir = 'normal';
    title(ax, 'Maze Preview');
    text(ax, 11, 11, 'No maze generated', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Color', [0.25 0.25 0.25], ...
        'FontSize', 14, ...
        'FontWeight', 'bold');
    return;
end

mazeDisplay = 1 - maze;
imagesc(ax, mazeDisplay);
colormap(ax, gray(256));
caxis(ax, [0 1]);
axis(ax, 'image');
ax.XTick = [];
ax.YTick = [];
ax.YDir = 'normal';
title(ax, 'Maze Preview');

drawStartGoalMarkers(ax, size(maze, 1), size(maze, 2));
end

function drawStartGoalMarkers(ax, mazeRows, mazeCols)
delete(findall(ax, 'Tag', 'StartGoalMarker'));
delete(findall(ax, 'Tag', 'StartGoalLabel'));

startCol = 2;
startRow = 1;
goalCol = mazeCols - 1;
goalRow = mazeRows;

hold(ax, 'on');

startMarker = plot(ax, startCol, startRow, 'o', ...
    'MarkerSize', 11, ...
    'MarkerFaceColor', [0.05 0.75 0.2], ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 1.2);
startMarker.Tag = 'StartGoalMarker';

goalMarker = plot(ax, goalCol, goalRow, 'o', ...
    'MarkerSize', 11, ...
    'MarkerFaceColor', [0.98 0.82 0.1], ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 1.2);
goalMarker.Tag = 'StartGoalMarker';

startLabel = text(ax, startCol + 1.2, startRow + 0.2, 'Start', ...
    'Color', 'k', ...
    'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'middle', ...
    'BackgroundColor', [1 1 1], ...
    'Margin', 1);
startLabel.Tag = 'StartGoalLabel';

goalLabel = text(ax, goalCol - 1.2, goalRow - 0.2, 'Goal', ...
    'Color', 'k', ...
    'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'BackgroundColor', [1 1 1], ...
    'Margin', 1);
goalLabel.Tag = 'StartGoalLabel';

hold(ax, 'off');
end

function exploredHandle = drawExploredNodes(ax, exploredRowCol)
if isempty(exploredRowCol)
    exploredHandle = gobjects(1);
    return;
end

[xValues, yValues] = pathRowColToXY(exploredRowCol);

hold(ax, 'on');
exploredHandle = plot(ax, xValues, yValues, 's', ...
    'LineStyle', 'none', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0.1 0.75 0.85], ...
    'MarkerEdgeColor', 'none');
hold(ax, 'off');

xlim(ax, [0.5, max(xValues) + 0.5]);
ylim(ax, [0.5, max(yValues) + 0.5]);
drawStartGoalMarkers(ax, max(yValues), max(xValues));
end

function pathHandle = drawSolutionPath(ax, pathRowCol)
if isempty(pathRowCol)
    pathHandle = gobjects(1);
    return;
end

[xValues, yValues] = pathRowColToXY(pathRowCol);

hold(ax, 'on');
pathHandle = plot(ax, xValues, yValues, '-', ...
    'Color', [0.9 0.15 0.1], ...
    'LineWidth', 2.5);
hold(ax, 'off');

xlim(ax, [0.5, max(xValues) + 0.5]);
ylim(ax, [0.5, max(yValues) + 0.5]);
drawStartGoalMarkers(ax, max(yValues), max(xValues));
end

function animateExploration(ax, exploredRowCol)
% Animate explored nodes in batches to keep larger mazes responsive.
if isempty(exploredRowCol)
    return;
end

[xValues, yValues] = pathRowColToXY(exploredRowCol);

hold(ax, 'on');
exploredHandle = plot(ax, nan, nan, 's', ...
    'LineStyle', 'none', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0.1 0.75 0.85], ...
    'MarkerEdgeColor', 'none');
hold(ax, 'off');

pointCount = numel(xValues);
batchSize = max(1, ceil(pointCount / 120));
pausePerFrame = 0.008;

for idx = 1:batchSize:pointCount
    lastIdx = min(pointCount, idx + batchSize - 1);
    exploredHandle.XData = xValues(1:lastIdx);
    exploredHandle.YData = yValues(1:lastIdx);
    drawStartGoalMarkers(ax, max(yValues), max(xValues));
    drawnow limitrate;
    pause(pausePerFrame);
end
end

function animateSolutionPath(ax, pathRowCol)
if isempty(pathRowCol)
    return;
end

[xValues, yValues] = pathRowColToXY(pathRowCol);

hold(ax, 'on');
pathHandle = plot(ax, xValues(1), yValues(1), '-', ...
    'Color', [0.9 0.15 0.1], ...
    'LineWidth', 2.5);
hold(ax, 'off');

stepPause = max(0.003, min(0.02, 0.25 / max(1, size(pathRowCol, 1))));
for idx = 2:numel(xValues)
    pathHandle.XData = xValues(1:idx);
    pathHandle.YData = yValues(1:idx);
    drawStartGoalMarkers(ax, max(yValues), max(xValues));
    drawnow limitrate;
    pause(stepPause);
end

drawStartGoalMarkers(ax, max(yValues), max(xValues));
end

function [matrixRow, matrixCol] = logicalCellToMatrix(cellRow, cellCol)
% Map logical maze cells onto their matrix positions.
matrixRow = 2 * cellRow;
matrixCol = 2 * cellCol;
end

function distance = manhattanDistance(position, goalPosition)
distance = abs(position(1) - goalPosition(1)) + abs(position(2) - goalPosition(2));
end