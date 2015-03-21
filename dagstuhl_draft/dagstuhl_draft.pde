//Player Input Panel
CodeButton[][] code;
//Current Inspector Model Panel
CodeButton[][] suspected_code;
//Current Smuggler Model Panel
CodeButton[][] smuggler_code;

//Conveyor Belt
SceneryCrate crate_for_player = null;        int wait_player;
SceneryCrate crate_for_inspector = null;     int wait_inspector;
SceneryCrate crate_for_smuggler = null;      int wait_smuggler;
boolean crates_should_move = true;
int score = 0;

//Inspector Memory
MiniTag[] inspector_minitag;
MiniTag[] smuggler_minitag;
ArrayList<Code> inspector_code_memory;
ArrayList<Code> smuggler_code_memory;
int tableSize = 12;
int buttonWidth = 200/tableSize;

//Assets - images, fonts, etc.
PFont font;
PImage img_crate;
PImage img_smuggler;
PImage img_inspector;
PImage bubble_question, bubble_tick, bubble_exclamation; 

//Game state stuff
boolean b_waitingForPlayerToSendCode = true;
int inspector_mental_state = -1;
int inspectorMemorySize = 8;
int smugglerMemorySize = 4;
int minitagwidth = 4; // CHANGE ME TO ACCOMMODATE TABLE SIZE

// tableSize & minitagwidth
// 4 & 12
// 8 & 6
// 12 & 3.5

//Scenery silliness
ArrayList<SceneryCrate> scenery_crates = new ArrayList<SceneryCrate>();
int inspector_frame = 0;
int inspector_frame_dx = 0;
PImage[] anim_inspector;
int nextFrame = 100; int animRate = 100; int lastMillis = 0;
int nextBlinkTime = 2000 + int(random(3000));
int inspector_mental_reset_timer = 0;

int buttonScale = 200 / tableSize;

void setup(){
    randomSeed(0);
  
    size(300*3, 450);
    background(153);
    img_crate = loadImage("crate.png");
    img_inspector = loadImage("inspector.png");
    img_smuggler = loadImage("smuggler.png");
    bubble_question = loadImage("bubble_question.png");
    bubble_tick = loadImage("bubble_tick.png");
    bubble_exclamation = loadImage("bubble_exclamation.png");
    
    anim_inspector = new PImage[7];
    for(int i=1; i<8; i++){
        anim_inspector[i-1] = loadImage("inspector"+i+".png");
    }
  
    stroke(0);
    //Create a 3x3 table of buttons to encode a message in
    code = new CodeButton[tableSize][tableSize];
    for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
          code[i][j] = new CodeButton(50+i*buttonScale, 
          50+j*buttonScale, 
          buttonScale, buttonScale, true);
       } 
    }
    
    wait_player = 50+(tableSize*buttonScale)/2 - 12;
    
    //Create a 3x3 table of (uneditable) buttons to show what the current suspected code is
    suspected_code = new CodeButton[tableSize][tableSize];
    for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
          suspected_code[i][j] = new CodeButton(350+(i*buttonScale), 
          50+j*buttonScale, 
          buttonScale, buttonScale, false);
       } 
    }
    
    wait_inspector = 350+(tableSize*buttonScale)/2 - 12;
    
    //Create a 3x3 table of (uneditable) buttons to show what the current suspected code is
    smuggler_code = new CodeButton[tableSize][tableSize];
    for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
          smuggler_code[i][j] = new CodeButton(650+(i*buttonScale), 
          50+j*buttonScale, 
          buttonScale, buttonScale, false);
       } 
    }
    
    wait_smuggler = 650+(tableSize*buttonScale)/2 - 12;

    //Set up the minitag index with empties
    inspector_minitag = new MiniTag[tableSize];
    smuggler_minitag = new MiniTag[tableSize];
    smuggler_code_memory = new ArrayList<Code>();
    inspector_code_memory = new ArrayList<Code>();
    
    int[][] empty = new int[tableSize][tableSize];
    for (int row=0; row<tableSize; row++) {
     for (int col=0; col<tableSize; col++) {
       empty[row][col] = 2;
     } 
    }
    for(int i=0; i<inspectorMemorySize; i++){
      inspector_minitag[i] = new MiniTag(empty, 350+tableSize*buttonScale+(buttonScale/5), 50+i*(buttonScale*3/2), minitagwidth/2);
    }
    for(int i=0; i<inspectorMemorySize; i++){
      smuggler_minitag[i] = new MiniTag(empty, 650+tableSize*buttonScale+(buttonScale/5), 50+i*(buttonScale*3/2), minitagwidth/2);
    }

    font = createFont("font.ttf", 32);
    textFont(font);
    textAlign(CENTER, TOP);
}

