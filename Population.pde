class Population{
  ArrayList<Player> pop = new ArrayList<Player>();
  Player bestPlayer;
  int gen = 1;
  int counter = 0;
  long bestScore = 0;
  float bestFitness = 0;
  float[] avgFitness;
  
  ConnectionHistory connectionHistory = new ConnectionHistory(input_nodes, output_nodes);
  ArrayList<Species> species = new ArrayList<Species>();
  
  Population(int size){
    for(int i=0;i<size;++i){
      pop.add(new Player());
      pop.get(i).brain.generateNetwork();
    }
    avgFitness = new float[size];
    for(int i=0;i<size;++i){
      avgFitness[i] = 0;
    }
  }
  
  void update(){
    for(int i=0;i<pop.size();++i){
      if(pop.get(i).dead == false){
        //println("pop.number "+i+" "+counter);
        //++counter;
        pop.get(i).look();
        pop.get(i).think();
        pop.get(i).update(i);
      }
    }
  }
  
  void show(){
    if(pop.get(0).dead == false){
      pop.get(0).show(1);
    }
    //for(int i=0;i<pop.size();++i){
    //  if(pop.get(i).dead == false){
    //    pop.get(i).show(i);
    //  }
    //}
  }
  
  boolean allDead(){
    for(int i=0;i<pop.size();++i){
      if(pop.get(i).dead == false){
        return false;
      }
    }
    return true;
  }
  
  void setBestPlayer(){
    
  }
  
  void naturalSelection(){
    speciate();
    calculateFitness();
    sortSpecies();
    cullSpecies();
    fitnessSharing();
    killStaleSpecies();
    killBadSpecies();
    setBestPlayer();
    
    if(bestFitness < species.get(0).players.get(0).fitness){
      bestFitness = (species.get(0).players.get(0).fitness)*(species.get(0).players.size());
    }
    if(bestScore < species.get(0).players.get(0).score){
      bestScore = species.get(0).players.get(0).score;
    }
    
    float avgSpeciesSum = calcSpeciesAvgSum();
    ArrayList<Player> nextGen = new ArrayList<Player>();
    for(int i=0;i<species.size();++i){
      nextGen.add(species.get(i).players.get(0).clone());
      int speciesPop = floor(species.get(i).speciesAverage()/avgSpeciesSum * pop.size()) - 1;
      for(int j=0;j<speciesPop;++j){
        nextGen.add(species.get(i).giveBaby(connectionHistory,gen));
      }
    }
    
    while(nextGen.size() < pop.size()){
      nextGen.add(species.get(0).giveBaby(connectionHistory,gen));
    }
    
    pop.clear();
    pop = (ArrayList)nextGen.clone();
   
    for(int i=0;i<pop.size();++i){
      pop.get(i).brain.generateNetwork();
    }
    
    printInfo();
    ++gen;
    generation = gen;
  }
  
  void speciate(){
    for(int i=0;i<species.size();++i){
      species.get(i).players.clear();
    }
   
    for(int i=0;i<pop.size();++i){
      boolean foundSpecies = false;
      for(int j=0;j<species.size();++j){
        if(species.get(j).sameSpecies(pop.get(i).brain, connectionHistory)){
          species.get(j).addToSpecies(pop.get(i));
          foundSpecies = true;
          break;
        }
      }
      if(foundSpecies == false){
        species.add(new Species(pop.get(i)));
      }
    }
    
    for(int i=0;i<species.size();++i){
      if(species.get(i).players.size() == 0){
        species.remove(i);
        --i;
      }
    }
  }
  
  void calculateFitness(){
    for(int i=0;i<pop.size();++i){
      pop.get(i).calculateFitness();
    }
  }
  
  void sortSpecies(){
    for(int i=0;i<species.size();++i){
      species.get(i).sortSpecies();
    }
    
    ArrayList<Species> tmp = new ArrayList<Species>();
    for(int i=0;i<species.size();++i){
      float max = 0;
      int maxIndex = 0; 
      for(int j=0;j<species.size();++j){
        if(species.get(j).bestFitness > max){
          max = species.get(j).bestFitness;
          maxIndex = j;
        }
      }
      
      tmp.add(species.get(maxIndex));
      species.remove(maxIndex);
      --i;
    }
    species = (ArrayList)tmp.clone();
  }
  
  void cullSpecies(){
    for(int i=0;i<species.size();++i){
      species.get(i).cull();
    }
  }
  
  void fitnessSharing(){
    for(int i=0;i<species.size();++i){
      species.get(i).fitnessSharing();
    }
  }
  
  void killStaleSpecies(){
    for(int i=1;i<species.size();++i){      //starting from 1 because if all the species are stale, we want atleast 1 to remain.
      if(species.get(i).stale >= 10){
        species.remove(i);
        --i;
      }
    }
  }
  
  void killBadSpecies(){
    float sum = calcSpeciesAvgSum();
    
    for(int i=1;i<species.size();++i){
      if(species.get(i).speciesAverage()/sum * pop.size() < 1.0){
        species.remove(i);
        --i;
      }
    }
  }
  
  float calcSpeciesAvgSum(){
    float sum = 0;
    for(int i=0;i<species.size();++i){
      sum += species.get(i).speciesAverage();
    }
    return sum;
  }
  
  void printInfo(){
    println("Gen: "+gen);
    println("Species: "+species.size());
    print("Size of species: ");
    for(int i=0;i<species.size();++i){
      print(species.get(i).players.size()+" ");
    }
    println(" ");
    
  }
  
  void gap(){
    println("#################################################################################");
    println("#################################################################################");
    println("#################################################################################");
    println("#################################################################################");
    println("#################################################################################");
  }
}
