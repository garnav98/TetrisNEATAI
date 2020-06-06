class Genome{
  int inputs;
  int outputs;
  int biasNode;
  int layers = 2;
  int nextNode = 0;
  
  ArrayList<NodeGene> nodes = new ArrayList<NodeGene>();
  ArrayList<ConnectionGene> connections = new ArrayList<ConnectionGene>();
  ArrayList<NodeGene> network = new ArrayList<NodeGene>(); 

  Genome(int in, int out){
    inputs = in;
    outputs = out;
    
    int localConnectionNo = 0;
    
    for(int i=0;i<inputs;++i){
      nodes.add(new NodeGene(i));
      nodes.get(i).layer = 0;
      ++nextNode;
    }
    for(int i=0;i<outputs;++i){
      nodes.add(new NodeGene(i+inputs));
      nodes.get(i+inputs).layer = 1;
      ++nextNode;
    }
    nodes.add(new NodeGene(nextNode));
    biasNode = nextNode;
    nodes.get(biasNode).layer = 0;
    ++nextNode;
    
    for(int i=0;i<inputs;++i){
      for(int j=0;j<outputs;++j){
        connections.add(new ConnectionGene(nodes.get(i), nodes.get(inputs+j), random(-1,1), localConnectionNo));
        ++localConnectionNo;
      }
    }
    for(int i=0;i<outputs;++i){
      connections.add(new ConnectionGene(nodes.get(biasNode), nodes.get(inputs+i), 1, localConnectionNo));
      ++localConnectionNo;
    }
  }
  
  Genome(int in, int out, boolean crossover){
    inputs = in;
    outputs = out;
  }
  
  NodeGene getNode(int number){
    for(int i=0;i<nodes.size();++i){
      if(nodes.get(i).number == number){
        return nodes.get(i);
      }
    }
    return null;
  } 
  
  void connect(){
    for(int i=0;i<nodes.size();++i){
      nodes.get(i).outConnections.clear();
    }
    //println("");
    for(int i=0;i<connections.size();++i){
      //println(connections.get(i).from.number+" -> "+connections.get(i).to.number);
      //println(connections.get(i).from.outConnections.size());
      connections.get(i).from.outConnections.add(connections.get(i));
      //println(connections.get(i).from.outConnections.size());
    }
    //println("#################################################################################");
  }  
  
  void mutate(ConnectionHistory connectionHistory){
    float rand1 = random(1);
    if(rand1 < 0.80){
      for(int i=0;i<connections.size();++i){
        connections.get(i).mutateWeight();
      }
    }
    
    float rand2 = random(1);
    if(rand2 < 0.12){
      addConnection(connectionHistory);
    }
    
    float rand3 = random(1);
    if(rand3 < 0.08){
      addNode(connectionHistory);
    }
  }
  
  void addConnection(ConnectionHistory connectionHistory){
    if(fullyConnected()){
      println("Fully Connected");
      return;
    }
    
    int random1 = floor(random(nodes.size()));
    int random2 = floor(random(nodes.size()));
    
    while(nodes.get(random1).layer == nodes.get(random2).layer || nodes.get(random1).isConnected(nodes.get(random2))){
      random1 = floor(random(nodes.size()));
      random2 = floor(random(nodes.size()));
    }
    
    if(nodes.get(random1).layer > nodes.get(random2).layer){
      int tmp = random1;
      random1 = random2;
      random2= tmp;
    }
    
    int currentInnovationNo = connectionHistory.getInnovationNo(nodes.get(random1).number, nodes.get(random2).number);
    connections.add(new ConnectionGene(nodes.get(random1), nodes.get(random2), random(-1,1), currentInnovationNo)); //<>//
    
    connect();
    
    //println("Total No of nodes: "+nodes.size());
    //for(int i=0;i<nodes.size();++i){
    //  println(nodes.get(i).number+" -> ");
    //  for(int j=0;j<nodes.get(i).outConnections.size();++j){
    //    print(nodes.get(i).outConnections.get(j).to.number+" ");
    //  }
    //  println("");
    //}
    
    //println("Total No of connections: "+connections.size());
    //for(int i=0;i<connections.size();++i){
    //    println(connections.get(i).from.number+" - "+connections.get(i).to.number+" :: "+connections.get(i).innovationNo);
    //}
    //println(""); //<>//
  }
  
  void addNode(ConnectionHistory connectionHistory){
    int randomConnection = floor(random(connections.size()));
    while(connections.get(randomConnection).from == nodes.get(biasNode)){
      randomConnection = floor(random(connections.size()));
    }
    connections.get(randomConnection).enabled = false;
    
    int curr = nextNode;
    nodes.add(new NodeGene(curr));
    ++nextNode;
  
    int currentInnovationNo = connectionHistory.getInnovationNo(connections.get(randomConnection).from.number, getNode(curr).number);
    connections.add(new ConnectionGene(connections.get(randomConnection).from, getNode(curr), 1, currentInnovationNo)); //<>//
    
    currentInnovationNo = connectionHistory.getInnovationNo(getNode(curr).number, connections.get(randomConnection).to.number);
    connections.add(new ConnectionGene(getNode(curr), connections.get(randomConnection).to, connections.get(randomConnection).weight,currentInnovationNo)); //<>// //<>//
    
    getNode(curr).layer = connections.get(randomConnection).from.layer + 1;
    
    currentInnovationNo = connectionHistory.getInnovationNo(nodes.get(biasNode).number, getNode(curr).number);
    connections.add(new ConnectionGene(nodes.get(biasNode), getNode(curr), 0, currentInnovationNo)); //<>//
    
    if(getNode(curr).layer == connections.get(randomConnection).to.layer){
      for(int i=0;i<nodes.size()-1;++i){
        if(nodes.get(i).layer >= getNode(curr).layer){
          ++nodes.get(i).layer;
        }
      }
      ++layers;
    }
    connect();
    
    //println("Total No of nodes: "+nodes.size());
    //for(int i=0;i<nodes.size();++i){
    //  println(nodes.get(i).number+" -> ");
    //  for(int j=0;j<nodes.get(i).outConnections.size();++j){
    //    print(nodes.get(i).outConnections.get(j).to.number+" ");
    //  }
    //  println("");
    //}
    
    //println("Total No of connections: "+connections.size());
    //for(int i=0;i<connections.size();++i){
    //    println(connections.get(i).from.number+" - "+connections.get(i).to.number+" :: "+connections.get(i).innovationNo);
    //}
    //println(""); //<>//
  }
  
  void generateNetwork(){
    connect();
    network = new ArrayList<NodeGene>();
  
    for(int i=0;i<layers;++i){
      for(int j=0;j<nodes.size();++j){
        if(nodes.get(j).layer == i){
          network.add(nodes.get(j));
        }
      }
    }
    
  }
  
  float[] feedForward(float[] inputValues){
    for(int i=0;i<nodes.size();++i){
      if(i<inputs){
        nodes.get(i).inputVal = inputValues[i];
      }
      else{
        nodes.get(i).inputVal = 0;
      }
    }
    nodes.get(biasNode).inputVal = 1;
    
    for(int i=0;i<network.size();++i){
      network.get(i).feedForward();
    }
    
    float[] output = new float[outputs];
    for(int i=0;i<outputs;++i){
      output[i] = nodes.get(inputs+i).outputVal;
    }
    
    for(int i=0;i<nodes.size();++i){
      nodes.get(i).inputVal = 0;
    }
    
    return output;
  }
  
  Genome crossover(Genome parent){
    Genome child = new Genome(inputs, outputs, true);
    child.nodes.clear();
    child.connections.clear();
    child.biasNode = biasNode;
    child.nextNode = nextNode;
    child.layers = layers;
    
    ArrayList<ConnectionGene> childGene = new ArrayList<ConnectionGene>();
    ArrayList<Boolean> isEnabled = new ArrayList<Boolean>(); 
    
    for(int i=0;i<connections.size();++i){
      int matchingGene = match(parent, connections.get(i).innovationNo); 
      boolean setEnabled = true;
      if(matchingGene != -1){
        if(!connections.get(i).enabled || !parent.connections.get(matchingGene).enabled){
          if(random(1)<0.75){
            setEnabled = false;
          }
        }
        float rand = random(1);
        if(rand < 0.5){
          childGene.add(connections.get(i));
        }
        else{
          childGene.add(parent.connections.get(matchingGene));
        }
      }
      else{
        childGene.add(connections.get(i));
        setEnabled = connections.get(i).enabled;
      }
      isEnabled.add(setEnabled);
    }
    
    for(int i=0;i<nodes.size();++i){
      child.nodes.add(nodes.get(i).clone());
    }
    for(int i=0;i<childGene.size();++i){
      int fromNode = childGene.get(i).from.number;
      int toNode = childGene.get(i).to.number;
      child.connections.add(childGene.get(i).clone(child.getNode(fromNode), child.getNode(toNode)));
      child.connections.get(i).enabled = isEnabled.get(i);
    }
    child.connect();
    return child;
  }
  
  boolean fullyConnected(){
    long maxConnection = 0;
    int[] nodesInLayers = new int[layers];
    
    for(int i=0;i<layers;++i){
      nodesInLayers[i] = 0;
    }
    for(int i=0;i<nodes.size();++i){
      ++nodesInLayers[nodes.get(i).layer];
    }
    
    for(int i=0;i<layers-1;++i){
      long tmpSum = 0;
      for(int j=i+1;j<layers;++j){
        tmpSum += nodesInLayers[j];
      }
      maxConnection += nodesInLayers[i]*tmpSum;
    }
    
    if(maxConnection == connections.size()) return true;
    else return false;
  }
  
  int match(Genome parent, int innovationNo){
    for(int i=0;i<parent.connections.size();++i){
      if(parent.connections.get(i).innovationNo == innovationNo){
        return i;
      }
    }
    return -1;
  }
        
  Genome clone(){
    Genome clone = new Genome(inputs, outputs, true);
    
    for(int i=0;i<nodes.size();++i){
      clone.nodes.add(nodes.get(i).clone());
    }
    
    for(int i=0;i<connections.size();++i){
      int fromNode = connections.get(i).from.number;
      int toNode = connections.get(i).to.number;
      clone.connections.add(connections.get(i).clone(clone.getNode(fromNode), clone.getNode(toNode)));
    }
    
    clone.biasNode = biasNode;
    clone.nextNode = nextNode;
    clone.layers = layers;
   
    clone.connect();
    return clone;
  }
  
  void drawGenome(){
    ArrayList<ArrayList<NodeGene>> allNodes = new ArrayList<ArrayList<NodeGene>>();
    ArrayList<PVector> nodePoses = new ArrayList<PVector>();
    ArrayList<Integer> nodeNumbers= new ArrayList<Integer>();
    
    for (int i = 0; i< layers; i++) {
      ArrayList<NodeGene> temp = new ArrayList<NodeGene>();
      for (int j = 0; j< nodes.size(); j++) {
        if (nodes.get(j).layer == i ) {
          temp.add(nodes.get(j));
        }
      }
      allNodes.add(temp);
    }

    for (int i = 0; i < layers; i++) {
      float x = (float)((i+1)*540)/(float)(layers+1.0);
      x += 540;
      for (int j = 0; j< allNodes.get(i).size(); j++) {
        float y = ((float)(j + 1.0) * 720)/(float)(allNodes.get(i).size() + 1.0);
        nodePoses.add(new PVector(x, y));
        nodeNumbers.add(allNodes.get(i).get(j).number);
      }
    }
    
    fill(255, 0, 0);
    stroke(0);
    strokeWeight(2);
    for (int i = 0; i< connections.size(); i++) {
      if (connections.get(i).enabled) {
        stroke(255);
      } else {
        stroke(200);
      }
      PVector from;
      PVector to;
      from = nodePoses.get(nodeNumbers.indexOf(connections.get(i).from.number));
      to = nodePoses.get(nodeNumbers.indexOf(connections.get(i).to.number));
      if (connections.get(i).weight > 0) {
        stroke(255, 0, 0);
      } else {
        stroke(0, 0, 255);
      }
      strokeWeight(map(abs(connections.get(i).weight), 0, 1, 0, 5));
      line(from.x, from.y, to.x, to.y);
    }
    
    for (int i = 0; i < nodePoses.size(); i++) {
      fill(255);
      stroke(0);
      strokeWeight(1);
      ellipse(nodePoses.get(i).x, nodePoses.get(i).y, 20, 20);
      textSize(10);
      fill(0);
      textAlign(CENTER, CENTER);

      text(nodeNumbers.get(i), nodePoses.get(i).x, nodePoses.get(i).y);
    }
  }
  
}
