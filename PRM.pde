//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius of obstacles
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of nodes in the PRM
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The function connectNeighbors() will always be called before planPath()
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of the positions in the nodePos array will ever be inside an obstacle
//   - The start and the goal position will never be inside an obstacle

// There are many useful functions in CollisionLibrary.pde and Vec2.pde
// which you can draw on in your implementation. Please add any additional 
// functionality you need to this file (PRM.pde) for compatabilty reasons.

// Here we provide a simple PRM implementation to get you started.
// Be warned, this version has several important limitations.
// For example, it uses BFS which will not provide the shortest path.
// Also, it (wrongly) assumes the nodes closest to the start and goal
// are the best nodes to start/end on your path on. Be sure to fix 
// these and other issues as you work on this assignment. This file is
// intended to illustrate the basic set-up for the assignmtent, don't assume 
// this example funcationality is correct and end up copying it's mistakes!).



//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] corners, float[] widths, float[] lengths, int numObstacles, Vec2[] nodePos, int numNodes){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      //Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      //float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayRectListIntersect(corners, widths, lengths, numObstacles, nodePos[i], nodePos[j]);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
        //println("neighbor added", nodePos[i]," ", nodePos[j]);
      }
    }
  }
}

////This is probably a bad idea and you shouldn't use it...
//int closestNode(Vec2 point, Vec2[] nodePos, int numNodes){
//  int closestID = -1;
//  float minDist = 999999;
//  for (int i = 0; i < numNodes; i++){
//    float dist = nodePos[i].distanceTo(point);
//    if (dist < minDist){
//      closestID = i;
//      minDist = dist;
//    }
//  }
//  return closestID;
//}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] corners, float[] widths, float[] lengths, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  //int startID = closestNode(startPos, nodePos, numNodes);
  //int goalID = closestNode(goalPos, nodePos, numNodes);
  //println(startPos);
  //println(goalPos);
  path = runAStar(nodePos, startPos, goalPos, numNodes, corners, widths, lengths, numObstacles);
  
  return path;
}


Float getHeuristicValue(Vec2 startPos, Vec2 goalPos, Vec2 nodePoint){
  // get the distance to the line from start to end from the nodePoint using dot product and trig
  Float value = 0.0;
  Float segmentLength = startPos.distanceTo(nodePoint);
  Vec2 dir = startPos.minus(goalPos);
  dir.x = -1 * dir.x;
  float angle = acos(dot(dir, nodePoint) / (nodePoint.length() * dir.length()));
  value = segmentLength * sin(angle);
  
  //println(nodePoint + " position, " + startPos + " startpos, " + goalPos + " endpos, " + dir + " dir, " + angle + " angle, " + value + " value");

  return value;
}