void sendCode(){
   
    /* First, we create an encoding of the CodeButton matrix
     * into the Code class which allows for our 'intelligence'
     * to try and learn from the behaviour.
     **/
    Integer[] parsedCode = new Integer[tableSize*tableSize];
    int parsedCodeIndex = 0;
    
    for(int i=0; i<tableSize; i++){
      for(int j=0;j<tableSize;j++){
        parsedCode[parsedCodeIndex++] = code[i][j].toInteger();    
      }
    }
  
    Code encoded = new Code(parsedCode);

   //b_waitingForPlayerToSendCode = false; 
   
   crate_for_player.attachEncoding(encoded);
   crate_for_player.attachTag(code);
   crate_for_player.setWaypoint(wait_inspector);
   crate_for_inspector = crate_for_player;
   crate_for_player = null;
}

void addCodeToInspectorMemory(SceneryCrate sc){
     MiniTag m = sc.m.copy();
    inspector_minitag[0].tween_target_y = -32;
    for(int i=0; i<inspectorMemorySize-1; i++){
       inspector_minitag[i+1].tween_target_y = inspector_minitag[i].y;
       inspector_minitag[i] = inspector_minitag[i+1];
    }
    inspector_minitag[inspectorMemorySize-1] = m;
    inspector_minitag[inspectorMemorySize-1].tween_target_y = inspector_minitag[inspectorMemorySize-2].y;
    inspector_minitag[inspectorMemorySize-1].x = inspector_minitag[inspectorMemorySize-2].x;  
    inspector_code_memory.add(sc.getEncoding());
    
    if (inspector_code_memory.size() > inspectorMemorySize) {
      inspector_code_memory.remove(0);
    }
}

void addCodeToSmugglerMemory(SceneryCrate sc){
     MiniTag m = sc.m.copy();
    smuggler_minitag[0].tween_target_y = -32;
    for(int i=0; i<smugglerMemorySize-1; i++){
       smuggler_minitag[i+1].tween_target_y = inspector_minitag[i].y;
       smuggler_minitag[i] = smuggler_minitag[i+1];
    }
    smuggler_minitag[smugglerMemorySize-1] = m;
    smuggler_minitag[smugglerMemorySize-1].tween_target_y = smuggler_minitag[smugglerMemorySize-2].y;
    smuggler_minitag[smugglerMemorySize-1].x = smuggler_minitag[smugglerMemorySize-2].x;  
    
    Code encoding = sc.getEncoding();
//    for(int i=0; i<smugglerMemorySize-1; i++){
//       smuggler_code_memory[i] = smuggler_code_memory[i+1];
//    }

    smuggler_code_memory.add(encoding);
    if (smuggler_code_memory.size() > smugglerMemorySize) {
      smuggler_code_memory.remove(0);
    }
//    smuggler_code_memory[smugglerMemorySize-1] = encoding;
    
}


void keyPressed(){
   if(crates_should_move && crate_for_inspector == null && key == ' ' && b_waitingForPlayerToSendCode){
      sendCode();
   } 
   if(key == 'q'){
      blink();
   }
}



