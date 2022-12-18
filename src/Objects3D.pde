// car racing simulator

int numObstacles = 24;
int place = 1;
Camera camera;
ObjMesh car0Mesh;
ObjMesh car1Mesh;
ObjMesh car2Mesh;
ObjMesh car3Mesh;
ObjMesh car4Mesh;
float dt = 0.05;
Table carData;
Car[] cars;
int time;
int userCarIndex;
Vec2[] carPos;
int[] carIDs;
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

Vec2[] car0corners;

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

int carStartTime;
int carTime;

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
  carData = setUpCarStats();
  car0corners = new Vec2[4];
  for(int i = 0; i < car0corners.length; i++){
    car0corners[i] = new Vec2(0,0);
  }
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
  carIDs = new int[5];
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
  // get the ID's of the cars that will race
  for(int i = 0; i < 5; i++){
    carIDs[i] = (int) (random(0,1) * 6.99);
  }
  
  for(int i = 0; i < 5; i++){
    int carIndex = carData.getInt(carIDs[i], "id");
    paths[i] = new ArrayList<Integer>();
    boolean isUser = false;
    carPos[i] = new Vec2(10 + 13 * i, 60);
    if(i==0){
      isUser = true;
    }
    cars[i] = new Car(carPos[i], isUser);
    cars[i].accelCoeff = carData.getFloat(carIndex, "acceleration");
    cars[i].velocity = new PVector(0,0,0);
    cars[i].rotationalVelo = 0;
    cars[i].maxRotationalVelo = 4;
    cars[i].acceleration = new PVector(0,0,0);
    cars[i].speed = 0;
    carVisibility[i] = true;
    cars[i].maxSpeed = carData.getFloat(carIndex, "maxSpeed");
    carRotations[i] = 0;
    carLengths[i] = carData.getFloat(carIndex, "length");
    carWidths[i] = carData.getFloat(carIndex, "width");
    if(i==0){
      cars[i].accelCoeff = 0;
      cars[i].numLaps = -1;
    }
  }
  car0Mesh = new ObjMesh(carData.getString(carData.getInt(carIDs[0], "id"), "mesh"));
  println("User got " + carData.getString(carData.getInt(carIDs[0], "id"), "mesh"));
  car0Mesh.scale = 3;
  car1Mesh = new ObjMesh(carData.getString(carData.getInt(carIDs[1], "id"), "mesh"));
  car1Mesh.scale = 3;
  car2Mesh = new ObjMesh(carData.getString(carData.getInt(carIDs[2], "id"), "mesh"));
  car2Mesh.scale = 3;
  car3Mesh = new ObjMesh(carData.getString(carData.getInt(carIDs[3], "id"), "mesh"));
  car3Mesh.scale = 3;
  car4Mesh = new ObjMesh(carData.getString(carData.getInt(carIDs[4], "id"), "mesh"));
  car4Mesh.scale = 3;
  
  camera.position = new PVector( cars[0].position.x * cos(cars[0].rotationY * PI / 180) + 20 * sin(cars[0].rotationY * PI / 180), -25, cars[0].position.y * sin(cars[0].rotationY * PI / 180) + 20 * cos(cars[0].rotationY * PI / 180));
  camera.phi = -0.2;
  cameraYaw = -0.1;
  
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

  //testPRM();
}

