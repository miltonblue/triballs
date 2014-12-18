// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// A fixed boundary class (now incorporates angle)

int counter = 0;

float note, interval;
float semi;

class Boundary {
  int counter_mod;
  
  public color coll;// = color(0,0,0);
  
  boolean delete = false;
  
  float[][][] rgbs = {
  {//First color
    {195, 63, 146},
    {105, 97, 186},
    {65, 178, 212},
    {164,216,128},
   }
};
  

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;
  // But we also have to make a body for box2d to know about it
  Body body;
  
 color returnColor()
 {
   return coll;
 }
  

 Boundary(float x_,float y_, float w_, float h_, float a) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    
    //coll = color(rgbs[0][counter][0],rgbs[0][counter][1],rgbs[0][counter][2]);
    coll = color((int)random(255),(int)random(255),(int)random(255));
    /*println(counter);
    counter += 1;
    if (counter >= 4){
      counter = 0;
    }*/
    
    // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.angle = a;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    body = box2d.createBody(bd);
    
    // Attached the shape to the body using a Fixture
    body.createFixture(sd,1);
    body.setUserData(this);
  }

  // Draw the boundary, if it were at an angle we'd have to do something fancier
  void display() {
    //counter += 1;
    //counter_mod = counter%6;
    //println(rgbs[0][0]);
    //coll = color(rgbs[counter][0][0],rgbs[counter][0][1],rgbs[counter][0][2]);
    noFill();
    stroke(coll);
    
    strokeWeight(1);
    rectMode(CENTER);

    float a = body.getAngle();

    pushMatrix();
    translate(x,y);
    rotate(-a);
    rect(0,0,w,h);
    popMatrix();
  }
  
  void killBody() {
    box2d.destroyBody(body);
    
    //semi = (int)w / 6;
    semi = (int)w/4;
    //println(semi);
    //if (semi == 0 || semi ==1)
    //semi = (int)random(24);
    interval = semi/12;
    note = 440*pow(2,interval);
    out.playNote( 0, 0.2, new SineInstrument( note ) );
  }
  
  void delete() {
    //out.playNote( 0, 1, new SineInstrument( w ) );
    delete = true;
    
  }
  
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+r*2 || delete) {
      killBody();
      return true;
    }
    return false;
  }

}


class SineInstrument implements Instrument {
  Oscil sineWave;
  ADSR envelope;
  Delay delay;

  SineInstrument( float frequency ) {
    sineWave = new Oscil( frequency, 0.01f, Waves.SINE );
    envelope = new ADSR ( 3.0, 0.001 ); // max amplitude (unknown unit), attack speed in seconds
    sineWave.patch( envelope );
  }

  void noteOn( float duration ) {
    envelope.noteOn();
    envelope.patch( out );
  }

  void noteOff() {
    envelope.unpatchAfterRelease( out );
    envelope.noteOff();
  }
}
