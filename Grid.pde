class Grid {
  //top left corner of the grid
  PVector displayPos;
  //how many columns there are in the grid
  int w;
  //how many rows there are in the grid
  int h;
  //width of the blocks (they are squares)
  float blockSize;
  //2D array for the blocks
  Block[][] blocks;
  //array of positions of blocks in the path
  PVector[] path;
  //whether the path has been found
  boolean pathFound;
  //how many objectives have been reached
  int nextObjective;
  //the objectives
  PVector[] objectives;

  //w is how many columns of blocks there are
  //h is how many rows of blocks there are

  Grid(int w, int h, float blockSize, PVector[] objectives, PVector displayPos) {
    this.displayPos = displayPos;
    this.w = w;
    this.h = h;
    this.blockSize = blockSize;
    this.objectives = objectives;
    //the path is always not found at the start
    this.pathFound = false;
    //no objectives have been reached at the start
    this.nextObjective = 1;

    blocks = new Block[w][h];
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {

        //find the position of this block
        PVector currentPos = new PVector(x, y);

        //set this block as a normal block
        blocks[x][y] = new Block(currentPos, blockSize, false, false, false, displayPos);
      }
    }

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {

        //find the position of this block
        PVector currentPos = new PVector(x, y);

        //if this block is in the objectives list
        for (int i = 0; i < objectives.length; i++) {
          if (objectives[i].x == x && objectives[i].y == y) {
            //set this block as an objective block
            blocks[x][y] = new Block(currentPos, blockSize, false, false, true, displayPos);
          }
        }
      }
    }

    blocks[int(objectives[0].x)][int(objectives[0].y)] = new Block(objectives[0], blockSize, false, true, false, displayPos);

    //calc the hcost for the starting block
    blocks[int(objectives[0].x)][int(objectives[0].y)].calc_hcost(objectives[nextObjective]);
    //"dist" of starting block to the starting block will always be 0
    blocks[int(objectives[0].x)][int(objectives[0].y)].g = 0;
    //starting block points to itself
    //this is what will identify it as the starting block when mapping out the final path
    blocks[int(objectives[0].x)][int(objectives[0].y)].pointer = objectives[0];
    //make the starting block seen
    blocks[int(objectives[0].x)][int(objectives[0].y)].seen = true;
    //update the fcost of the starting block
    blocks[int(objectives[0].x)][int(objectives[0].y)].update_fcost();
  }

  void step() {
    //find the block with the lowest fcost that is availabe (seen but not closed)
    //current lowest f cost
    //this is the position of the block with the lowest fcost that is seen and not closed (green)
    //if it is null, a green block has not been found
    PVector currentLowestF = null;
    //go through all the blocks
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        //if the block is seen but not closed (it's green) and isn't a wall
        if (blocks[x][y].seen && !blocks[x][y].closed && !blocks[x][y].wall) {
          //if a green block hasn't been found before
          if (currentLowestF == null) {
            currentLowestF = blocks[x][y].pos;
            //if a green block has been found already
          } else {
            //if its fcost is lower than the current lowest fcost, change the current lowest fcost
            if (blocks[x][y].f < blocks[int(currentLowestF.x)][int(currentLowestF.y)].f) {
              //update the block with the lowest fcost
              currentLowestF = blocks[x][y].pos;
            }
          }
        }
      }
    }
    //if a green block has been found
    if (currentLowestF != null) {

      //make the block closed
      blocks[int(currentLowestF.x)][int(currentLowestF.y)].closed = true;

      //go through all adjecent blocks
      for (int y = int(currentLowestF.y) - 1; y < currentLowestF.y + 2; y++) {
        for (int x = int(currentLowestF.x) - 1; x < currentLowestF.x + 2; x++) {

          //if the ajdecent block is in the grid
          if (y < h && x < w && y >= 0 && x >= 0) {

            //if its not the centre block
            if (x != currentLowestF.x || y != currentLowestF.y) {

              //if it isn't through the wall by being in the corner
              if (!blocks[int(currentLowestF.x)][y].wall || !blocks[x][int(currentLowestF.y)].wall) {

                //calculate the hcost of the block
                blocks[x][y].calc_hcost(objectives[nextObjective]);
                //store the gcost of the block to check gcost is actually being reduced
                int prevG = blocks[x][y].g;
                //calculate the gcost based on the gcost of the block
                //depending on the gcost of the block it was seen from
                //and whether it was on a diagonal from that block or directly adjacent
                if (abs(currentLowestF.x - x) + abs(currentLowestF.y - y) == 2) {
                  blocks[x][y].g = blocks[int(currentLowestF.x)][int(currentLowestF.y)].g + 14;
                  //it also has to have already been seen or it will always pick the default 0 option which is what all the blocks start as
                  if (prevG < blocks[x][y].g && blocks[x][y].seen) {
                    blocks[x][y].g = prevG;
                  }
                } else {
                  blocks[x][y].g = blocks[int(currentLowestF.x)][int(currentLowestF.y)].g + 10;
                  //it also has to have already been seen or it will always pick the default 0 option which is what all the blocks start as
                  if (prevG < blocks[x][y].g && blocks[x][y].seen) {
                    blocks[x][y].g = prevG;
                  }
                }
                //store the previous fcost
                int prevF = blocks[x][y].f;
                //store the previous pointer;
                PVector prevPointer = blocks[x][y].pointer;
                //update the fcost (gcost + hcost)
                blocks[x][y].update_fcost();
                //set the block's pointer (the block it was seen from)
                blocks[x][y].pointer = currentLowestF;
                //if the previous fcost is smaller than the new fcost and its been seen
                if (prevF <= blocks[x][y].f && blocks[x][y].seen) {
                  //roll back the block's fcost
                  blocks[x][y].f = prevF;
                  //roll back the block's pointer
                  blocks[x][y].pointer = prevPointer;
                }
                //make the block seen
                //has to be done at the end because it checks if the block has been seen before
                blocks[x][y].seen = true;
              }
            }
          }
        }
      }

      //if its got to the next objective
      if (currentLowestF.x == objectives[nextObjective].x && currentLowestF.y == objectives[nextObjective].y) {
        //store the length of the path
        int pathLength = 1;
        //store the current path block
        PVector currentPathBlock = objectives[nextObjective];
        //while the current path block is not the pevious objective
        //cannot check if they are equal with (currentPathBlock == objectives[nextObjective - 1]) because they are not refering to the same object
        while (currentPathBlock.x != objectives[nextObjective - 1].x || currentPathBlock.y != objectives[nextObjective - 1].y) {
          //make the current path block a path block
          blocks[int(currentPathBlock.x)][int(currentPathBlock.y)].path = true;
          //set the current path block to where the current path block is pointing to
          currentPathBlock = blocks[int(currentPathBlock.x)][int(currentPathBlock.y)].pointer;
          //increment the path length
          pathLength++;
        }

        //intitialise the array storing the positions of all the blocks in the path with the newly found length of the path
        path = new PVector[pathLength];
        //store the current path block
        currentPathBlock = objectives[nextObjective];
        //this for loop goes backwards because the pointers go from the end to the begining
        for (int i = path.length - 1; i >= 0; i--) {
          //set appropriate element of the path array to the current path block
          path[i] = currentPathBlock;
          //set the current path block to where the current path block is pointing to
          currentPathBlock = blocks[int(currentPathBlock.x)][int(currentPathBlock.y)].pointer;
        }
        printArray(path);

        for (int y = 0; y < h; y++) {
          for (int x = 0; x < w; x++) {
            blocks[x][y].seen = false;
          }
        }

        //update what the next objective is
        nextObjective++;

        //if the path has been completed to the last objective
        if (nextObjective == objectives.length) {
          //set the variable to say that the path has been found
          pathFound = true;
        } else {
          //calc the hcost for the starting block
          blocks[int(objectives[nextObjective - 1].x)][int(objectives[nextObjective - 1].y)].calc_hcost(objectives[nextObjective]);
          //"dist" of starting block to the starting block will always be 0
          blocks[int(objectives[nextObjective - 1].x)][int(objectives[nextObjective - 1].y)].g = 0;
          //starting block points to itself
          blocks[int(objectives[nextObjective - 1].x)][int(objectives[0].y)].pointer = objectives[nextObjective - 1];
          //make the starting block seen
          blocks[int(objectives[nextObjective - 1].x)][int(objectives[nextObjective - 1].y)].seen = true;
          //make the starting block not closed
          blocks[int(objectives[nextObjective - 1].x)][int(objectives[nextObjective - 1].y)].closed = false;
          //update the fcost of the starting block
          blocks[int(objectives[nextObjective - 1].x)][int(objectives[nextObjective - 1].y)].update_fcost();
        }
      }
    }
  }

  void create_wall() {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (in_rect(new PVector(mouseX, mouseY), blocks[x][y].pos.copy().mult(blocks[x][y].w).copy().add(blocks[x][y].displayPos), blocks[x][y].w, blocks[x][y].w)) {
          blocks[x][y].wall = true;
        }
      }
    }
  }

  void generate_random_walls(float wallProb) {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        for (int i = 0; i < objectives.length; i++) {
          if (random(1) > wallProb || dist(objectives[i].x, objectives[i].y, x, y) < 5 || dist(objectives[i].x, objectives[i].y, x, y) < 5) {
            blocks[x][y].wall = false;
            break;
          }
          blocks[x][y].wall = true;
        }
      }
    }
  }

  void display(float edgeThickness) {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        blocks[x][y].display(edgeThickness);
      }
    }
  }
}
