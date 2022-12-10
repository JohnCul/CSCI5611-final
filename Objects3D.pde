// car racing simulator

int numObstacles = 24;
int place = 1;
Camera camera;
ObjMesh copCarMesh;
ObjMesh car1Mesh;
ObjMesh car2Mesh;
ObjMesh car3Mesh;
ObjMesh car4Mesh;
float dt = 0.05;
Car[] cars;
int time;
int userCarIndex;
Vec2[] carPos;
float[] carWidths;
float[] carLengths;
float[] carRotations;
boolean[] carVisibility;
float[] obstacleRot;
Vec2[] startPos;
Vec2[] goalPos;
ArrayList<Integer>[] paths;

Vec2[] obstaclePos;
float[] obstacleW;
float[] obstacleL;
boolean[] obstacleVisibility;

Vec2 userFinishPos;
float userFinishW;
float userFinishL;
int userFinishVisits;
Vec2 userMiddlePos;
float userMiddleW;
float userMiddleL;
int userMiddleVisits;

int numCollisions;
int pathLength;

int numNodes = 500;
long startTime, endTime;
int strokeWidth = 2;
float cameraYaw;
boolean wDown, sDown, dDown, aDown, upDown, downDown;

static int maxNumNodes = 1000;
Vec2[][] nodePos = new Vec2[5][numNodes];

ArrayList<Integer> curPath = new ArrayList();
int currNode;
boolean paused = true;
float shipSpeed = 100;


