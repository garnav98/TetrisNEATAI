class Field{
  int cols;
  int rows;
  int[][] map;
  
  Field(int r, int c){
    rows = r;
    cols = c;
    map = new int[rows][cols];
    for(int i=0;i<rows;++i){
      for(int j=0;j<cols;++j){
        map[i][j] = 0;
      }
    }
  }
  
  void show(){
    for(int i=0;i<cols;i+=SIZE){
      line(SIZE+i, 4*SIZE, SIZE+i, H+4*SIZE);
    }
    for(int j=4*SIZE;j<rows;j+=SIZE){
      line(SIZE, j, W+SIZE, j);
    }
  }
  
  float[] calcHoles(){
    float[] tmp = new float[(cols/SIZE)];
    for(int j=0;j<cols;j+=SIZE){
      float y=0;
      for(int i=4*SIZE;i<rows;i+=SIZE){
        if(map[i][j] != 0){
          for(int k=i;k<rows;k+=SIZE){
            if(map[k][j] == 0) ++y;
          }
          break;
        }
      }
      tmp[(j/SIZE)]=y;
    }
    //for(int i=0;i<10;++i){
    //  print(tmp[i]+"    ");
    //}
    //println("");
    return tmp;
  }
}
