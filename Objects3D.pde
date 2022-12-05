// Created for CSCI 5611 by Dan Shervheim
// Monkey mesh is the default Blender starting file.
// Tiger mesh is by Jeremie Louvetz: https://sketchfab.com/3d-models/sumatran-tiger-95c4008c4c764c078f679d4c320e7b18#download

int numObstacles = 24;
int place = 1;
Camera camera;
ObjMesh copCarMesh;
ObjMesh car1Mesh;
ObjMesh car2Mesh;
ObjMesh car3Mesh;
ObjMesh car4Mesh;
float dt = 1;
Car[] cars;
int time;
int userCarIndex;
Vec2[] carPos;
float[] carWidths;
float[] carLengths;
float[] carRotations;
Vec2[] startPos;
Vec2[] goalPos;
ArrayList<Integer>[] paths;

Vec2[] obstaclePos;
float[] obstacleW;
float[] obstacleL;
boolean[] obstacleVisibility;

int numCollisions;
int pathLength;

int numNodes = 1000;
long startTime, endTime;
int strokeWidth = 2;

//// variables used for the particle coins at the end
//static int maxParticles = 200;
//PVector gravity =  new PVector(0, 150, 0);
//PVector particlePos[] = new PVector[maxParticles];
//PVector particleVel[] = new PVector[maxParticles];
//PVector particleRotations[] = new PVector[maxParticles];
//float[] particleScales = new float[maxParticles];
//int numParticles = 0;
//float genRate = 50;
//boolean startCoins = false;

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
  camera = new Camera();
  camera.position = new PVector( 250, -462, -106 );
  camera.phi = -1;
  camera.theta = 3.14;
  carPos = new Vec2[5];
  carWidths = new float[5];
  carLengths = new float[5];
  carRotations = new float[5];
  cars = new Car[5];
  paths = new ArrayList[5];
  //println("Press the Space Bar to set sail, press R to regenerate the system");
  //println();
  for(int i = 0; i < 5; i++){
    paths[i] = new ArrayList<Integer>();
    boolean isUser = false;
    if(i==0){
      isUser = true;
      
    }
    carPos[i] = new Vec2(10 + 13 * i, 60);
    cars[i] = new Car(carPos[i], isUser);
    cars[i].velocity = new PVector(0,0,0);
    cars[i].speed = random(.5,.65);
    cars[i].maxSpeed = cars[i].speed;
    carRotations[i] = 0;
    carLengths[i] = 20;
    carWidths[i] = 10;
    
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
  
  
  // obstacles
  obstaclePos = new Vec2[numObstacles];
  obstacleW = new float[numObstacles];
  obstacleL = new float[numObstacles];
  obstacleVisibility = new boolean[numObstacles];
  startPos = new Vec2[cars.length];
  goalPos = new Vec2[cars.length];
  
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
  
  obstaclePos[3] = new Vec2(60,150);
  obstacleW[3] = 50;
  obstacleL[3] = 30;
  obstacleVisibility[3] = true;
  
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
  
  obstaclePos[20] = new Vec2(445,320);
  obstacleW[20] = 20;
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
      //insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    nodePos[carNum][i] = randPos;
  }
}