void setup()
{
  size(600, 600, P3D);
  userCarIndex = 0;
  userFinishPos = new Vec2(40,80);
  userFinishW = 80;
  userFinishL = 1;
  userMiddlePos = new Vec2(400,400);
  userMiddleW = 200;
  userMiddleL = 200;
  userMiddleVisits = 0;
  userFinishVisits = 0;
  camera = new Camera();
  carPos = new Vec2[5];
  carWidths = new float[5];
  carLengths = new float[5];
  carRotations = new float[5];
  cars = new Car[5];
  carVisibility = new boolean[5];
  paths = new ArrayList[5];
  wDown = false;
  sDown = false; 
  dDown = false;
  aDown = false;
  upDown = false;
  downDown  = false;
  //println("Press the Space Bar to set sail, press R to regenerate the system");
  //println();
  for(int i = 0; i < 5; i++){
    paths[i] = new ArrayList<Integer>();
    boolean isUser = false;
    carPos[i] = new Vec2(10 + 13 * i, 60);
    if(i==0){
      isUser = true;
    }
    cars[i] = new Car(carPos[i], isUser);
    cars[i].accelCoeff = 1;
    cars[i].velocity = new PVector(0,0,0);
    cars[i].rotationalVelo = 0;
    cars[i].maxRotationalVelo = 4;
    cars[i].acceleration = new PVector(0,0,0);
    cars[i].speed = 0;
    carVisibility[i] = true;
    cars[i].maxSpeed = random(.75,.9);
    carRotations[i] = 0;
    carLengths[i] = 6.5;
    carWidths[i] = 4;
    if(i==0){
      cars[i].accelCoeff = 0;
      cars[i].numLaps = -1;
    }
  }
  copCarMesh = new ObjMesh("Cop.obj");
  copCarMesh.scale = 3;
  car1Mesh = new ObjMesh("NormalCar1.obj");
  car1Mesh.scale = 3;
  car2Mesh = new ObjMesh("NormalCar2.obj");
  car2Mesh.scale = 3;
  car3Mesh = new ObjMesh("SportsCar.obj");
  car3Mesh.scale = 3;
  car4Mesh = new ObjMesh("SportsCar2.obj");
  car4Mesh.scale = 3;
  
  camera.position = new PVector( cars[0].position.x * cos(cars[0].rotationY * PI / 180) + 20 * sin(cars[0].rotationY * PI / 180), -25, cars[0].position.y * sin(cars[0].rotationY * PI / 180) + 20 * cos(cars[0].rotationY * PI / 180));
  camera.phi = -0.2;
  cameraYaw = 0.0;
  
  // obstacles
  obstaclePos = new Vec2[numObstacles];
  obstacleW = new float[numObstacles];
  obstacleL = new float[numObstacles];
  obstacleVisibility = new boolean[numObstacles];
  startPos = new Vec2[cars.length];
  goalPos = new Vec2[cars.length];
  
  obstacleRot = new float[numObstacles];
  for(int v = 0; v < numObstacles; v++){
     obstacleRot[v] = 0;
  }
  
  obstaclePos[0] = new Vec2(110,250);
  obstacleW[0] = 60;
  obstacleL[0] = 350;
  obstacleVisibility[0] = true;
  
  //finish: separate nodes between start and finish
  obstaclePos[1] = new Vec2(40,50);
  obstacleW[1] = 100;
  obstacleL[1] = 10;
  obstacleVisibility[1] = false;
  
  obstaclePos[2] = new Vec2(80,60);
  obstacleW[2] = 10;
  obstacleL[2] = 30;
  obstacleVisibility[2] = false;
  
  obstaclePos[3] = new Vec2(500,500);
  obstacleW[3] = 1;
  obstacleL[3] = 1;
  obstacleVisibility[3] = false;
  
  obstaclePos[4] = new Vec2(20,225);
  obstacleW[4] = 40;
  obstacleL[4] = 30;
  obstacleVisibility[4] = true;
  
  obstaclePos[5] = new Vec2(60,300);
  obstacleW[5] = 50;
  obstacleL[5] = 30;
  obstacleVisibility[5] = true;
  
  obstaclePos[6] = new Vec2(20,375);
  obstacleW[6] = 40;
  obstacleL[6] = 30;
  obstacleVisibility[6] = true;
  
  obstaclePos[7] = new Vec2(100,485);
  obstacleW[7] = 200;
  obstacleL[7] = 30;
  obstacleVisibility[7] = true;
  
  obstaclePos[8] = new Vec2(210,400);
  obstacleW[8] = 20;
  obstacleL[8] = 200;
  obstacleVisibility[8] = true;
  
  obstaclePos[9] = new Vec2(210,250);
  obstacleW[9] = 200;
  obstacleL[9] = 20;
  obstacleVisibility[9] = true;
  
  obstaclePos[10] = new Vec2(300,350);
  obstacleW[10] = 20;
  obstacleL[10] = 200;
  obstacleVisibility[10] = true;
  
  obstaclePos[11] = new Vec2(265,330);
  obstacleW[11] = 20;
  obstacleL[11] = 20;
  obstacleVisibility[11] = true;
  
  //edges
  obstaclePos[12] = new Vec2(505,250);
  obstacleW[12] = 20;
  obstacleL[12] = 500;
  obstacleVisibility[12] = true; 
  
  obstaclePos[13] = new Vec2(-5,250);
  obstacleW[13] = 20;
  obstacleL[13] = 500;
  obstacleVisibility[13] = true; 

  obstaclePos[14] = new Vec2(250, -5);
  obstacleW[14] = 500;
  obstacleL[14] = 20;
  obstacleVisibility[14] = true; 

  obstaclePos[15] = new Vec2(250,505);
  obstacleW[15] = 500;
  obstacleL[15] = 20;
  obstacleVisibility[15] = true; 
  
  obstaclePos[16] = new Vec2(230,380);
  obstacleW[16] = 20;
  obstacleL[16] = 20;
  obstacleVisibility[16] = true;
  
  obstaclePos[17] = new Vec2(280,430);
  obstacleW[17] = 20;
  obstacleL[17] = 20;
  obstacleVisibility[17] = true;
  
  obstaclePos[18] = new Vec2(390,400);
  obstacleW[18] = 130;
  obstacleL[18] = 20;
  obstacleVisibility[18] = true;
  
  obstaclePos[19] = new Vec2(335,400);
  obstacleW[19] = 50;
  obstacleL[19] = 20;
  obstacleVisibility[19] = false;
  
  obstaclePos[20] = new Vec2(395,320);
  obstacleW[20] = 120;
  obstacleL[20] = 150;
  obstacleVisibility[20] = true;
  
  obstaclePos[21] = new Vec2(335,320);
  obstacleW[21] = 20;
  obstacleL[21] = 150;
  obstacleVisibility[21] = true;
  
  obstaclePos[22] = new Vec2(350,175);
  obstacleW[22] = 300;
  obstacleL[22] = 20;
  obstacleVisibility[22] = true;
  
  obstaclePos[23] = new Vec2(350,100);
  obstacleW[23] = 300;
  obstacleL[23] = 200;
  obstacleVisibility[23] = true;

  testPRM();
}


