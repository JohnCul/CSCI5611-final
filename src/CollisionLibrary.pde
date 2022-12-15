//Compute collision tests. Code from the in-class exercises may be helpful ehre.

//Returns true if the point is inside a circle
//You must consider a point as colliding if it's distance is <= eps
boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps){
  float dist = pointPos.distanceTo(center);
  if (dist < r+eps){ //small safety factor
    return true;
  }
  return false;
}

//Returns true if the point is inside a list of circle
//You must consider a point as colliding if it's distance is <= eps
boolean pointInRectList(Vec2[] points, float[] widths, float[] lengths, int numObstacles, Vec2 pointPos, float eps){
  for (int i = 0; i < numObstacles; i++){
    Vec2 corner =  points[i];
    float w = widths[i];
    float l = lengths[i];
    if (pointInRect(corner,w, l, pointPos, eps)){
      return true;
    }
  }
  return false;
}

boolean pointInRect(Vec2 corner, float w, float l, Vec2 pointPos, float eps){
  if(pointPos.x > corner.x - eps - w/2 && pointPos.x < corner.x + w/2 + eps && pointPos.y > corner.y - eps - l/2 && pointPos.y  < corner.y + l/2 + eps){
    return true;
  }
  return false;
}

//Returns true if the point is inside a list of circle
//You must consider a point as colliding if it's distance is <= eps
boolean pointInCircleList(Vec2[] centers, float[] radii, int numObstacles, Vec2 pointPos, float eps){
  for (int i = 0; i < numObstacles; i++){
    Vec2 center =  centers[i];
    float r = radii[i];
    if (pointInCircle(center,r,pointPos, eps)){
      return true;
    }
  }
  return false;
}


class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

hitInfo rayCircleIntersect(Vec2 center, float r, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  
  //Step 2: Compute W - a displacement vector pointing from the start of the line segment to the center of the circle
    Vec2 toCircle = center.minus(l_start);
    
    //Step 3: Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
    float a = 1;  //Length of l_dir (we normalized it)
    float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
    float c = toCircle.lengthSqr() - (r+strokeWidth)*(r+strokeWidth); //different of squared distances
    
    float d = b*b - 4*a*c; //discriminant 
    
    if (d >=0 ){ 
      //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
      //  ... this means t will be between 0 and the length of the line segment
      float t1 = (-b - sqrt(d))/(2*a); //Optimization: we only need the first collision
      float t2 = (-b + sqrt(d))/(2*a); //Optimization: we only need the first collision
      //println(hit.t,t1,t2);
      if (t1 > 0 && t1 < max_t){
        hit.hit = true;
        hit.t = t1;
      }
      else if (t1 < 0 && t2 > 0){
        hit.hit = true;
        hit.t = -1;
      }
      
    }
    
  return hit;
}

hitInfo rayCircleListIntersect(Vec2[] centers, float[] radii, int numObstacles, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  hit.t = max_t;
  for (int i = 0; i < numObstacles; i++){
    Vec2 center = centers[i];
    float r = radii[i];
    
    hitInfo circleHit = rayCircleIntersect(center, r, l_start, l_dir, hit.t);
    if (circleHit.t > 0 && circleHit.t < hit.t){
      hit.hit = true;
      hit.t = circleHit.t;
    }
    else if (circleHit.hit && circleHit.t < 0){
      hit.hit = true;
      hit.t = -1;
    }
  }
  return hit;
}

hitInfo rayRectListIntersect(Vec2[] centers, float[] widths, float[] lengths, int numObstacles, Vec2 l_start, Vec2 l_end){
  hitInfo hit = new hitInfo();
  hit.t = l_start.distanceTo(l_end);
  for (int i = 0; i < numObstacles; i++){
    Vec2 center = centers[i];
    float w = widths[i];
    float l = lengths[i];
    
    hitInfo rectHit = rayRectIntersect(center, w, l, l_start, l_end);
    //println(rectHit.hit);
    if (rectHit.hit){
      hit.hit = true;
    }
  }
  return hit;
}



// fourCorners: 0 = BL, 1 = TL, 2 = TR, 3 = BR
// need to check 0-1, 1-2, 2-3, 3-0
hitInfo rayCarListIntersect(Vec2[] centers, float[] widths, float[] lengths, float[] rotations, boolean[] visibility, Vec2[] fourCorners, int carInd){
  hitInfo hit = new hitInfo();
  for (int i = 0; i < centers.length; i++){
    if(i != carInd && visibility[i]){
      Vec2 center = centers[i];
      float w = widths[i];
      float l = lengths[i];
      float rotation = rotations[i];
      
      hitInfo rectHit = rayCarIntersect(center, w, l, rotation, fourCorners[0], fourCorners[1]);
      //println(rectHit.hit);
      if (rectHit.hit){
        hit.hit = true;
        hit.t = i;
        return hit;
      }
      rectHit = rayCarIntersect(center, w, l, rotation, fourCorners[1], fourCorners[2]);
      //println(rectHit.hit);
      if (rectHit.hit){
        hit.hit = true;
        hit.t = i;
        return hit;
      }
      rectHit = rayCarIntersect(center, w, l, rotation, fourCorners[2], fourCorners[3]);
      //println(rectHit.hit);
      if (rectHit.hit){
        hit.hit = true;
        hit.t = i;
        return hit;
      }
      rectHit = rayCarIntersect(center, w, l, rotation, fourCorners[3], fourCorners[0]);
      //println(rectHit.hit);
      if (rectHit.hit){
        hit.hit = true;
        hit.t = i;
        return hit;
      }
    }
  }
  return hit;
}