Table setUpCarStats(){
  Table stats = new Table();
  stats.addColumn("id");
  stats.addColumn("acceleration");
  stats.addColumn("maxSpeed");
  stats.addColumn("width");
  stats.addColumn("length");
  stats.addColumn("mesh");
  
  // car 0: police car
  TableRow newRow = stats.addRow();
  newRow.setInt("id", 0);
  newRow.setFloat("acceleration", 1);
  newRow.setFloat("maxSpeed", random(1.0,1.1));
  newRow.setFloat("width", 5);
  newRow.setFloat("length", 11);
  newRow.setString("mesh", "Cop.obj");
  
  //car 1: normal car 1
  TableRow newRow2 = stats.addRow();
  newRow2.setInt("id", 1);
  newRow2.setFloat("acceleration", .5);
  newRow2.setFloat("maxSpeed", random(.5,.7));
  newRow2.setFloat("width", 4);
  newRow2.setFloat("length",11);
  newRow2.setString("mesh", "NormalCar1.obj");
  
  //car 2: normal car 2
  TableRow newRow3 = stats.addRow();
  newRow3.setInt("id", 2);
  newRow3.setFloat("acceleration", .8);
  newRow3.setFloat("maxSpeed", random(.6,.7));
  newRow3.setFloat("width", 4);
  newRow3.setFloat("length",11);
  newRow3.setString("mesh", "NormalCar2.obj");
  
  //car 3: sports car 1
  TableRow newRow4 = stats.addRow();
  newRow4.setInt("id", 3);
  newRow4.setFloat("acceleration", 1.1);
  newRow4.setFloat("maxSpeed", random(0.8,0.9));
  newRow4.setFloat("width", 4);
  newRow4.setFloat("length", 10.5);
  newRow4.setString("mesh", "SportsCar.obj");
  
  //car 4: sports car 2
  TableRow newRow5 = stats.addRow();
  newRow5.setInt("id", 4);
  newRow5.setFloat("acceleration", 1.0);
  newRow5.setFloat("maxSpeed", random(0.7,0.85));
  newRow5.setFloat("width", 5);
  newRow5.setFloat("length", 11);
  newRow5.setString("mesh", "SportsCar2.obj");
  
  //car 5: taxi
  TableRow newRow8 = stats.addRow();
  newRow8.setInt("id", 5);
  newRow8.setFloat("acceleration", 1.2);
  newRow8.setFloat("maxSpeed", random(0.8,0.9));
  newRow8.setFloat("width", 5.5);
  newRow8.setFloat("length", 11);
  newRow8.setString("mesh", "Taxi.obj");
  
  //car 6: SUV
  TableRow newRow7 = stats.addRow();
  newRow7.setInt("id", 6);
  newRow7.setFloat("acceleration", .8);
  newRow7.setFloat("maxSpeed", random(.5,.6));
  newRow7.setFloat("width", 5);
  newRow7.setFloat("length", 11);
  newRow7.setString("mesh", "SUV.obj");

  return stats;
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
    goalPos[i] = new Vec2(cars[cars.length - 1].position.x, cars[cars.length - 1].position.y - 30);
    
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
    println("Car "+ i + " Path: ", curPath);
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
       if(difference > .02){
         cars[i].rotationAccel = -3;
       }else if(difference < .02){
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
    //float rot = PI + carRotations[i] * PI / 180;
    float rot = PI - (carRotations[i]* PI / 180);
    fourCorners[0] = new Vec2(c.x - ((w/2)*cos(rot)) + ((l/2) * sin(rot)) , c.y - ((w/2)*sin(rot)) - ((l/2) * cos(rot)) );
    fourCorners[1] = new Vec2(c.x - ((w/2)*cos(rot)) - ((l/2) * sin(rot)) , c.y  - ((w/2) * sin(rot)) + ((l/2) * cos(rot)));
    fourCorners[2] = new Vec2(c.x + ((w/2)*cos(rot)) - ((l/2) * sin(rot)) , c.y + ((w/2)*sin(rot)) + ((l/2) * cos(rot)) );
    fourCorners[3] = new Vec2(c.x + ((w/2)*cos(rot)) + ((l/2) * sin(rot)) , c.y + ((w/2)*sin(rot)) - ((l/2)*cos(rot)));
    if( i==0){
      car0corners[0] = fourCorners[0];
      car0corners[1] = fourCorners[1];
      car0corners[2] = fourCorners[2];
      car0corners[3] = fourCorners[3];
    }
    
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
    collision = rayCarObstacleListIntersect(obstaclePos, obstacleW, obstacleL, obstacleRot, obstacleVisibility, fourCorners, -1);
    if(collision.hit){
      // CHANGE THIS IF NEEDED
      int chosen  = 0;
      if((int) collision.t == 0){
        chosen = 1;
      }else if((int) collision.t == 2){
        chosen = 3;
      }else if((int) collision.t == 3){
        chosen = 2;
      }
      // find the nromal vector to "bounce off of"
      Vec2 rHit = carPos[i].minus(fourCorners[(int) collision.t]);
      Vec2 rOpposite = carPos[i].minus(fourCorners[chosen]);
      Vec2 addedR = rHit.plus(rOpposite);
      addedR.normalize();
      cars[i].position.add(rHit.times(0.05));
      float currentCarVelo = cars[i].velocity.mag() + 0.2;
      cars[i].velocity = new PVector(0,0,0);
      cars[i].velocity.add(new PVector(addedR.x * 0.3 * currentCarVelo, 0, addedR.y * 0.3 * currentCarVelo));
      carPos[i] = cars[i].position;
      
    }
    
    
    if(cars[i].numLaps == 3 && !cars[i].finished){
        cars[i].finished = true;
        println("Car " + i + " finished!");
    }
    else if(cars[i].position.y > 75 && cars[i].finished && !cars[i].placed){
      cars[i].place = place;
      cars[i].placed = true;
      place++;
      println("Car " + i , " placed " + cars[i].place);
        
    }
  }
  
  if(!cars[0].finished){
      carTime = millis() - carStartTime;
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
  if(key == ' '){
    paused = false;
    carStartTime = millis();
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

//Vec2 findPointOutsideOfObstacle(Vec2 cameraPos){
//  Vec2 ret = cameraPos;
//  while(pointInRectList(obstaclePos, obstacleW, obstacleL, obstaclePos.length, ret, 0)){
//    Vec2 betweenCamAndCar = carPos[0].minus(cameraPos);
//    camera.position.add(new PVector(betweenCamAndCar.x * 0.02, 0, betweenCamAndCar.y * 0.02));
//    ret = new Vec2(camera.position.x, camera.position.z);
//  }
//  return ret;
//}


void draw()
{
  background(255);
  camera.Update(1.0/frameRate);
  directionalLight(100.0, 100.0, 100.0, 0, 1, -1);
  ambientLight(155, 155.0, 155.0);
  camera.position = new PVector( cars[0].position.x - 20 * sin(cars[0].rotationY * PI / 180), -25, cars[0].position.y - 20 * cos(cars[0].rotationY * PI / 180));
  //Vec2 cameraVec2 = new Vec2(camera.position.x, camera.position.z);
  //println(pointInRectList(obstaclePos, obstacleW, obstacleL, obstaclePos.length, cameraVec2, 0));
  //if(pointInRectList(obstaclePos, obstacleW, obstacleL, obstaclePos.length, cameraVec2, 0)){
  //  Vec2 positionToAdd = findPointOutsideOfObstacle(cameraVec2);
  //  camera.position.add(new PVector(positionToAdd.x, 0, positionToAdd.y));
  //}
  camera.theta = PI + cars[0].rotationY * PI / 180;
  camera.phi = -0.2 + cameraYaw;
  if(time == 0){
    surface.setTitle("Loading AI Car Pathways");
    testPRM();
    time+=1;
  }else{
    surface.setTitle("Racing Game!");
    time+=1;
    //if(upDown && cameraYaw < 0.2){
    //  cameraYaw += .005;
    //}
    //if(downDown && cameraYaw > -0.2){
    //  cameraYaw -= .005;
    //}
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
      cars[0].accelCoeff = carData.getFloat(carData.getInt(carIDs[0], "id"), "acceleration");
    }
    else if(sDown){
      cars[0].accelCoeff = -1 * carData.getFloat(carData.getInt(carIDs[0], "id"), "acceleration");
    }else{
      cars[0].accelCoeff = 0;
      cars[0].rotationAccel = 0;
      // simulates friction: slow it down if w or s not pressed
      cars[0].velocity.mult(0.95);
    }
    //Update agent if not paused
    if (!paused){
      moveCars(); 
    }
    // make the baseplate
    strokeWeight(1);
    stroke( 0, 0, 0 );
    fill( 105, 105, 105 );
    pushMatrix();
    translate( 250, 0, 250 );
    box( 500, 10, 500 );
    popMatrix();
    
    
    //starting/finish line
    for(int i = 0; i < 16; i++){
      if(i%2 == 0){
        fill( 0,0, 0 );
      }else{
        fill( 255,255,255 );
      }
      pushMatrix();
      translate( 80- 5*i, -5, 83 );
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
      translate( 80- 5*i, -5, 78 );
      //rotateZ(3.14);
      box( 5, 3, 5 );
      popMatrix();
    }
    
    //meshes 
    car0Mesh.position = new PVector(carPos[0].x, -5, carPos[0].y);
    car0Mesh.rotation = new PVector(0, cars[0].rotationY, 180);
    car0Mesh.draw();
    
    
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
        //noStroke();
        fill( 0,0, 255 );
        pushMatrix();
        translate( obstaclePos[i].x, -20, obstaclePos[i].y );
        box( obstacleW[i], 30, obstacleL[i] );
        popMatrix();
      }
    }
  } //<>//
  
  //GUI background
  pushMatrix();
  translate(cars[0].position.x + 500  * sin(cars[0].rotationY * PI / 180), -80, cars[0].position.y + 500 * cos(cars[0].rotationY * PI / 180)) ;
  rotateY(camera.theta);
  hint(DISABLE_DEPTH_TEST);
  rotateZ(PI / 2);
  rotateX(PI / 2);
  rotateY(PI / 2);
  
  rotateX(PI/2);
  fill(100,100,100, 100);
  rect(500,120,-2000, -600);
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  
  
  

  // num laps
  pushMatrix();
  translate(cars[0].position.x + 500  * sin(cars[0].rotationY * PI / 180), -80, cars[0].position.y + 500 * cos(cars[0].rotationY * PI / 180)) ;
  rotateY(camera.theta);
  hint(DISABLE_DEPTH_TEST);
  int numToDisplay = (int)(cars[0].numLaps + 1);
  if(cars[0].finished && cars[0].place != 0){
    fill(255,100,100);
    textSize(40);
    numToDisplay = 3;
    text("FINISHED PLACE " + cars[0].place, -370, 110);
  }
  fill(255,100,100);
  textSize(40);
  text("TIME: " + (float)carTime / 1000.0 + " SECONDS", -390, 70);
  textSize(60);
  text("LAP " + numToDisplay + "/3", 170, 70);
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  
  
  //map
  pushMatrix();
  translate(cars[0].position.x + 500  * sin(cars[0].rotationY * PI / 180), -80, cars[0].position.y + 500 * cos(cars[0].rotationY * PI / 180)) ;
  rotateY(camera.theta);
  hint(DISABLE_DEPTH_TEST);
  translate(30,110,0);
  rotateZ(PI / 2);
  rotateX(PI / 2);
  rotateY(PI / 2);
  
  translate(-100,0,-100);

  for(int i = 0; i < carPos.length; i++){
    fill( 0,255, 50 );
    translate(carPos[i].x / 5, 0, carPos[i].y / 5);
    rotateX(PI/2);
    if(cars[i].isUser){
      fill( 255,255, 0 );
      star(0, 0, 1.5, 3.5, 5); 
    }else{
      circle(0,0,5);
    }
    //sphere(2);
    rotateX(-PI/2);
    translate(-carPos[i].x / 5, 0, -carPos[i].y / 5);
  }
  for(int i = 0; i < obstaclePos.length; i++){
    if(obstacleVisibility[i]){
      noStroke();
      fill( 0,0, 0 );
      pushMatrix();
      translate( obstaclePos[i].x / 5, 0, obstaclePos[i].y / 5 );
      box( obstacleW[i] / 5, 8, obstacleL[i] / 5 );
      popMatrix();
    }
  }
  //starting/finish line
  for(int i = 0; i < 16; i++){
    if(i%2 == 0){
      fill( 0,0, 0 );
    }else{
      fill( 255,255,255 );
    }
    pushMatrix();
    translate( (80- 5*i) / 5, 0, 82.5 /5);
    //rotateZ(3.14);
    box( 1, .6, 1 );
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
    translate( (80- 5*i) / 5, 0, 77.5 /5);
    //rotateZ(3.14);
    box( 1, .6, 1 );
    popMatrix();
  }
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  
  if(paused){
    pushMatrix();
    translate(cars[0].position.x + 500  * sin(cars[0].rotationY * PI / 180), 0, cars[0].position.y + 500 * cos(cars[0].rotationY * PI / 180)) ;
    rotateY(camera.theta);
    hint(DISABLE_DEPTH_TEST);
    textSize(70);
    
    fill(255,100,100);
    text("PRESS SPACE TO RACE", -350, 100);
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
}

void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
