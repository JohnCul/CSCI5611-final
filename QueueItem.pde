
public class QueueItem{
  public int id;
  public int nodeId;
  public int parentId;
  public float distance;
  public float weightedDistance;
  public boolean visited = false;
  
  public QueueItem(int id, int nodeId, int parentId, float dist, float weightedDist){
    this.id = id;
    this.nodeId = nodeId;
    this.parentId = parentId;
    this.distance = dist;
    this.weightedDistance = weightedDist;
  }
  
  public String toString(){
    return "" + this.nodeId;
  }
  
}