hitInfo rayCarIntersect(Vec2 corner, float w, float l, float rotation, Vec2 l_start, Vec2 l_end){
  hitInfo hit = new hitInfo();
  boolean isHit = LineIntersectsRect(l_start, l_end, corner, w, l, PI - (rotation * PI / 180));
  hit.hit = isHit;
  
  return hit;
}


hitInfo rayRectIntersect(Vec2 corner, float w, float l, Vec2 l_start, Vec2 l_end){
  hitInfo hit = new hitInfo();
  boolean isHit = LineIntersectsRect(l_start,l_end, corner, w, l, 0);
  hit.hit = isHit;
  
  return hit;
}


public boolean LineIntersectsRect(Vec2 p1, Vec2 p2, Vec2 r, float w, float h, float rotation){
  float e = 0;
  return LineIntersectsLine(p1, p2, new Vec2(r.x - w/2 * cos(rotation) + h/2 * sin(rotation) - e, r.y - h/2 * cos(rotation) - w/2 * sin(rotation) - e), new Vec2(r.x + w/2 * cos(rotation) + h/2 * sin(rotation) + e, r.y - h/2 * cos(rotation) + w / 2 * sin(rotation) - e)) ||
         LineIntersectsLine(p1, p2, new Vec2(r.x + w/2 * cos(rotation) + h/2 * sin(rotation) + e, r.y - h/2 * cos(rotation) + w / 2 * sin(rotation) - e), new Vec2(r.x + w/2 * cos(rotation) - h/2 * sin(rotation) + e, r.y + h/2 * cos(rotation) - w/2 * sin(rotation) + e)) ||
         LineIntersectsLine(p1, p2, new Vec2(r.x + w/2 * cos(rotation) - h/2 * sin(rotation) + e, r.y + h/2 * cos(rotation) - w/2 * sin(rotation) + e), new Vec2(r.x - w/2 * cos(rotation) + h/2 * sin(rotation) - e, r.y + h/2 * cos(rotation) - w/2 * sin(rotation)+ e)) ||
         LineIntersectsLine(p1, p2, new Vec2(r.x - w/2 * cos(rotation) + h/2 * sin(rotation) - e, r.y + h/2 * cos(rotation) - w/2 * sin(rotation)+ e), new Vec2(r.x - w/2 * cos(rotation) + h/2 * sin(rotation) - e, r.y - h/2 * cos(rotation) - w/2 * sin(rotation) - e));
}

public boolean LineIntersectsLine(Vec2 l1p1, Vec2 l1p2, Vec2 l2p1, Vec2 l2p2){
    float q = (l1p1.y - l2p1.y) * (l2p2.x - l2p1.x) - (l1p1.x - l2p1.x) * (l2p2.y - l2p1.y);
    float d = (l1p2.x - l1p1.x) * (l2p2.y - l2p1.y) - (l1p2.y - l1p1.y) * (l2p2.x - l2p1.x);

    if( d == 0 )
    {
        return false;
    }

    float r = q / d;

    q = (l1p1.y - l2p1.y) * (l1p2.x - l1p1.x) - (l1p1.x - l2p1.x) * (l1p2.y - l1p1.y);
    float s = q / d;

    if( r < 0 || r > 1 || s < 0 || s > 1 )
    {
        return false;
    }

    return true;
}


// fourCorners: 0 = BL, 1 = TL, 2 = TR, 3 = BR
// need to check 0-1, 1-2, 2-3, 3-0
hitInfo rayCarObstacleListIntersect(Vec2[] centers, float[] widths, float[] lengths, float[] rotations, boolean[] visibility, Vec2[] fourCorners, int carInd){
  hitInfo hit = new hitInfo();
  for (int i = 0; i < centers.length; i++){
    if(i != carInd && visibility[i]){
      Vec2 center = centers[i];
      float w = widths[i];
      float l = lengths[i];
      
      
      boolean rectHit = pointInRect(center, w, l, fourCorners[0], 0.0);
      //println(rectHit.hit);
      if (rectHit){
        hit.hit = true;
        hit.t = 0;
        return hit;
      }
      rectHit = pointInRect(center, w, l, fourCorners[1], 0.0);
      //println(rectHit.hit);
      if (rectHit){
        hit.hit = true;
        hit.t = 1;
        return hit;
      }
      rectHit = pointInRect(center, w, l, fourCorners[2], 0.0);
      //println(rectHit.hit);
      if (rectHit){
        hit.hit = true;
        hit.t = 2;
        return hit;
      }
      rectHit = pointInRect(center, w, l, fourCorners[3], 0.0);
      //println(rectHit.hit);
      if (rectHit){
        hit.hit = true;
        hit.t = 3;
        return hit;
      }
    }
  }
  return hit;
}
