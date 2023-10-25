class Block {
  //it is assumed that this is in a 2D array

  //pos is position in block array in grid not position on screen
  PVector pos;
  //size of the block (stands for width)
  float w;
  //g cost ("dist" from start)
  int g;
  //h cost ("dist" from end)
  int h;
  //f cost (g cost  + h cost)
  int f;
  //has this block been visited and closed off
  boolean closed;
  //is this block and obstacle / wall
  boolean wall;
  //is this block the starting block
  boolean start;
  //is this block the target / end block
  boolean objective;
  //whether the block is being seen
  boolean seen;
  //whether the block is in the path
  boolean path;
  //where this block was seen from
  PVector pointer;
  //what to add to the actual pos to display on the screen
  PVector displayPos;

  Block(PVector pos, float w, boolean wall, boolean start, boolean objective, PVector displayPos) {
    this.pos = pos;
    this.w = w;
    //block always starts as not having been visited
    this.closed = false;
    this.wall = wall;
    this.start = start;
    this.objective = objective;
    //block always starts as not being seen
    this.seen = false;
    //block only starts in the path if it is the start or end block
    if (start || objective) {
      this.path = true;
    } else {
      this.path = false;
    }
    this.displayPos = displayPos;
    this.pointer = null;
  }

  void calc_hcost(PVector targetPos) {
    PVector d = new PVector(abs(targetPos.x - pos.x), abs(targetPos.y - pos.y));
    if (d.x > d.y) {
      h = int(d.y * 14 + (d.x - d.y) * 10);
    } else {
      h = int(d.x * 14 + (d.y - d.x) * 10);
    }
    //h *= 10;
  }

  void update_fcost() {
    f = g + h;
  }

  void display(float edgeThickness) {
    stroke(0);
    strokeWeight(edgeThickness);
    if (closed) {
      fill(255, 80, 80);
    } else if (seen) {
      fill(80, 255, 80);
    } else {
      fill(255);
    }
    if (path) {
      fill(80, 80, 255);
    }
    if (start || objective) {
      fill(0, 255, 255);
    }
    if (wall) {
      fill(0);
    }
    square(pos.x * w + displayPos.x, pos.y * w + displayPos.y, w);
    //textSize(10);
    //fill(0);
    //text("g:" + str(g), pos.x * w + 2 + displayPos.x, pos.y * w + 12 + displayPos.y);
    //text("h:" + str(h), pos.x * w + 24 + displayPos.x, pos.y * w + 12 + displayPos.y);
    //textSize(15);
    //text("f:" + str(f), pos.x * w + 5 + displayPos.x, pos.y * w + 42 + displayPos.y);
    //if (pointer != null) {
    //  textSize(10);
    //  fill(0);
    //  text("x:" + str(int(pointer.x)), pos.x * w + 2 + displayPos.x, pos.y * w + 12 + displayPos.y);
    //  text("y:" + str(int(pointer.y)), pos.x * w + 24 + displayPos.x, pos.y * w + 12 + displayPos.y);
    //}
  }
}