//Generate non-colliding PRM nodes
void generateRandomNodes(int carNum){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(10, 490),random(10, 490));
    boolean insideAnyObstacle = pointInRectList(obstaclePos, obstacleW, obstacleL,obstaclePos.length,randPos,17);
    while (insideAnyObstacle){
      randPos = new Vec2(random(10, 490),random(10, 490));
      insideAnyObstacle = pointInRectList(obstaclePos, obstacleW, obstacleL,obstaclePos.length,randPos,17);
    }
    nodePos[carNum][i] = randPos;
  }
}

// build the PRM based on the obstacles then print the path statistics
void testPRM(){
  for(int i = 0; i < cars.length; i++){
    startPos[i] = cars[i].position;
    goalPos[i] = new Vec2(cars[i].position.x, cars[i].position.y - 30);
    
    startTime = System.nanoTime(); //<>//
    generateRandomNodes(i);
    connectNeighbors(obstaclePos, obstacleW, obstacleL, obstaclePos.length, nodePos[i], numNodes);
    
    curPath = planPath(startPos[i], goalPos[i], obstaclePos, obstacleW, obstacleL, obstaclePos.length, nodePos[i], numNodes);
    if(curPath.size() > 0){
      currNode = curPath.get(0);
      while(currNode < 0 && curPath.size() > 0){
        generateRandomNodes(i);
        connectNeighbors(obstaclePos, obstacleW, obstacleL, obstaclePos.length, nodePos[i], numNodes);
        curPath = planPath(startPos[i], goalPos[i], obstaclePos, obstacleW, obstacleL, obstaclePos.length, nodePos[i], numNodes);
        if(curPath.size() > 0){
          currNode = curPath.get(0);
        }
      }
      cars[i].nextInd = 0;
    }else{
      cars[i].nextInd = - 1;
    }
    paths[i] = curPath;
    cars[i].path = curPath;
    endTime = System.nanoTime();
    println("Path: ", curPath);
  }

}

public float findDifference(float carAngle, float desiredAngle){
  // when carAngle is 350 and desired is 5, we want it to go up to 360 then to 0
  float diff = 0.0;
  if(carAngle > 180 && desiredAngle < 90){
    desiredAngle += 360;
  }
  else if(carAngle < 90 && desiredAngle > 270){
    desiredAngle -= 360;
  }
  
  diff = carAngle - desiredAngle;
  if(diff < -180){
    diff+= 360;
  }
  return diff;
}


