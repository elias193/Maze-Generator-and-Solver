# MATLAB Maze Generator and Solver

## What does this project do?

This project generates and solves a maze in MATLAB through a graphical user interface. The user can choose the maze length, height, difficulty, and the algorithm used to solve the maze.

To generate the maze, the program follows these steps:

1. Generate a maze matrix where walls and paths are represented in a grid-based structure.
2. Treat the logical maze cells as nodes connected by possible paths.
3. Use a Depth-First Search (DFS) backtracking approach to carve passages between cells and create a valid maze.
4. Add entry and exit points so the maze can always be solved.
5. Adjust the maze difficulty by opening extra walls:
   - lower difficulty creates a more open maze with more possible routes
   - higher difficulty keeps the maze closer to a stricter maze structure with more dead ends

The program then allows the maze to be solved and visualised using different pathfinding algorithms.

## Features

- MATLAB graphical user interface
- User-defined maze length and height
- Adjustable difficulty setting
- Maze generation and visualisation
- Animated maze solving
- Exploration visualisation for each algorithm
- Clear/reset button to restore the startup state

## Algorithms used

### DFS and BFS

**DFS (Depth-First Search)** is used in two ways in this project.

First, it is used to generate the maze by carving paths between cells using a backtracking process.

Second, it can also be used as a solving algorithm. DFS explores one branch as far as possible before backtracking and continuing through other branches. It is effective for finding a path, but it does not always give the shortest path.

**BFS (Breadth-First Search)** explores the maze level by level. It uses a queue-based approach and checks neighbouring cells in layers moving outward from the start. In an unweighted maze like this one, BFS guarantees the shortest path.

### A* Star

**A\*** is a more informed pathfinding algorithm. It combines the distance already travelled with a heuristic estimate of the remaining distance to the goal. In this project, the heuristic helps guide the search toward the exit more efficiently than uninformed search methods in many cases.

A\* is widely used in pathfinding problems because it balances correctness and efficiency.

## How the maze is represented

The maze is stored as a matrix:

- `1` represents a wall
- `0` represents an open path

For display, the maze is shown with:

- black tiles for walls
- white tiles for traversable paths

The start and goal positions are marked clearly on the interface, and the selected solving algorithm animates both the explored area and the final path.

## How to run the project

1. Open MATLAB
2. Run `maze_app`
3. Enter the maze length, height, and difficulty
4. Select a solving algorithm
5. Click **Generate Maze**
6. Click **Solve**

## Notes

This project was originally completed in 2023 as a course project and has been uploaded here as part of my portfolio.

Future improvements could include adding other pathfinding algorithms such as Dijkstra’s algorithm.
