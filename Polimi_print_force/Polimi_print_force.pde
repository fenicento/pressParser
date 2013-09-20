import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import peasy.*;
import de.looksgood.ani.*;

// Reference to physics world
VerletPhysics2D physics;
PeasyCam cam;
SQLite db;
// A list of cluster objects
ArrayList clusters;
ArrayList<String> links;

// Boolean that indicates whether we draw connections or not
boolean showPhysics = true;
boolean showParticles = true;

Ani diameterAni;

// Font
PFont f;
AttractionBehavior repulsion;
int count=0;
float trasp=1;

void setup() {

  Ani.init(this);
  size(1920, 1080, OPENGL);
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(300);
  cam.setMaximumDistance(1000);
  cam.lookAt(width/2, height/2+50, 0);
  f = createFont("Georgia", 12, true);
  db = new SQLite( this, "press.sqlite" );  // open database file
  
  smooth(8);
  // Initialize the physics
  
  physics=new VerletPhysics2D();
  physics.setDrag(0.000001);
  physics.setWorldBounds(new Rect(10, 10, width-10, height-10));
  repulsion= new AttractionBehavior(new Vec2D(width/2, height/2), width/2, -10);

  clusters=new ArrayList<Cluster>();
  // Spawn a new random graph
  //newGraph();

  //diameterAni = new Ani(this, 0.7, "trasp", 0f, Ani.SINE_IN, "onStart:itsStarted,onEnd:restoreTrasp");
  //diameterAni.end();
  
  querydb("12","2012");

  println(links);
}

// Spawn a new random graph
void newGraph() {
  trasp=1;


  // Clear physics
  physics.clear();


  // Create new ArrayList (clears old one)
  clusters = new ArrayList();

  // Create 8 random clusters
  for (int i = 0; i < 8; i++) {
    Vec2D center = new Vec2D(width/2, height/2);
    clusters.add(new Cluster((int) random(20, 80), random(100, 300), center));
  }

  //	All clusters connect to all clusters	
  for (int i = 0; i < clusters.size(); i++) {
    for (int j = i+1; j < clusters.size(); j++) {
      Cluster ci = (Cluster) clusters.get(i);
      Cluster cj = (Cluster) clusters.get(j);
      ci.connect(cj);
    }
  }
}

void draw() {
  //println(trasp);

  if (count <= 300) 
  {
    count++;
    //println("count: "+count);
  }
  else {
    //println("check!");
    count=0;
    //diameterAni.start();
  }

  // Update the physics world
  physics.update();

  background(0);
  
   if (showPhysics) {
    for (int i = 0; i < clusters.size(); i++) {
      // Cluster internal connections
      Cluster ci = (Cluster) clusters.get(i);
      ci.showConnections();
    }
    
  // Display all points
  if (showParticles) {
    for (int i = 0; i < clusters.size(); i++) {
      Cluster c = (Cluster) clusters.get(i);
      c.display();
    }
  }

  // If we want to see the physics
 
  }

  // Instructions
  fill(0);
  textFont(f);
  //text("'p' to display or hide particles\n'c' to display or hide connections\n'n' for new graph",10,20);
}

// Key press commands
void keyPressed() {
  if (key == 'c') {
    showPhysics = !showPhysics;
    if (!showPhysics) showParticles = true;
  } 
  else if (key == 'p') {
    showParticles = !showParticles;
    if (!showParticles) showPhysics = true;
  } 
  else if (key == 'n') {
    newGraph();
  }
}

void restoreTrasp(Ani theAni) {
  count=0;
  Ani.to(this, 0.1, "trasp", 1f, Ani.SINE_IN);
  //newGraph();
  
}

void itsStarted() {
  //println("diameterAni started");
}


void querydb(String month, String year) {
 
 db.connect(); 
 db.query( "SELECT * FROM links where year=\""+year+"\" AND month=\""+month+"\""); 
 
 ArrayList<Node> currNodes = new ArrayList<Node>();
 links = new ArrayList<String>();
 
 while (db.next())
        {
          
          links.add(db.getString("source")+"-"+db.getString("target")+"-"+db.getString("value"));
          
          //find sources
          boolean sfound=false;
          for(Node n : currNodes) {
            if(db.getString("source").equalsIgnoreCase(n.name)) {
              sfound=true;
              n.siz++;
              break;
            }
          }
          if(!sfound) {
            currNodes.add(new Node(random(-800,800),db.getString("source"),1));
          }
          
          
          //find targets
          boolean tfound=false;
          for(Node n : currNodes) {
            if(db.getString("target").equalsIgnoreCase(n.name)) {
              tfound=true;
              n.siz++;
              println("added");
              break;
            }
          }
          if(!tfound) {
            currNodes.add(new Node(random(-800,800),db.getString("target"),1));
          }
        }
    findType(currNodes);   
    clusters.add(new Cluster(currNodes,links)); 
}


void findType(ArrayList<Node> nod) {
  
 for(Node n : nod){
  db.query( "SELECT * FROM entities where name=\""+n.name+"\""); 
  
  while (db.next())
        {
          n.group=db.getInt("type")+1;
        }
 }
}
