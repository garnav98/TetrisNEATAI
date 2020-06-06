class NodeGene{
  PVector pos = new PVector();
  ArrayList<ConnectionGene> outConnections = new ArrayList<ConnectionGene>();
  int number;
  int layer = 0;
  float inputVal = 0;
  float outputVal = 0;
  
  NodeGene(int no){
    number = no;
  }
  
  float activate(float x){
    float y = 1 / (1 + pow((float)Math.E,-4.9*x));
    return y;
  }
  
  void feedForward(){
    if(layer != 0){
      outputVal = activate(inputVal);
    }
    else{
      outputVal = inputVal;
    }
    for(int i=0;i<outConnections.size();++i){
      if(outConnections.get(i).enabled){
        outConnections.get(i).to.inputVal += outConnections.get(i).weight * outputVal;
      }
    }
  }
  
  boolean isConnected(NodeGene x){
    if(layer == x.layer){
      return false;
    }
    
    if(layer < x.layer){
      for(int i=0;i<outConnections.size();++i){
        if(outConnections.get(i).to == x){
          return true;
        }
      }
    }
    else{
      for(int i=0;i<x.outConnections.size();++i){
        if(x.outConnections.get(i).to == this){
          return true;
        }
      }
    }
    
    return false;
  }
  
  NodeGene clone(){
    NodeGene clone = new NodeGene(number);
    clone.layer = layer;
    return clone;
  }
}