void draw(){
   background(100);
   stroke(0);
   fill(0);
   
   //VIEW: Reset the speech bubble after a time period 
   if(inspector_mental_reset_timer != 0 && millis() > inspector_mental_reset_timer){
     inspector_mental_reset_timer = 0;
      inspector_mental_state = -1; 
   }
   
   //Draw all the things!
   for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
         CodeButton cb = code[i][j];
         fill(cb.c);
         rect(cb.x, cb.y, cb.w, cb.h);
         
         cb = suspected_code[i][j];
         fill(cb.c);
         rect(cb.x, cb.y, cb.w, cb.h);
         
         cb = smuggler_code[i][j];
         fill(cb.c);
         rect(cb.x, cb.y, cb.w, cb.h);
      } 
    }
    
    //Draw the inspector
    if(inspector_mental_state > -1){
       switch(inspector_mental_state){
          case 0:
            image(bubble_question, 900/2+16, height-72-40);
            break;
          case 1:
            image(bubble_tick, 900/2+16, height-72-40);
            break;
          case 2:
            image(bubble_exclamation, 900/2+16, height-72-40);
            break;
       } 
    }

    //image(anim_inspector[inspector_frame], 900/2 - 32, height-64);
    image(img_inspector, 900/2-24, height-72);
    //Draw the smuggler
    image(img_smuggler, 600+150-24, height-72);
    //The crates
    for(SceneryCrate sc : scenery_crates){
        sc.update(); 
    }
    //Minitags in the inspector memory
    for(int i=0; i<inspectorMemorySize; i++){
       inspector_minitag[i].draw(); 
    }
    for(int i=0; i<smugglerMemorySize; i++){
       smuggler_minitag[i].draw(); 
    }
    //Some text
    fill(0,0,0);
    text("Current Code", 50 + tableSize*(buttonScale/2), 15);
    text("Suspected Code", 350 + tableSize*(buttonScale/2), 15);
    text("Smuggler's Code", 650 + tableSize*(buttonScale/2), 15);
    text(score+" Packages", 750, 265);
    text("Press SPACE to transmit", 280, 265);
    rect(0, height-2, width, 2);
    
   //Update all the game logics!
   if(crate_for_player == null){
      //Player has no crate, so send one along.
      SceneryCrate sc = new SceneryCrate(-10, height-32);
      scenery_crates.add(sc);
      sc.setWaypoint(wait_player);
      crate_for_player = sc;
   }
   
   Code dummyCode = new Code(new Integer[0]);
   Code inspector_model = dummyCode.learnCode(inspector_code_memory); // generalize
   Code smuggler_model = dummyCode.learnCode(smuggler_code_memory); // generalize
   
   updateCode(inspector_model, suspected_code);
   updateCode(smuggler_model, smuggler_code);
   
   // INSPECTOR CHECKING
   if(crate_for_inspector != null && 
       crate_for_inspector.x == crate_for_inspector.waypoint && crates_should_move){
       //The inspector crate is waiting
       crates_should_move = false;
       
       boolean doInspect = false;
       
       if (inspector_model != null &&
           inspector_model.matchCode(crate_for_inspector.getEncoding())) {
            
           //Show an exclamation
           inspector_mental_state = 2;
           print("inspector matched!");
           println(inspector_model.code);
           doInspect = true;
       } else if (int(random(2)) == 0) {
         
         //Show an exclamation
         inspector_mental_state = 0;
         println("inspector randomly checks");
         doInspect = true;
       }
       
       if (doInspect) {
         println("doing inspection...adding to memory");
         addCodeToInspectorMemory(crate_for_inspector);
         
         crate_for_inspector.setYWaypoint(height+32);
         crate_for_inspector = null;
         crates_should_move = true;
         
         Code generalModel = dummyCode.learnCode(inspector_code_memory);
         if (generalModel.totalCode()) {
            println("inspector suspects everything...game over!"); 
         }
       }
       else{
         //Show a tick
         inspector_mental_state = 1;
         
         crates_should_move = true;
         crate_for_inspector.setWaypoint(wait_smuggler);
         crate_for_smuggler = crate_for_inspector;
         crate_for_inspector = null;
       }
       
       inspector_mental_reset_timer = millis()+3000;
   }
   
   // SMUGGLER CHECKING
   if(crate_for_smuggler != null &&
     crate_for_smuggler.x == crate_for_smuggler.waypoint && crates_should_move){
     crates_should_move = false;
     
     println("smuggler memory size: " + smuggler_code_memory.size());
     if (smuggler_model != null) {
       String outStr = "";
        for (int i=0; i<smuggler_model.code.length; i++) {
          outStr += smuggler_model.code[i] + ",";
        }
       println("smuggler model: " + outStr);
     }
     if (smuggler_model != null && 
         smuggler_model.matchCode(crate_for_smuggler.getEncoding())) {
             println("smuggler matched crate and scores!");
             score += 1;
     } else {
       println("smuggler fails!");
     }
     
     println("smuggler learns!");
     addCodeToSmugglerMemory(crate_for_smuggler);
     //Again, for now let's unpause immediately and process it
     crates_should_move = true; 
     crate_for_smuggler.setWaypoint(width+64);
     crate_for_smuggler = null;
     
     println("current score: " + score);
   }
   //Animation [IGNORE]
   nextBlinkTime -= (millis() - lastMillis);
   if(nextBlinkTime < 0){
     blink();
     nextBlinkTime = 3000 + int(random(5000)); 
   }
   if(inspector_frame_dx != 0){
     nextFrame -= (millis() - lastMillis);
     if(nextFrame < 0){
       nextFrame = animRate;
       if(inspector_frame_dx == -1){
           if(inspector_frame > 0)
              inspector_frame--;
           else
              inspector_frame_dx = 0; 
       }
       else if(inspector_frame_dx == 1){
           if(inspector_frame < 6)
              inspector_frame++;
           else
              inspector_frame_dx = 0;
       }
     }
   }
   lastMillis = millis();
   
   //END ANIMATION
   
}

