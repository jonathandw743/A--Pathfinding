//term "dist" in comments used loosely to mean the cost from getting from one square to another in a certain path

Grid grid;
boolean pathfinding;
PVector[] objectives;

void setup() {
  size(800, 600);
  objectives = new PVector[4];
  objectives[0] = new PVector(0, height / 10 - 1);
  objectives[1] = new PVector(30, 20);
  objectives[2] = new PVector(50, 40);
  objectives[3] = new PVector(width / 10 - 1, 0);
  grid = new Grid(width / 10, height / 10, 10, objectives, new PVector(0, 0));
  //for (int i = 0; i < 500; i++) {
  //  grid.step();
  //}
  pathfinding = false;
  
  grid.generate_random_walls(0.75);
}

void draw() {
  grid.display(1);
  if (pathfinding && !grid.pathFound) {
    grid.step();
    //delay(100);
  }

  if (mousePressed) {
    if (!grid.pathFound) {
      if (mouseButton == LEFT) {
        pathfinding = true;
        //while (pathfinding && !grid.pathFound) {
        //  grid.step();
        //  //delay(100);
        //}
      } else {
        grid.create_wall();
      }
    }
  }
}

//void mousePressed() {
//  if (!grid.pathFound) {
//    if (mouseButton == LEFT) {
//      pathfinding = true;
//    } else {
//      grid.create_wall();
//    }
//  }
//}