// build the PRM based on the obstacles then print the path statistics
void testPRM(){
  for(int i = 0; i < cars.length; i++){
    startPos[i] = cars[i].position;
    //goalPos[i] = cars[i].position.minus(new Vec2(0, 10));
    goalPos[i] = new Vec2(cars[i].position.x, cars[i].position.y - 30);
    //println("start " + startPos + ", goal " + goalPos);
    
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
    //println(curPath);
    endTime = System.nanoTime();
    //pathQuality();
    println("Path: ", curPath);
  //  println("Nodes:", numNodes," Time (us):", int((endTime-startTime)/1000),
  //        " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions);
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
       if(cars[i].nextInd >= cars[i].path.size()){
         directionToTravel = goalPos[i].minus(carPos[i]);
         directionToTravel.normalize();
       
         if(carPos[i].distanceTo(goalPos[i]) < 3){
           cars[i].nextInd = 0;
           cars[i].numLaps++;
         }
       }else{
         directionToTravel = nodePos[i][cars[i].path.get(cars[i].nextInd)].minus(carPos[i]);
         directionToTravel.normalize();
         carPos[i].add(directionToTravel.times(cars[i].speed));
         cars[i].position = carPos[i];
         if(carPos[i].distanceTo(nodePos[i][cars[i].path.get(cars[i].nextInd)]) < 3){
           cars[i].nextInd++;
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
         cars[i].rotationAccel = -4;
         cars[i].speed = cars[i].maxSpeed - abs(difference) * 0.002;
       }else if(difference < 0.2){
         cars[i].rotationAccel = 4;
         cars[i].speed = cars[i].maxSpeed - abs(difference) * 0.002;
       }else{
         cars[i].rotationAccel = 0;
         cars[i].speed = cars[i].maxSpeed;
       }
       cars[i].rotationY += cars[i].rotationAccel * dt;
       cars[i].rotationY = cars[i].rotationY % 360;
       
       directionToTravel.normalize();
       //Vec2 directionOfRotation = new Vec2(sin(cars[i].rotationY * PI / 180), cos(cars[i].rotationY * PI / 180));
       cars[i].velocity = new PVector((sin(cars[i].rotationY * PI / 180) * cars[i].speed), 0, cos(cars[i].rotationY * PI / 180) * (cars[i].speed));
       carPos[i].add(new Vec2(cars[i].velocity.x, cars[i].velocity.z));

       cars[i].position = carPos[i];
       
    }
    
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
    
    hitInfo collision = rayCarListIntersect(carPos, carWidths, carLengths, carRotations, fourCorners, i);
    if(collision.hit){
      println("collision between " + i + ", " + collision.t + " at time " + time);
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
  // reset positions, path, coins, everything
  //if (key == 'r'){
  //  paused = true;
  //  numParticles = 0;
  //  startCoins = false;
  //  gravity =  new PVector(0, 150, 0);
  //  particlePos = new PVector[maxParticles];
  //  particleVel = new PVector[maxParticles];
  //  particleRotations = new PVector[maxParticles];
  //  testPRM();

  //  return;
  //}
  //// start the ship movement
  //if(key == ' '){
  //  paused = !paused;
  //}

  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}



void draw()
{
  time+=1;
  //Update agent if not paused
  //if (!paused){
  //  moveAgent(1.0/frameRate);
  //}
  //println(camera.position + ", " + camera.phi + ", " + camera.theta);
  background(255);
  camera.Update(1.0/frameRate);
  //println(camera.phi + ", " + camera.theta + ", " + camera.position);
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
  
  
  for(int i = 0; i < cars.length; i++){
    stroke( 0,0, 0 );
    fill( i * 40 ,255 - i * 40, 255 - i * 40 );
    pushMatrix();
    translate( startPos[i].x, -10, startPos[i].y );
    box( 2,10,2 );
    popMatrix();
    stroke( 0,0, 0 );
    pushMatrix();
    translate( goalPos[i].x, -10, goalPos[i].y );
    box( 2,10,2 );
    popMatrix();
    
      //show the nodes that it uses
    for(int j = 0; j < paths[i].size(); j++){
      pushMatrix();
      translate( nodePos[i][paths[i].get(j)].x, -10, nodePos[i][paths[i].get(j)].y );
      box( 3, 20, 3 );
      popMatrix();
    }
  }
  
  
  //for(int i = 0; i < nodePos[0].length; i++){
  //  stroke( 0,0, 0 );
  //  fill( 255,255, 255 );
  //  pushMatrix();
  //  translate( nodePos[0][i].x, -10, nodePos[0][i].y );
  //  box( 5, 5, 5 );
  //  popMatrix();
  //}
 

  copCarMesh.position = new PVector(carPos[0].x, -10, carPos[0].y);
  copCarMesh.rotation = new PVector(0, cars[0].rotationY, 180);
  copCarMesh.draw();
  
  car1Mesh.position = new PVector(carPos[1].x, -10, carPos[1].y);
  car1Mesh.rotation = new PVector(0, cars[1].rotationY, 180);
  car1Mesh.draw();
  
  car2Mesh.position = new PVector(carPos[2].x, -10, carPos[2].y);
  car2Mesh.rotation = new PVector(0, cars[2].rotationY, 180);
  car2Mesh.draw();
  
  car3Mesh.position = new PVector(carPos[3].x, -10, carPos[3].y);
  car3Mesh.rotation = new PVector(0, cars[3].rotationY, 180);
  car3Mesh.draw();
  
  car4Mesh.position = new PVector(carPos[4].x, -10, carPos[4].y);
  car4Mesh.rotation = new PVector(0, cars[4].rotationY, 180);
  car4Mesh.draw();
  //println(car4Mesh.rotation);
  
  
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
