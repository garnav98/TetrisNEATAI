class Species{
  ArrayList<Player> players = new ArrayList<Player>();
  int stale = 0;
  float bestFitness = 0;
  Genome parameterGenome;
  
  float excessCoeff = 1.5;
  float disjointCoeff = 1.5;
  float weightDiffCoeff = 0.8;
  float compatibilityThreshold = 0.6;
  
  Species(Player p){
    players.add(p);
    bestFitness = p.fitness;
    parameterGenome = p.brain.clone();
  }
  
  void addToSpecies(Player p){
    players.add(p);
  }
  
  boolean sameSpecies(Genome p, ConnectionHistory connectionHistory){
    float compatibility = 0;
    float excess = findExcess(parameterGenome, p);
    float disjoint = findDisjointExcess(parameterGenome, p, connectionHistory) - excess;
    float averageWeightDifference = findAvgWtDiff(parameterGenome, p);
    
    float N = max(p.connections.size()+p.nodes.size(), parameterGenome.connections.size()+parameterGenome.nodes.size());
    if(N < 20){
      N = 1;
    }
    
    compatibility = (excessCoeff*excess/N) + (disjointCoeff*disjoint/N) + (weightDiffCoeff*averageWeightDifference);
    //println("compatibility: "+compatibility+" excess: "+excess+" disjoint: "+disjoint+" averageWeightDifference: "+averageWeightDifference);
    return (compatibility < compatibilityThreshold);
  }
  
  float findExcess(Genome x, Genome y){
    float[] a = new float[x.connections.size()];
    float[] b = new float[y.connections.size()];
    
    for(int i=0;i<x.connections.size();++i){
      a[i] = x.connections.get(i).innovationNo;
    }
    for(int i=0;i<y.connections.size();++i){
      b[i] = y.connections.get(i).innovationNo;
    }
    
    a = sort(a);
    b = sort(b);
    int lena = a.length;
    int lenb = b.length;
    float count = 0;
    
    if(a.length != x.connections.size() || b.length != y.connections.size()){
      println("shits crazy");
    }
    
    if(a[lena-1] == b[lenb-1]){
      return 0;
    }
    if(a[lena-1] < b[lenb-1]){
      for(int i=0;i<lenb;++i){
        if(b[i] > a[lena-1]){
          ++count;
        }
      }
    }else{
      for(int i=0;i<lena;++i){
        if(a[i] > b[lenb-1]){
          ++count;
        }
      }
    }
    return count;
  }
  
  float findDisjointExcess(Genome x, Genome y, ConnectionHistory connectionHistory){
    float matching = 0;
    for(int i=0;i<x.connections.size();++i){
      for(int j=0;j<y.connections.size();++j){
        if(x.connections.get(i).innovationNo == y.connections.get(j).innovationNo){
          ++matching; 
          break;
        }
      }
    }
    
    float curr = x.connections.size() + y.connections.size() - (2*matching) - findExcess(x,y);
    if(curr < 0){
      println(x.connections.size()+" "+y.connections.size()+" "+matching+" disjoint < 0");
      exit();
    }
    return (x.connections.size() + y.connections.size() - (2*matching));
  }
  
  float findAvgWtDiff(Genome x, Genome y){
    float matching = 0;
    float diff = 0;
    for(int i=0;i<x.connections.size();++i){
      for(int j=0;j<y.connections.size();++j){
        if(x.connections.get(i).innovationNo == y.connections.get(j).innovationNo){
          ++matching;
          diff += abs(x.connections.get(i).weight - y.connections.get(j).weight);
        }
      }
    }
    
    if(matching == 0){
      return 100.0;
    }
    else{
      return (diff/matching);
    }
  }
  
  void sortSpecies(){
    ArrayList<Player> tmp = new ArrayList<Player>();
   
    for(int i=0;i<players.size();++i){
      float max = 0;
      int maxIndex = 0; 
      for(int j=0;j<players.size();++j){
        if(players.get(j).fitness > max){
          max = players.get(j).fitness;
          maxIndex = j;
        }
      }
      tmp.add(players.get(maxIndex));
      players.remove(maxIndex);
      --i;
    }
    players = (ArrayList)tmp.clone();
    
    if(players.get(0).fitness > bestFitness) {     
      stale = 0;
      bestFitness = players.get(0).fitness;
      parameterGenome = players.get(0).brain.clone();
    }
    else{
      stale++;
    }
  }
  
  float speciesAverage(){
    float sum = 0;
    for(int i=0;i<players.size();++i){
      sum += players.get(i).fitness;
    }
    return (sum/players.size());
  }
  
  void check(){
    //println("Size: "+players.size());
    //for(int i=0;i<players.size();++i){
    //  println(i+" -> "+players.get(i).fitness+"  "+players.get(i).score+"  "+players.get(i).noOfMoves);
    //}
    //println("Species average: "+speciesAverage());
  }
  
  Player giveBaby(ConnectionHistory connectionHistory, int gen){
    Player baby;
    if(random(1) < 0.25){
      baby = selectParent().clone();
    }
    else{
      Player parent1 = selectParent();
      Player parent2 = selectParent();
      if(parent1.fitness < parent2.fitness){
        baby = parent2.crossover(parent1);
      }
      else{
        baby = parent1.crossover(parent2);
      }
    }
    baby.brain.mutate(connectionHistory);  
    return baby;
  }
  
  Player selectParent(){
    float sum = 0;
    for(int i=0;i<players.size();++i){
      sum += players.get(i).fitness;
    }
    
    float rand = random(sum);
    float runningSum = 0;
    for(int i=0;i<players.size();++i){
      runningSum += players.get(i).fitness;
      if(runningSum > rand){
        return players.get(i);
      }
    }
    return players.get(0);
  }
  
  void cull(){
    if (players.size() > 2) {
      for (int i = players.size()/2; i<players.size(); i++) {
        players.remove(i); 
        i--;
      }
    }
  }
  
  void fitnessSharing(){
    for (int i=0; i<players.size(); i++) {
      players.get(i).fitness/=players.size();
    }
  }
  
}
