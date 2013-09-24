// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Force directed graph
// Heavily based on: http://code.google.com/p/fidgen/

// Notice how we are using inheritance here!
// We could have just stored a reference to a VerletParticle object
// inside the Node class, but inheritance is a nice alternative

class Node extends VerletParticle2D {
  
  int group;
  float siz;
  int vip=0;
  String name;
  int clust;
  
  Node(Vec2D pos) {
    super(pos);
    group=int(random(1,4));
    siz=random(5,20);
  }
  
   Node(float offset, String n, float s, int c) {
    super(new Vec2D(width/2+offset,height/2.3+offset));
    this.name=n;
    this.siz=log(s);
    this.group=1;
    this.clust=c+1;
  }

  // All we're doing really is adding a display() function to a VerletParticle
  void display() {
     noStroke();
    hint(DISABLE_DEPTH_TEST);
    
    if(vvip!=null) {
     
     if(this.vip>0) {
      if(group==1) drawCircle(x,y,16,#44ddff,255);
      else if(group==2) drawCircle(x,y,siz,#ddff77,255);
      else if(group==3) drawCircle(x,y,siz,#ff8888,255);
     }
    
    else {
     if(group==1) drawCircle(x,y,16,#44ddff,40);
     else if(group==2) drawCircle(x,y,siz,#ddff77,40);
     else if(group==3) drawCircle(x,y,siz,#ff8888,40);
    } 
      
    }
    
    else{
     
     if(group==1) drawCircle(x,y,16,#44ddff,255);
     else if(group==2) drawCircle(x,y,siz,#ddff77,255);
     else if(group==3) drawCircle(x,y,siz,#ff8888,255);
     
    }
    hint(ENABLE_DEPTH_TEST); 
  }
  
  void drawCircle(float x,float y, float m, color col, int alpha) {
    fill(col, alpha*trasp);
    noStroke();
    float r=sqrt(m/PI)*9;
    ellipse(x,y,r,r);
    fill(255,alpha*trasp);
   textSize(14);
   text(this.name, x+r, y+r*.5);
  }
   
    void drawTriangle(float x,float y, float m, color col) {

    
    float randang=m/y*100;

    fill(col, 60*trasp);
    stroke(col, 80*trasp);
    
    pushMatrix();
    
    translate(x, y);
    rotateZ(randang);
    beginShape(TRIANGLES);

    vertex(0, -m, 0);
    vertex(-0.866*m, 0.5*m, 0);
    vertex(0.866*m, 0.5*m, 0);
    endShape(CLOSE);

    fill(col, 60*trasp);
    stroke(col, 80*trasp);
    beginShape(TRIANGLES);

    vertex(0, -m, 0);
    vertex(0.866*m, 0.5*m, 0);
    //vertex(x+0.8*m,y+0.8*m,0);
    fill(col, 30*trasp);
    stroke(col, 40*trasp);
    vertex(0, 0, m);

    endShape(CLOSE);

    fill(col, 60*trasp);
    stroke(col, 80*trasp);
    beginShape(TRIANGLES);

    //vertex(x,y-m,0);
    vertex(-0.866*m, 0.5*m, 0);
    vertex(0.866*m, 0.5*m, 0);

    fill(col, 30*trasp);
    stroke(col, 40*trasp);
    vertex(0, 0, m);

    endShape(CLOSE);

    fill(col, 60*trasp);
    stroke(col, 80*trasp);
    beginShape(TRIANGLES);

    vertex(0, -m, 0);
    //vertex(x-0.8*m,y+0.8*m,0);
    vertex(-0.866*m, 0.5*m, 0);

    fill(col, 30*trasp);
    stroke(col, 40*trasp);
    vertex(0, 0, m);

    endShape(CLOSE);
    popMatrix();
    
    
    
   fill(255,200*trasp);
   textSize(12);
   text(this.name, x+m, y+m*.5);

}
}