public void moveCars(){
   for(int i = 0; i < cars.length; i++){
     carRotations[i] = cars[i].rotationY;
     if(!cars[i].isUser){
       //move the car based on location, next node to travel to, and speed
       Vec2 directionToTravel = new Vec2(0,0);
       hitInfo pathSmoothing = new hitInfo();
       if(cars[i].nextInd >= cars[i].path.size()){
         directionToTravel = goalPos[i].minus(carPos[i]);
         directionToTravel.normalize();
         pathSmoothing = rayRectListIntersect(obstaclePos, obstacleW, obstacleL, obstaclePos.length, nodePos[i][cars[i].path.get(0)], carPos[i]);
         if(carPos[i].distanceTo(goalPos[i]) < 3 || !pathSmoothing.hit){
           cars[i].nextInd = 0;
           cars[i].numLaps++;
           //println(i+ " next lap " + cars[i].numLaps);
         }
       }else{
         directionToTravel = nodePos[i][cars[i].path.get(cars[i].nextInd)].minus(carPos[i]);
         directionToTravel.normalize();
         
         if(cars[i].nextInd + 1 == cars[i].path.size()){
           pathSmoothing = rayRectListIntersect(obstaclePos, obstacleW, obstacleL, obstaclePos.length, goalPos[i], carPos[i]);
           if(carPos[i].distanceTo(nodePos[i][cars[i].path.get(cars[i].nextInd)]) < 3 || !pathSmoothing.hit){
             directionToTravel = goalPos[i].minus(carPos[i]);
             directionToTravel.normalize();
             cars[i].nextInd++;
           }
         }else{
           pathSmoothing = rayRectListIntersect(obstaclePos, obstacleW, obstacleL, obstaclePos.length, nodePos[i][cars[i].path.get(cars[i].nextInd + 1)], carPos[i]);
           if(carPos[i].distanceTo(nodePos[i][cars[i].path.get(cars[i].nextInd)]) < 3 || !pathSmoothing.hit){
             cars[i].nextInd++;
           }
         }
       }
       
       //find angle to rotate
       Vec2 straight = new Vec2(0, -1);
       float dotProd = dot(directionToTravel, straight);
       float determinant = directionToTravel.x * straight.y - straight.x * directionToTravel.y; // or just directionToTravel.x
       float desiredAngle = atan2(determinant, dotProd) * 180 / PI;
       desiredAngle += 180;
       float difference = findDifference(cars[i].rotationY, desiredAngle);
       //if(abs(difference) > 20){
       //  println(i,", ",cars[i].rotationY,", ",desiredAngle,", ",difference);
       //}
       if(difference > 0.2){
         cars[i].rotationAccel = -3;
       }else if(difference < 0.2){
         cars[i].rotationAccel = 3;
       }else{
         cars[i].rotationAccel = 0;
       }
       cars[i].rotationY += cars[i].rotationAccel;
     
       cars[i].rotationY = cars[i].rotationY % 360;
       
       directionToTravel.normalize();
       
    }else{
       if(cars[i].rotationalVelo > cars[i].maxRotationalVelo){
         cars[i].rotationalVelo = cars[i].maxRotationalVelo;
       }else if(cars[i].rotationalVelo < -cars[i].maxRotationalVelo){
         cars[i].rotationalVelo = -cars[i].maxRotationalVelo;
       }else{
         cars[i].rotationalVelo += cars[i].rotationAccel * 0.2;
       }
       cars[i].rotationY += cars[i].rotationalVelo;
       
       cars[i].rotationY = cars[i].rotationY % 360;
       // see if user car passed finish line and iterate laps
       boolean inFinishLine = pointInRect(userFinishPos, userFinishW, userFinishL, carPos[i], 0);
       if(inFinishLine && userFinishVisits == userMiddleVisits){
         cars[i].numLaps++;
         userFinishVisits++;
         //println("new lap");
       }
       
       boolean inMiddleLine = pointInRect(userMiddlePos, userMiddleW, userMiddleL, carPos[i], 0);
       if(inMiddleLine && userFinishVisits == userMiddleVisits + 1){
         userMiddleVisits++;
         //println("user hit middle");
       }
    }
    
    
    cars[i].acceleration = new PVector((sin(cars[i].rotationY * PI / 180)), 0, cos(cars[i].rotationY * PI / 180)).mult(cars[i].accelCoeff);
    cars[i].velocity.add(cars[i].acceleration.mult(dt));
    if(cars[i].velocity.mag() > cars[i].maxSpeed){
      cars[i].velocity = cars[i].velocity.normalize().mult(cars[i].maxSpeed);
    }
    carPos[i].add(new Vec2(cars[i].velocity.x, cars[i].velocity.z));
    
    cars[i].position = carPos[i];
    
    // check for collisions with the current car and other cars. If there is a collision, adjust BOTH cars motions check cars[i]
    Vec2[] fourCorners = new Vec2[4];
    Vec2 c = carPos[i];
    float w = carWidths[i];
    float l = carLengths[i];
    float rot = carRotations[i] * PI / 180;
    fourCorners[0] = new Vec2(c.x - ((w/2)*cos(rot)) + ((l/2) * sin(rot)) , c.y - ((w/2)*sin(rot)) - ((l/2) * cos(rot)) );
    fourCorners[1] = new Vec2(c.x - ((w/2)*cos(rot)) - ((l/2) * sin(rot)) , c.y  - ((w/2) * sin(rot)) + ((l/2) * cos(rot)));
    fourCorners[2] = new Vec2(c.x + ((w/2)*cos(rot)) - ((l/2) * sin(rot)) , c.y + ((w/2)*sin(rot)) + ((l/2) * cos(rot)) );
    fourCorners[3] = new Vec2(c.x + ((w/2)*cos(rot)) + ((l/2) * sin(rot)) , c.y + ((w/2)*sin(rot)) - ((l/2)*cos(rot)));
    
    hitInfo collision = rayCarListIntersect(carPos, carWidths, carLengths, carRotations, carVisibility, fourCorners, i);
    if(collision.hit){
      // CHANGE THIS IF NEEDED
      Vec2 betweenCars = carPos[i].minus(carPos[(int) collision.t]).times(0.05);
      Vec2 betweenCarsBackwards = carPos[(int) collision.t].minus(carPos[i]).times(0.05);
      cars[i].velocity.add(new PVector(betweenCars.x * 0.3, 0, betweenCars.y * 0.3));
      cars[i].position.add(betweenCars.times(0.05));
      carPos[i] = cars[i].position;
      cars[(int) collision.t].velocity.add(new PVector(betweenCarsBackwards.x, 0, betweenCarsBackwards.y));
      cars[(int) collision.t].position.add(betweenCarsBackwards.times(0.05));
      carPos[(int) collision.t] = cars[(int) collision.t].position;
      
    }
    
    // check for collisions with walls
    collision = rayCarListIntersect(obstaclePos, obstacleW, obstacleL, obstacleRot, obstacleVisibility, fourCorners, -1);
    if(collision.hit){
      // CHANGE THIS IF NEEDED
      //println("collision between " + i + ", " + collision.t + " at time " + time);
      Vec2 betweenWall = carPos[i].minus(obstaclePos[(int) collision.t]);
      betweenWall.normalize();
      cars[i].velocity = new PVector(0,0,0);
      cars[i].velocity.add(new PVector(betweenWall.x * 0.1, 0, betweenWall.y * 0.1));
      cars[i].position.add(betweenWall.times(0.1));
      carPos[i] = cars[i].position;
      
    }
    
    
    if(cars[i].numLaps == 3 && !cars[i].finished){
        cars[i].finished = true;
        println(i," finished!");
      }
    else if(cars[i].position.y > 75 && cars[i].finished && !cars[i].placed){
      cars[i].place = place;
      cars[i].placed = true;
      place++;
      println(i , " placed " + cars[i].place);
        
    }
  }
}