//A* algorithm
// uses the distance traveled and the distance to the heuristic, which is the line from startPos to endPos.
// uses a heuristic coefficient of 1
ArrayList<Integer> runAStar(Vec2[] nodePos, Vec2 startPos, Vec2 goalPos, int numNodes, Vec2[] centers, float[] widths, float[] lengths, int numObstacles){
  boolean[] distVisited = new boolean[maxNumNodes];
  Float foundGoalDistance = 2000.0;
  ArrayList<Integer> foundGoalPath = new ArrayList();
  ArrayList<QueueItem> priorityQueue = new ArrayList();
  ArrayList<QueueItem> usedQueue = new ArrayList();
  int queueIdCount = 0;
  ArrayList<Integer> path = new ArrayList();
  float heuristic_coefficient = 1;
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }
  boolean directHit = false;
  //float segmentLength = startPos.distanceTo(goalPos);
  //Vec2 dir = goalPos.minus(startPos).normalized();
  hitInfo hit = rayRectListIntersect(centers, widths, lengths, numObstacles, startPos, goalPos);
  if(!hit.hit){
    directHit = true;
    println("direct");
  }

  //println("starting");
  // Add every node to the fringe that doesn't have an obstacle in between it and the start
  // calculate distances based on dist to the point and weighted distance to the goal position
  // if there's no direct hit between start and goal pos, search for the path
  if(!directHit){
    for(int i = 0; i < nodePos.length; i++){
      if(nodePos[i] != null){
        //segmentLength = startPos.distanceTo(nodePos[i]);
        //dir = nodePos[i].minus(startPos).normalized();
        hit = rayRectListIntersect(centers, widths, lengths, numObstacles, startPos, nodePos[i]);
        if(!hit.hit){
          //println(i + ", " + nodePos[i] + ", " + heuristic_coefficient * (getHeuristicValue(startPos, goalPos, nodePos[i])));
          QueueItem itemToAdd = new QueueItem(queueIdCount, i, -1, nodePos[i].distanceTo(startPos), nodePos[i].distanceTo(startPos) + heuristic_coefficient * (getHeuristicValue(startPos, goalPos, nodePos[i])));
          priorityQueue.add(itemToAdd);
          queueIdCount++;
        }
      }
    }
    
    
    while (priorityQueue.size() > 0){

      int lowestDistIndex = 0;
      float lowestWeightedDistance = 0.0;
      for(int i = 0; i <  priorityQueue.size(); i++){
        
        if((lowestWeightedDistance > priorityQueue.get(i).weightedDistance || lowestWeightedDistance == 0.0) && !priorityQueue.get(i).visited){
          //println(i + " replaces " + lowestDistIndex + " with " + priorityQueue.get(i).weightedDistance + "<" + lowestWeightedDistance);
          lowestDistIndex = i;
          lowestWeightedDistance = priorityQueue.get(i).weightedDistance;
          
        }
      }
      //println("lowest is " + lowestDistIndex + " with parent " + priorityQueue.get(lowestDistIndex).parentId);

      //distVisited[lowestDistIndex] = true;
      priorityQueue.get(lowestDistIndex).visited = true;
      //println(" Current Fringe: ", priorityQueue);
      // search for the lowestDistIndex in the fringe and pop it off
      QueueItem currentItem = priorityQueue.get(lowestDistIndex);
      usedQueue.add(currentItem);
      priorityQueue.remove(lowestDistIndex);
      
      // check to see if the popped off node can connect to the solution. If so, then solution found
      //segmentLength = goalPos.distanceTo(nodePos[currentItem.nodeId]);
      //dir = goalPos.minus(nodePos[currentItem.nodeId]).normalized();
      hit = rayRectListIntersect(centers, widths, lengths, numObstacles, nodePos[currentItem.nodeId], goalPos);
      if(!hit.hit){
        //lastVisited = currentNode;
        currentItem.distance += nodePos[currentItem.nodeId].distanceTo(goalPos);
        //println("Goal found! " + currentItem.nodeId + ", distance of " + currentItem.distance);
        //break;
        if(currentItem.distance < foundGoalDistance){
          //println("new solution");
          foundGoalDistance = currentItem.distance;
          //println("New path with " +  currentItem.nodeId + ", " + foundGoalDistance);
          foundGoalPath.clear();
          foundGoalPath.add(currentItem.nodeId);
          //println("added " + currentItem.nodeId + " to the goal path");
          // get queueID of parent queue item node
          int prevNode = currentItem.parentId;
          //println("prevnode is " + prevNode);
          while (prevNode >= 0){
             //println(prevNode," ");
             for(int h = 0; h < usedQueue.size(); h++){
               //println("index is  " + usedQueue.get(h).nodeId + " looking for " + prevNode);
               if(prevNode == usedQueue.get(h).id){
                 foundGoalPath.add(usedQueue.get(h).nodeId);
                 //println("added " + usedQueue.get(h).nodeId + " to the goal path with parent " + usedQueue.get(h).parentId);
                 prevNode = usedQueue.get(h).parentId;
                 //println("prevnode is " + prevNode);
                 break;
               }
             }
          }
          //println(foundGoalPath);
         }
         //println(foundGoalPath);
      }
      //println("id " + currentItem.nodeId);
      for (int i = 0; i < neighbors[currentItem.nodeId].size(); i++){
        int neighborNode = neighbors[currentItem.nodeId].get(i);
        // switch to visited with items

        if (!visited[neighborNode]){
          visited[neighborNode] = true;
          distVisited[neighborNode] = true;
          QueueItem itemToAdd = new QueueItem(queueIdCount, neighborNode, currentItem.id, currentItem.distance + nodePos[neighborNode].distanceTo(nodePos[currentItem.nodeId]), currentItem.distance + nodePos[neighborNode].distanceTo(nodePos[currentItem.nodeId]) + heuristic_coefficient * getHeuristicValue(startPos, goalPos, nodePos[neighborNode]));
          queueIdCount++;
          priorityQueue.add(itemToAdd);
          //println("added " + itemToAdd.nodeId);
        }
      }
      if(foundGoalDistance > 0.0){
        for(int i = 0; i < priorityQueue.size(); i++){
          if(priorityQueue.get(i).distance > foundGoalDistance){
            //println("too long removed " + priorityQueue.get(i).nodeId);
            priorityQueue.remove(i);
          }
        }
      }
    }
    
    if(foundGoalPath.size() > 0){
      //println("here");
      for(int i = 0; i < foundGoalPath.size(); i++){
        if(!path.contains(foundGoalPath.get(i))){
          path.add(0, foundGoalPath.get(i));
          //println("goal path added " + foundGoalPath.get(i));
        }
      }
    }else {
      //println("no path");
      path.add(0,-1);
      return path;
    }
    
    
  }
  return path;
}
