final int SIZE = 30; 
final int H = 600;
final int W = 300;
final int input_nodes = 32;
final int output_nodes = 6;
int globalInnovationNo = 1000000;
int generation=1;
int currentplayer;

Player player;
Population pop;
String tetro[] = new String[7];

boolean human = false;
boolean holdPressed = false;

long[] scoreDistribution = {0, 100, 400, 900, 2000};

void settings(){
  size(1080,720);
}
void setup(){
  tetro[0]  = "----";
  tetro[0] += "XXXX";
  tetro[0] += "----";
  tetro[0] += "----";
  
  tetro[1]  = "----";
  tetro[1] += "XX--";
  tetro[1] += "-XX-";
  tetro[1] += "----";
  
  tetro[2]  = "----";
  tetro[2] += "-XX-";
  tetro[2] += "XX--";
  tetro[2] += "----";
  
  tetro[3]  = "----";
  tetro[3] += "-XXX";
  tetro[3] += "-X--";
  tetro[3] += "----";
  
  tetro[4]  = "----";
  tetro[4] += "-X--";
  tetro[4] += "-XXX";
  tetro[4] += "----";
  
  tetro[5]  = "----";
  tetro[5] += "-XX-";
  tetro[5] += "-XX-";
  tetro[5] += "----";
  
  tetro[6]  = "--X-";
  tetro[6] += "-XX-";
  tetro[6] += "--X-";
  tetro[6] += "----";
  
  frameRate(150);
  player = new Player();
  pop = new Population(300);
}

void draw(){
  background(0);
  fill(255);
  rect(SIZE, 4*SIZE, W, H);
  stroke(255);
  line(W+2*SIZE,0, W+2*SIZE, H+4*SIZE);
  line(W+8*SIZE, 0, W+8*SIZE,H+4*SIZE);
  if(human){
    player.update(0);
    player.show(0);
    if(player.dead == true){
      player = new Player();
    }
    fill(255);
    textSize(30);
    textAlign(LEFT);
    text("SCORE : "+player.score, 550, 30);
    text("LEVEL : "+player.level, 550, 60);
  }
  else{
    if(pop.allDead() == true){
      pop.naturalSelection();
    }
    else{
      pop.update();
      pop.show();
      pop.pop.get(0).brain.drawGenome();
    } 
    fill(255);
    textSize(18);
    textAlign(LEFT);
    text("GEN : "+pop.gen, 370, 30);
    text("BESTSCORE : "+pop.bestScore, 370, 60);
    text("BESTFITNESS : "+pop.bestFitness, 370, 90);
  }
}

void keyPressed(){
  if(key == CODED) {
     switch(keyCode) {
      case UP:
        if(holdPressed == false){
          player.rotateClock();
          holdPressed = true;
        }
        break;
      case DOWN:
        player.softFall();
        break;  
      case LEFT:
        player.moveLeft();
        break;
      case RIGHT:
        player.moveRight();
        break;
     }
  }
  else{
    if(key == 'z'){
      if(holdPressed == false){
        player.rotateAntiClock();
        holdPressed = true;
      }
    }
    if(key == ' '){
      player.hardFall();
    }
  }
}

void keyReleased(){
  holdPressed = false;
}