//boolean shiftDown = false;
void keyPressed()
{

  if(keyCode == UP){
    upDown =true;
  }
  if(keyCode == DOWN){
    downDown =true;
  }
  
  if(key == 'd' || key == 'D'){
    dDown =true;
  }
  if(key == 'A' || key == 'a'){
    aDown =true;
  }
  if(key == 'W' || key == 'w' ){
    wDown =true;
  }
  if(key == 's' || key == 'S' ){
    sDown =true;
  }
  //camera.HandleKeyPressed();
}

void keyReleased()
{
  if(keyCode == DOWN ){
    downDown = false;
  }
  if(keyCode == UP ){
    upDown = false;
  }
  if(key == 'd' || key == 'D' ){
    dDown = false;
  }
  if(key == 'A' || key == 'a' ){
    aDown = false;
  }
  if(key == 'W' || key == 'w' ){
    wDown = false;
  }
  if(key == 's' || key == 'S' ){
    sDown = false;
  }
  //camera.HandleKeyReleased();
}

void draw()
{
  time+=1;
  if(upDown && cameraYaw < 0.2){
    cameraYaw += .005;
  }
  if(downDown && cameraYaw > -0.2){
    cameraYaw -= .005;
  }
  if(dDown && (wDown || sDown)){
    cars[0].rotationAccel = -.2;
  }
  if(aDown && (wDown || sDown)){
    cars[0].rotationAccel = .2;
  }
  if((dDown && aDown) || (!aDown && ! dDown)){
    cars[0].rotationAccel = 0;
    cars[0].rotationalVelo *= 0.8;
  }
  if(wDown){
    cars[0].accelCoeff = 1;
  }
  else if(sDown){
    cars[0].accelCoeff = -1;
  }else{
    cars[0].accelCoeff = 0;
    // simulates friction: slow it down if w or s not pressed
    cars[0].velocity.mult(0.95);
  }

  camera.position = new PVector( cars[0].position.x - 20 * sin(cars[0].rotationY * PI / 180), -25, cars[0].position.y - 20 * cos(cars[0].rotationY * PI / 180));
  camera.theta = PI + cars[0].rotationY * PI / 180;
  camera.phi = -0.2 + cameraYaw;
  //Update agent if not paused
  //if (!paused){
  //  moveAgent(1.0/frameRate);
  //}
  background(255);
  camera.Update(1.0/frameRate);
  directionalLight(255.0, 255.0, 255.0, 0, 1, -1);
  ambientLight(30, 30.0, 30.0);
  moveCars();
  // make the baseplate
  strokeWeight(1);
  stroke( 0, 0, 0 );
  fill( 105, 105, 105 );
  pushMatrix();
  translate( 250, 0, 250 );
  box( 500, 10, 500 );
  popMatrix();
  
  // make the four walls
  stroke( 0,0, 0 );
  fill( 255,255, 255 );
  pushMatrix();
  translate( 250, -10, 1 );
  rotateZ(3.14);
  box( 500, 10, 2 );
  popMatrix();
  
  fill( 255,255, 255 );
  pushMatrix();
  translate( 250, -10, 499 );
  rotateZ(3.14);
  box( 500, 10, 2 );
  popMatrix();
  
  fill( 255,255, 255 );
  pushMatrix();
  translate( 1, -10, 250 );
   rotateZ(3.14);
  box( 2, 10, 496 );
  popMatrix();
  
  fill( 255,255, 255 );
  pushMatrix();
  translate( 499, -10, 250 );
  rotateZ(3.14);
  box( 2, 10, 496 );
  popMatrix();
  
  
  ////Draw graph
  //stroke(0,0,0);
  //strokeWeight(1);
  //for (int i = 0; i < numNodes; i++){
  //  for (int j : neighbors[i]){
  //    line(nodePos[i].x,-10,nodePos[i].y,nodePos[j].x,-10,nodePos[j].y);
  //  }
  //}
  
  //starting/finish line
  for(int i = 0; i < 16; i++){
    if(i%2 == 0){
      fill( 0,0, 0 );
    }else{
      fill( 255,255,255 );
    }
    pushMatrix();
    translate( 80- 5*i, -5, 82.5 );
    //rotateZ(3.14);
    box( 5, 3, 5 );
    popMatrix();
  }
  //starting/finish line
  for(int i = 0; i < 16; i++){
    if(i%2 == 1){
      fill( 0,0, 0 );
    }else{
      fill( 255,255,255 );
    }
    pushMatrix();
    translate( 80- 5*i, -5, 77.5 );
    //rotateZ(3.14);
    box( 5, 3, 5 );
    popMatrix();
  }
  
  
  //for(int i = 0; i < cars.length; i++){
  //  stroke( 0,0, 0 );
  //  fill( i * 40 ,255 - i * 40, 255 - i * 40 );
  //  pushMatrix();
  //  translate( startPos[i].x, -10, startPos[i].y );
  //  box( 2,10,2 );
  //  popMatrix();
  //  stroke( 0,0, 0 );
  //  pushMatrix();
  //  translate( goalPos[i].x, -10, goalPos[i].y );
  //  box( 2,10,2 );
  //  popMatrix();
    
  //    //show the nodes that it uses
  //  for(int j = 0; j < paths[i].size(); j++){
  //    pushMatrix();
  //    translate( nodePos[i][paths[i].get(j)].x, -10, nodePos[i][paths[i].get(j)].y );
  //    box( 3, 20, 3 );
  //    popMatrix();
  //  }
  //}
  
  
  //for(int i = 0; i < nodePos[0].length; i++){
  //  stroke( 0,0, 0 );
  //  fill( 255,255, 255 );
  //  pushMatrix();
  //  translate( nodePos[0][i].x, -10, nodePos[0][i].y );
  //  box( 5, 5, 5 );
  //  popMatrix();
  //}
 

  copCarMesh.position = new PVector(carPos[0].x, -8, carPos[0].y);
  copCarMesh.rotation = new PVector(0, cars[0].rotationY, 180);
  copCarMesh.draw();
  
  car1Mesh.position = new PVector(carPos[1].x, -5, carPos[1].y);
  car1Mesh.rotation = new PVector(0, cars[1].rotationY, 180);
  car1Mesh.draw();
  
  car2Mesh.position = new PVector(carPos[2].x, -5, carPos[2].y);
  car2Mesh.rotation = new PVector(0, cars[2].rotationY, 180);
  car2Mesh.draw();
  
  car3Mesh.position = new PVector(carPos[3].x, -5, carPos[3].y);
  car3Mesh.rotation = new PVector(0, cars[3].rotationY, 180);
  car3Mesh.draw();
  
  car4Mesh.position = new PVector(carPos[4].x, -5, carPos[4].y);
  car4Mesh.rotation = new PVector(0, cars[4].rotationY, 180);
  car4Mesh.draw();
  
  for(int i = 0; i < obstaclePos.length; i++){
    if(obstacleVisibility[i]){
      noStroke();
      fill( 0,0, 255 );
      pushMatrix();
      translate( obstaclePos[i].x, -10, obstaclePos[i].y );
      box( obstacleW[i], 40, obstacleL[i] );
      popMatrix();
    }
  }
}
