import java.util.Map;

class ConnectionHistory{
  HashMap<ArrayList<Integer>, Integer> connection = new HashMap<ArrayList<Integer>, Integer>();
  
  ConnectionHistory(int input, int output){
    int localInnovationNo = 0;
    for(int i=0;i<input;++i){
      for(int j=0;j<output;++j){
        ArrayList<Integer> tmp = new ArrayList<Integer>();
        tmp.add(i);
        tmp.add(input+j);
        connection.put(tmp, localInnovationNo);
        ++localInnovationNo;
      }
    }
    int biasNode = input+output;
    for(int i=0;i<output;++i){
      ArrayList<Integer> tmp = new ArrayList<Integer>();
      tmp.add(biasNode);
      tmp.add(input+i);
      connection.put(tmp, localInnovationNo);
      ++localInnovationNo;
    }
  }
  
  int getInnovationNo(int fromNode, int toNode){
    int valueToReturn = -1;
    
    ArrayList<Integer> currFind = new ArrayList<Integer>();
    currFind.add(fromNode);
    currFind.add(toNode);
    if(connection.containsKey(currFind)){
      valueToReturn = connection.get(currFind);
    }
    else{
      valueToReturn = globalInnovationNo;
      connection.put(currFind, valueToReturn);
      ++globalInnovationNo;
    }
  
    return valueToReturn;
  }
  
  void show(){
    for (Map.Entry me : connection.entrySet()) {
      print(me.getKey() + " is ");
      println(me.getValue());
    }
    return; 
  }
  
}
