class ConnectionGene{
  NodeGene from;
  NodeGene to;
  float weight = 0;
  int innovationNo;
  boolean enabled = true;
  
  ConnectionGene(NodeGene x, NodeGene y, float wt, int inn){
    from = x;
    to = y;
    weight = wt;
    innovationNo = inn;
  }
  
  void mutateWeight(){
    float rand = random(1);
    if(rand < 0.1){
      weight = random(-1,1);
    }
    else{
      weight += randomGaussian()/5;
      if(weight > 1) weight = 1;
      if(weight < -1) weight = -1;
    }
  }
  
  ConnectionGene clone(NodeGene fromNode, NodeGene toNode){
    ConnectionGene clone = new ConnectionGene(fromNode, toNode, weight, innovationNo);
    clone.enabled = enabled;
    return clone;
  }
}
