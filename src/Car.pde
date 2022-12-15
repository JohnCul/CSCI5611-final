//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Car {
  public Vec2 position;
  public boolean isUser;
  public PVector velocity;
  public PVector acceleration;
  public float speed;
  public float maxSpeed;
  public float rotationAccel;
  public float rotationalVelo;
  public float maxRotationalVelo;
  public float rotationY;
  public int nextInd;
  public ArrayList<Integer> path;
  public int numLaps;
  public boolean finished = false;
  public int place;
  public boolean placed = false;
  public int accelCoeff;
  
  public Car(Vec2 position, boolean isUser){
    this.position = position;
    this.isUser = isUser;
    this.rotationAccel = 0.0;
    this.velocity = new PVector();
    this.path = new ArrayList<Integer>();
    this.numLaps = 0;
  }
}