void updateCode(Code code, CodeButton table[][]) {

  for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
         CodeButton cb = table[i][j];
         Integer val = (code == null)?null:code.code[i*tableSize+j];
         if (val == null) {
           cb.state = 2; 
         } else {
           cb.state = val;
         }
         cb.updateColor();
      } 
    } 
}

void mousePressed(){
  for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
         CodeButton cb = code[i][j];
         if(cb.isMouseOver()){
             cb.state = (cb.state+1)%2;
             cb.updateColor();
         }
      } 
    }

}

class SceneryCrate{
   int x, y;
   int speed = 2;
   int waypoint = -1;
   int y_waypoint = -1;
   MiniTag m = null;
   Code encoding = null;
  
  SceneryCrate(int _x, int _y){
     x = _x; y = _y;
  } 
  
  void setWaypoint(int x){
     waypoint = x; 
  }
  
   void setYWaypoint(int y){
     y_waypoint = y; 
  }
  
  void attachTag(CodeButton[][] code){
    int[][] code_as_ints = new int[code.length][code[0].length]; 
     for(int i=0; i<code.length; i++){
        for(int j=0; j<code[0].length; j++){
            code_as_ints[i][j] = code[i][j].state;
        }
     } 
     m = new MiniTag(code_as_ints, x, y, minitagwidth/2);
  }
  
  void attachEncoding(Code encoding){
    this.encoding = encoding;
  }
  
  public Code getEncoding(){
    return encoding;
  } 
  
  
  void update(){
    if(crates_should_move){
      if(waypoint >= 0){
       if(x >= waypoint){
          x = waypoint;
       }
       else{
         x += speed;
       }
      }
      if(y_waypoint >= 0){
       if(y >= waypoint){
          y = waypoint;
       }
       else{
         y += speed;
       }
      }
    }
     
     image(img_crate, x, y);
     //draw the tag
     if(m != null){
       m.x = x; m.y = y;
        m.draw(); 
     }
  }
}

/*
 *  Minitags are used to indicate codes that have been sent through the conveyor.
 *  They're little UI things, basically.
 */
class MiniTag{
    int[][] array;
    int x;
    int y; int tween_target_y;
    int w;
    int speed = 5;
    
    int border = 1;
  
   MiniTag(int[][] _array, int _x, int _y, int _w){
     array = _array;
     x = _x; y = _y; tween_target_y = _y;
     w = _w;
   }
   
   MiniTag copy(){
      return new MiniTag(array, x, y, w); 
   }
   
