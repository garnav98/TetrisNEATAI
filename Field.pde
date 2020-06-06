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
      line(SIZE+i, 0, SIZE+i, H+4*SIZE);
    }
    for(int j=0;j<rows;j+=SIZE){
      line(SIZE, j+4*SIZE, W+SIZE, j+4*SIZE);
    }
  }
}
