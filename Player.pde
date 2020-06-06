class Player{
  int currPiece;
  int currX;                 // subtracted SIZE since only then the block would be in approx. centre
  int currY;
  int currRotation = 0;
  boolean dead = false;
  
  int [] col;
  Field field;
  
  long score = 0;
  int level = 0;
  int linesRemoved = 0;        //setting it to zero at the end of update for some reason, so don't use this for any calculations.
  int totalLinesRemoved = 0;   //this gives the total lines removed, may use it.
  int tetrisFormed = 0;
  int noOfMoves = 0;
  long playerTime = 0;
 
  Genome brain;
  float vision[];
  float decision[];
  float fitness = 0;
  
  Player(){
    currPiece = floor(random(7));
    //currPiece = 0;
    currX = SIZE + W/2 - SIZE;
    currY = 0;
    
    col = new int[3];
    field = new Field(H+4*SIZE, W);
    
    brain = new Genome(input_nodes, output_nodes);
  }
  
  void update(int counter){
    int delay = adjustSpeed();
    if(millis() - playerTime >= delay){
      playerTime = millis();
      if(!collide(currX, currY+SIZE, currRotation)){
        currY += SIZE;
        ++noOfMoves;
      }
      else{
        forceDown();
        checkOver();
        deleteRows();
        createNew();
      }
    }
    if(linesRemoved > 9){
      ++level;
      linesRemoved = 0;
    }
  }
  
  int adjustSpeed(){
    if(level < 2) return 250;
    else if(level < 4) return 200;
    else if(level < 6) return 150;
    else if(level < 8) return 100;
    else return 50;
  }
  
  void show(int counter){
    setColour(currPiece);
    for(int i=0;i<4;++i){
      for(int j=0;j<4;++j){
        if(tetro[currPiece].charAt(rotate(i, j, currRotation)) == 'X'){
          fill(col[0],col[1],col[2]);
          stroke(0);
          rect(currX + i*SIZE, currY + j*SIZE, SIZE, SIZE);
        }
      }
    }
    for(int i=0;i<W;i+=SIZE){
      for(int j=0;j<H+4*SIZE;j+=SIZE){
        if(field.map[j][i] != 0){
          setColour(field.map[j][i]-1);
          fill(col[0],col[1],col[2]);
          stroke(0);
          rect(SIZE + i, j, SIZE, SIZE);
        }
      }
    }
    field.show();
  }
  
  void setColour(int n){
    if(n == 0){
      col[0] = 148;
      col[1] = 0;
      col[2] = 211;
    }
    else if(n == 1){
      col[0] = 75;
      col[1] = 0;
      col[2] = 130;
    }
    else if(n == 2){
      col[0] = 0;
      col[1] = 0;
      col[2] = 255;
    }
    else if(n == 3){
      col[0] = 0;
      col[1] = 255;
      col[2] = 0;
    }
    else if(n == 4){
      col[0] = 255;
      col[1] = 255;
      col[2] = 0;
    }
    else if(n == 5){
      col[0] = 255;
      col[1] = 127;
      col[2] = 0;
    }
    else if(n == 6){
      col[0] = 255;
      col[1] = 0;
      col[2] = 0;
    }
  }
  
  int rotate(int rx, int ry, int rState) {
    switch(rState){
      case 0:
          return ry * 4 + rx;
      case 1:
          return 12 + ry - (rx * 4);
      case 2:
          return 15 - (ry * 4) - rx;
      case 3:
          return 3 - ry + (rx * 4);
    }
    return 0;
  }
  
  boolean collide(int x, int y, int rt){
    for(int i=0;i<4;++i){
      for(int j=0;j<4;++j){
        if(tetro[currPiece].charAt(rotate(i, j, rt)) == 'X'){
          if(x+i*SIZE < SIZE || x+i*SIZE >= W+SIZE || y+j*SIZE>=H+4*SIZE){      //if going outside the borders
            return true;
          }
          if(field.map[y+(j*SIZE)][(x+(i*SIZE)-SIZE)] != 0){                    //if colliding with some other piece
            return true;
          }
        }
      }
    }
    return false;
  }
  
  void forceDown(){
    for(int i=0;i<4;++i){
        for(int j=0;j<4;++j){
          if(tetro[currPiece].charAt(rotate(i, j, currRotation)) == 'X'){
            field.map[currY+(j*SIZE)][(currX+(i*SIZE)-SIZE)] = currPiece+1;
          }
        }
     }
  }
  
  void checkOver(){
    for(int i=0;i<4;++i){
        for(int j=0;j<4;++j){
          if(tetro[currPiece].charAt(rotate(i, j, currRotation)) == 'X'){
            if(currY+(j*SIZE) < 4*SIZE){
              dead = true;
            }
          }
        }
     }
  }
  
  void deleteRows(){
    ArrayList<Integer> lines = new ArrayList<Integer>();
    int tmpRowsDeleted = 0;
     for(int j=0;j<4;++j){
        int currRow = currY + j*SIZE;
        if(currRow >= H+4*SIZE) continue;
        
        boolean completeRow = true;
        for(int i=0;i<W;i+=SIZE){
          if(field.map[currRow][i] == 0){
            completeRow = false;
            break;
          }
        }
        
        if(completeRow == true){
          lines.add(currRow);
          ++linesRemoved;
          ++tmpRowsDeleted;
        }
      }
      for(int iterator=0;iterator<lines.size();++iterator){
        for(int i=0;i<W;i+=SIZE){
          for(int j=lines.get(iterator);j>0;j-=SIZE){
            field.map[j][i] = field.map[j-SIZE][i];
            field.map[j-SIZE][i] = 0;
          }
        }
      }
      addScore(0, tmpRowsDeleted);
      linesRemoved += tmpRowsDeleted;
      totalLinesRemoved += tmpRowsDeleted;
      if(tmpRowsDeleted == 4){
        ++tetrisFormed;
      }
  }
  
  void createNew(){
    currX = SIZE + W/2 - SIZE;
    currY = 0;
    currRotation = 0;
    currPiece = floor(random(7));
    //currPiece = 0;
  }
  
  void addScore(int flag, int noOfLines){
    if(level < 2){
      if(flag == 0){
        score += scoreDistribution[noOfLines];
      }
      else{
        score += noOfLines;
      }
    }
    else if(level < 4){
      if(flag == 0){
        score += scoreDistribution[noOfLines]*2;
      }
      else{
        score += noOfLines*2;
      }
    }
    else if(level < 6){
      if(flag == 0){
        score += scoreDistribution[noOfLines]*3;
      }
      else{
        score += noOfLines*3;
      }
    }
    else if(level < 8){
      if(flag == 0){
        score += scoreDistribution[noOfLines]*4;
      }
      else{
        score += noOfLines*4;
      }
    }
    else{
      if(flag == 0){
        score += scoreDistribution[noOfLines]*5;
      }
      else{
        score += noOfLines*5;
      }
    }
  }
  
  void calculateFitness(){
    if(totalLinesRemoved < 10){
      fitness = pow(2,totalLinesRemoved) * score * noOfMoves;
      if(tetrisFormed > 0){
        fitness *= (tetrisFormed*tetrisFormed);
      }
    }
    else{
      fitness = pow(2,10) * score * noOfMoves;
      fitness *= (totalLinesRemoved - 9);
      if(tetrisFormed > 0){
        fitness *= (tetrisFormed*tetrisFormed);
      }
    }
  }
  
  Player crossover(Player parent2){
    Player baby = new Player();
    baby.brain = brain.crossover(parent2.brain);
    baby.playerTime = playerTime;
    baby.brain.generateNetwork();
    return baby;
  }
  
  Player clone(){
    Player clone = new Player();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.playerTime = playerTime;
    clone.brain.generateNetwork();
    return clone;
  }
  
  void look(){
    vision = new float[input_nodes];
    float[] tmpValues = lookInDirection();
    for(int i=0;i<input_nodes;++i){
      vision[i] = tmpValues[i];
    }
  }
  
  float[] lookInDirection(){
    float[] visionInDirection = new float[31];
    
    //float[] tmpArray = new float[3];
    
    for(int i=0;i<10;++i){
      visionInDirection[i] = 0;
    }
    for(int j=0;j<field.cols;j+=SIZE){
      for(int i=4*SIZE;i<field.rows;i+=SIZE){
        if(field.map[i][j] != 0){
          visionInDirection[j/SIZE] = (H+(4*SIZE)-i)/SIZE;
          break;
        }
      }
    }
    
    float maxHeight = 0;
    for(int i=0;i<9;++i){
      visionInDirection[i+10] = abs(visionInDirection[i+1]-visionInDirection[i]);
      maxHeight = max(maxHeight, visionInDirection[i]);
    }
    
    visionInDirection[19] = max(maxHeight, visionInDirection[9]);
    
    float totalHoles = 0;
    for(int j=0;j<field.cols;j+=SIZE){
      float holesInColumn = 0;
      for(int i=4*SIZE;i<field.rows;i+=SIZE){
        if(field.map[i][j] != 0){
          for(int k=i;k<field.rows;k+=SIZE){
             if(field.map[i][j] == 0){
               ++holesInColumn;
             }
          }
        }
      }
      visionInDirection[(j/SIZE)+20] = holesInColumn;
      totalHoles += holesInColumn;
    }
    
    visionInDirection[30] = totalHoles;
    
    for(int i=0;i<10;++i){              //normalizing values.
      visionInDirection[i] /= 20.0;
    }
    for(int i=10;i<19;++i){
      visionInDirection[i] /= 20.0;      //as taking the absolute difference, hence need only divide by 20.
      //visionInDirection[i] += 1;
      //visionInDirection[i] /= 2.0;
    }
    visionInDirection[19] /= 20.0;
    for(int i=20;i<30;++i){
      visionInDirection[i] /= 19.0;
    }
    visionInDirection[30] /= 171.0;      //max no of holes could be 171.
    
    //tmpArray[0] = visionInDirection[0];
    //tmpArray[1] = visionInDirection[1];
    //tmpArray[2] = visionInDirection[2];
    //return tmpArray;
    return visionInDirection;
  }
  
  void think(){
    decision = brain.feedForward(vision);
    
    float max = 0;
    int maxIndex = 0;
    for(int i=0;i<decision.length;i++){
      if(decision[i] > max){
        max = decision[i];
        maxIndex = i;
      }
    }
    switch(maxIndex){
      case 0:
         moveLeft();
         break;
       case 1:
         moveRight();
         break;
       case 2:
         rotateClock();
         break;
       case 3: 
         rotateAntiClock();
         break;
       case 4: 
         softFall();
         break;
       case 5: 
         hardFall();
         break;
    } 
    ++noOfMoves;
  }
  
  void moveLeft(){
    if(!collide(currX-SIZE, currY, currRotation)){
      currX -= SIZE;
    }
  }
  
  void moveRight(){
    if(!collide(currX+SIZE, currY, currRotation)){
      currX += SIZE;
    }
  }
  
  void rotateClock(){
    int tmpRotation = currRotation + 1;
    if(tmpRotation > 3){
      tmpRotation = 0;
    }
    if(!collide(currX, currY, tmpRotation)){
      currRotation = tmpRotation;
    }
  }
  
  void rotateAntiClock(){
    int tmpRotation = currRotation - 1;
    if(tmpRotation < 0){
      tmpRotation = 3;
    }
    if(!collide(currX, currY, tmpRotation)){
      currRotation = tmpRotation;
    }
  }
  
  void softFall(){
    int linesCovered = 0;
    if(!collide(currX, currY+SIZE, currRotation)){
      currY += SIZE;
      ++linesCovered;
    }
    addScore(1,linesCovered);
  }
  
  void hardFall(){
    int linesCovered = 0;
    while(!collide(currX, currY+SIZE, currRotation)){
      currY += SIZE;
      ++linesCovered;
    }
    addScore(1,linesCovered);
  }
  
  void playerVal(int playerNo, int gen){
    println("Player no: "+playerNo+" || "+" Gen: "+gen);
    println("Total No of nodes: "+brain.nodes.size());
    for(int i=0;i<brain.nodes.size();++i){
      println(brain.nodes.get(i).number+" -> ");
      for(int j=0;j<brain.nodes.get(i).outConnections.size();++j){
        print(brain.nodes.get(i).outConnections.get(j).to.number+" ");
      }
      println("");
    }
    
    println("Total No of connections: "+brain.connections.size());
    for(int i=0;i<brain.connections.size();++i){
        println(brain.connections.get(i).from.number+" - "+brain.connections.get(i).to.number+" :: "+brain.connections.get(i).innovationNo);
    }
    println("####################################################################");
  }
}