   void draw(){
     fill(0); stroke(0);
     rect(x, y, w*array.length+border+border, w*array[0].length+border+border);
     for(int i=0; i<array.length; i++){
        for(int j=0; j<array[i].length; j++){
          if(array[i][j] == 0){
            fill(255);
            stroke(255);
          }
          else if(array[i][j] == 1){
            stroke(0);
            fill(0);
          }
          else if(array[i][j] == 2){
              stroke(128);
              fill(128); 
          }
          rect(border + x + i*w, border + y + j*w, w, w);
        } 
     }
     
//     //DEBUG BECAUSE FUCK TWEENING AT 10.30PM
//     if(tween_target_y != y){
//        y = tween_target_y;
//       return; 
//     }
     
     if(tween_target_y < y){
        y -= speed; 
     }
     else if(tween_target_y > y){
        y += speed; 
     }
     if(tween_target_y != y && Math.abs(tween_target_y-y) < speed){
        y = tween_target_y; 
     }
   }
}

//This is a button that changes colour when you click it
class CodeButton{
    float x, y, w, h;
    
    int state = 0;
    color c;
    color c_on = color(0);
    color c_unknown = color(128);
    color c_off = color(255);
    
    boolean editable = true;
    
    CodeButton(float _x, float _y, float _w, float _h, boolean _editable){
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        
        editable = _editable;
        
        c = c_off;
    }
    
    void clear(){
       state = 0;
       updateColor(); 
    }
    
    void updateColor(){
 
       switch(state){
          case 0: c = c_off; break;
          case 1: c = c_on; break;
          case 2: c = c_unknown; break;
       } 
    }
    
    boolean isMouseOver(){
        if (mouseX >= x && mouseX <= x+w && 
            mouseY >= y && mouseY <= y+h) {
          return true;
        } else {
          return false;
        }
    }
    
    Integer toInteger() {
      return new Integer(state);
    }
}

class Code {
  public Integer[] code;
  public int len;

  public Code(Integer[] code) {
    int clen = code.length;
    this.code = new Integer[clen];
    for (int i=0; i<clen; i++) {
      this.code[i] = code[i];
    }
    this.len = code.length;
  }

  public boolean matchCode(Code target) {
    int ncol = target.len;
    if (ncol != this.len) {
      throw new java.lang.IllegalArgumentException();
    }
    for (int c=0; c<ncol; c++) {
      if (this.code[c] != null &&
        !this.code[c].equals(target.code[c])) {
        return false;
      }
    }

    return true;
  }

  Code learnCode(ArrayList<Code> inputCodes) {
    if (inputCodes.size() < 1) {
      return null;
    }
    //  Integer[] learnCode(List[Integer] inputCodes[][]) {
    int totalCodes = inputCodes.size();
    int codeLength = inputCodes.get(0).len;

    Integer code = null;
    //  Integer lastLearned = null;

    Integer[] learnedCode = new Integer[codeLength];

    /**
     * The agent will iterate across every 'cell' in the cypher.
     * It first establishes what the actual code is based upon the 
     * first cell in the first cypher of the list.  In the event
     * that this does not persist across all instances in the list it
     * is otherwise ignored and set as null.
     */

    for (int c=0; c<codeLength; c++) {
      for (int currentCode=0; currentCode<totalCodes; currentCode++) {
        if (inputCodes.get(currentCode).len != codeLength) {
          throw new java.lang.IllegalArgumentException(); // throw error
        }

        if (currentCode==0) { 
          code = inputCodes.get(currentCode).code[c];
          learnedCode[c] = code;
        } else {
          if (!code.equals(inputCodes.get(currentCode).code[c])) {
            learnedCode[c] = null;
          }
        }
      }
    }
    Code lcode = new Code(learnedCode);
    return lcode;
  }
  
  public boolean totalCode() {
   for (int i=0; i<this.len; i++) {
    if (code[i] != null) {
     return false;
    }
   } 
   return true;
  }
  
}

void blink(){
      if(inspector_frame == 0){
         inspector_frame_dx = 1; 
      }
      else if(inspector_frame == 6){
        inspector_frame_dx = -1;
      } 
}

