import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


import megamu.mesh.*;

Box2DProcessing box2d;


import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput   out;
Gain         gain;


ArrayList<Boundary> boundaries;
ArrayList<Ball> balls;

ArrayList<Float>x_list;
ArrayList<Float>y_list;

float x, y;//variable f
float x_coord, y_coord;
PVector v1, v2;
float[][] myEdges;
int point_nr;

float delta_x, delta_y, bound_x, bound_y, hyp, theta;

float pi = 3.14159265358979323846;
//Import the Balls Class

Boundary wall;

float r;//radius of the ball

void setup() {
  
  
  minim = new Minim( this );  
  out = minim.getLineOut();

  //gain = new Gain(1.f);

  point_nr = 400;
  smooth();
  //noLoop();
  //stroke(30);
  size(500, 1000);
  x_list=new ArrayList<Float>();
  y_list=new ArrayList<Float>();
  //background(153);
  //v1 = new PVector(40, 20);
  //v2 = new PVector(25, 50);

  box2d = new Box2DProcessing(this);  
  box2d.createWorld();

  box2d.listenForCollisions();


  box2d.setGravity(0, -50);


  balls = new ArrayList<Ball>();

  float[][] points = new float[point_nr][2];
  for (int i = 0; i < point_nr; i++) {
    x = random(width - 100);
    y = random(height - 100);
    points[i][0]=x;
    points[i][1]=y;
  }

  Delaunay myDelaunay = new Delaunay( points );
  myEdges = myDelaunay.getEdges();


  boundaries = new ArrayList<Boundary>();

  //boundaries.add(new Boundary(width/2, height-50, width, 10, 0));


  for (int i=0; i<myEdges.length; i++) {
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];

    delta_x = endX - startX;
    delta_y = endY - startY;

    bound_x = startX + delta_x/2;
    bound_y = startY + delta_y/2;

    hyp = sqrt(pow(delta_x, 2)+pow(delta_y, 2));

    theta = atan(delta_y/delta_x);

    boundaries.add(new Boundary(bound_x+50, bound_y+50, hyp, 0, -theta));
    //line( startX, startY, endX, endY );
    //println(startX, startY, endX, endY);
  }
}

void draw() {
  background(230, 243, 249);
  /*for (int j = 0; j < 100; j++) {
   x_coord = x_list.get((int)random(100));
   y_coord = y_list.get((int)random(100));
   ellipse(x_coord,y_coord, 2, 2);*/

  box2d.step(); 

  // Display all the boxes
  /*for (Ball b : balls) {
   b.display();
   }*/

  for (int i = balls.size ()-1; i >= 0; i--) {
    Ball p = balls.get(i);
    p.display();
    // Particles that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    if (p.done()) {
      balls.remove(i);
    }
  }

  for (int i = boundaries.size ()-1; i >= 0; i--) {
    Boundary p = boundaries.get(i);
    p.display();
    // Particles that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    if (p.done()) {
      boundaries.remove(i);
    }
  }


  for (int i = boundaries.size ()-1; i>= 0; i--) {
    Boundary wall = boundaries.get(i);
    wall.display();
  }
  //println(wall);
}



void mouseClicked() {
  Ball p = new Ball(mouseX, mouseY);
  balls.add(p);
}

// Collision event functions!
void beginContact(Contact cp) {
  // Get both shapes
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  /*if (o1.getClass() == Ball.class && o2.getClass() == Ball.class) {
    Ball p1 = (Ball) o1;
    p1.delete();
    Ball p2 = (Ball) o2;
    p2.delete();
  }*/

  if (o1.getClass() == Boundary.class && o2.getClass() == Ball.class) {
    //Ball p = (Ball) o2;
    //p.delete();
    Boundary p1 = (Boundary) o1;
    color colo = p1.returnColor();
    p1.delete();
    Ball p2 = (Ball) o2;
    p2.change(colo);
  }
  if (o2.getClass() == Boundary.class && o1.getClass() == Ball.class) {
    Boundary p = (Boundary) o2;
    p.delete();
    //Ball p1 = (Ball) o1;
    //p1.delete();
  }
}

// Objects stop touching each other
void endContact(Contact cp) {
}

