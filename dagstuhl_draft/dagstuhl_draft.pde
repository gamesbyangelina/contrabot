CodeButton[][] code;
CodeButton[][] suspected_code;
int tableSize = 4;
int buttonWidth = 50;

//Assets - images, fonts, etc.
PFont font;
PImage img_crate;

//Test stuff for building miniature tags
MiniTag m;

//Game state stuff
boolean b_waitingForPlayerToSendCode = true;

//Scenery silliness
ArrayList<SceneryCrate> scenery_crates = new ArrayList<SceneryCrate>();
int inspector_frame = 0;
int inspector_frame_dx = 0;
PImage[] anim_inspector;
int nextFrame = 100; int animRate = 100; int lastMillis = 0;

void setup(){
    size(300*3, 350);
    background(153);
    img_crate = loadImage("crate.png");
    
    anim_inspector = new PImage[7];
    for(int i=1; i<8; i++){
        anim_inspector[i-1] = loadImage("inspector"+i+".png");
    }
  
    //Create a 3x3 table of buttons to encode a message in
    code = new CodeButton[tableSize][tableSize];
    for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
          code[i][j] = new CodeButton(50+i*50, 50+j*50, 50, 50, true);
       } 
    }
    //Create a 3x3 table of (uneditable) buttons to show what the current suspected code is
    suspected_code = new CodeButton[tableSize][tableSize];
    for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
          suspected_code[i][j] = new CodeButton(350+(i*50), 50+j*50, 50, 50, false);
       } 
    }

    font = createFont("font.ttf", 32);
    textFont(font);
    textAlign(CENTER, TOP);
    
    int cx = -32;
    while(cx < 868){
      cx += 50 + random(50);
      scenery_crates.add(new SceneryCrate(cx, 318));
    }
    
    int[][] minicode = new int[][]{
      {1,0,1,0},
      {0,1,0,1},
      {1,0,1,0},
      {0,1,0,1},
    };
    m = new MiniTag(minicode, 10, 10, 4); 
    
}

void sendCode(){
   /*
    *  DO STUFF HERE
    */
   //b_waitingForPlayerToSendCode = false; 
   
   scenery_crates.add(new SceneryCrate(-10, 318));
}

void keyPressed(){
   if(key == ' ' && b_waitingForPlayerToSendCode){
      sendCode();
   } 
   if(key == 'q'){
      //Test the animation
      if(inspector_frame == 0){
         inspector_frame_dx = 1; 
      }
      else if(inspector_frame == 6){
        inspector_frame_dx = -1;
      }
   }
}

void draw(){
   background(153);
   
   //Draw all the things!
   for(int i=0; i<tableSize; i++){
       for(int j=0; j<tableSize; j++){
         CodeButton cb = code[i][j];
         fill(cb.c);
         rect(cb.x, cb.y, cb.w, cb.h);
         
         cb = suspected_code[i][j];
         fill(cb.c);
         rect(cb.x, cb.y, cb.w, cb.h);
      } 
    }
    
    //Draw the inspector
    image(anim_inspector[inspector_frame], 900/2 - 24, 350-64);
    
    for(SceneryCrate sc : scenery_crates){
       image(img_crate, sc.x, sc.y);
        sc.update(); 
    }
    
    fill(0,0,0);
    text("Current Code", 50 + tableSize*(buttonWidth/2), 15);
    text("Suspected Code", 350 + tableSize*(buttonWidth/2), 15);
    text("Press SPACE to transmit", 300, 265);
    rect(0, 348, width, 2);
    
   //Update all the game logics!
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
     lastMillis = millis();
   }
   
   m.draw();
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
  
  SceneryCrate(int _x, int _y){
     x = _x; y = _y;
  } 
  
  void update(){
     if(x > width){
        x = -32; 
     }
     x += speed;
  }
}

/*
 *  Minitags are used to indicate codes that have been sent through the conveyor.
 *  They're little UI things, basically.
 */
class MiniTag{
    int[][] array;
    int x;
    int y;
    int w;
    
    int border = 1;
  
   MiniTag(int[][] _array, int _x, int _y, int _w){
     array = _array;
     x = _x; y = _y;
     w = _w;
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
          else{
            stroke(0);
            fill(0);
          }
          rect(border + x + i*w, border + y + j*w, w, w);
        } 
     }
   }
}

//This is a button that changes colour when you click it
class CodeButton{
    float x, y, w, h;
    
    int state = 0;
    color c;
    color c_on = color(0, 0, 0);
    color c_off = color(255, 255, 255);
    
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
      if(!editable)
        return;
       switch(state){
          case 0: c = c_off; break;
          case 1: c = c_on; break;
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
}
