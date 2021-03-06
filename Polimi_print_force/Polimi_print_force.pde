import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import peasy.*;
import de.looksgood.ani.*;
import java.util.Iterator;
import java.util.Map;
import java.util.Locale;
import java.text.DateFormatSymbols;
String monthString;
boolean people=true;
boolean orgs=true;
boolean places=true;


VerletPhysics2D physics;
PeasyCam cam;
SQLite db;
float sedSiz;
// A list of cluster objects
ArrayList clusters;
ArrayList<String> links;


IntDict relPlaces = new IntDict();
IntDict relPeople = new IntDict();
IntDict relCompany = new IntDict();

ArrayList<Sediment> sediments = new ArrayList<Sediment>();

HashMap<Integer, Integer> nclust = new HashMap<Integer, Integer>(); 
// Boolean that indicates whether we draw connections or not
boolean showPhysics = true;
boolean showParticles = true;

String relevant ="";
VerletParticle2D vvip;
Ani diameterAni;

// Font
PFont fb;
PFont fl;
AttractionBehavior repulsion;
int count=0;
float trasp=1;

int month=2;
int year=1992;
int yr1=0;
int yr2=0;



/*************************************
 *
 * SETUP - inizialization of variables 
 * and objects
 *
 **************************************/

void setup() {

  Ani.init(this);
  size(1920, 1080, OPENGL);
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(300);
  cam.setMaximumDistance(1300);
  cam.lookAt(width/2, height/2+50, 0);
  fl = loadFont("DIN-l40.vlw");
  fb = loadFont("DIN-b40.vlw");
  db = new SQLite( this, "press.sqlite" );  // open database file
  sedSiz=width/27f;
  smooth(8);
  // Initialize the physics

  physics=new VerletPhysics2D();
  physics.setDrag(0.000001);
  physics.setWorldBounds(new Rect(300, 300, width-300, height-300));
  repulsion= new AttractionBehavior(new Vec2D(width/2, height/2), width/2, -10);

  clusters=new ArrayList<Cluster>();
  // Spawn a new random graph
  //newGraph();

  diameterAni = new Ani(this, 0.7, "trasp", 0f, Ani.SINE_IN, "onStart:itsStarted,onEnd:restoreTrasp");
  diameterAni.end();

  //querydb(String.valueOf(month), String.valueOf(year));

  println(links);
  textFont(fl, 12);
  interval("1992", "2003");
}



/*************************************
 *
 * NEW GRAPH - spawns a new graph
 *
 **************************************/

void newGraph() {
  trasp=1;


  // Clear physics
  physics.clear();


  // Create new ArrayList (clears old one)
  clusters = new ArrayList();
  nclust = new HashMap<Integer, Integer>(); 
  nextMonth();
  querydb(String.valueOf(month), String.valueOf(year));
}


/*************************************
 *
 * DRAW - draws everything on screen
 *
 **************************************/

void draw() {
  //println(trasp);

  textAlign(LEFT);
  if (count>0 && count<= 300) 
  {
    count++;
    //println("count: "+count);
  }
  else {
    //println("check!");
    count=0;
    diameterAni.start();
  }

  // Update the physics world
  physics.update();

  background(0);

  fill(255);
  textSize(40);
  textFont(fl, 40);
  textAlign(RIGHT);
  
  if(yr1 ==0 && yr2==0) {
  monthString=new DateFormatSymbols(Locale.ENGLISH).getMonths()[month-1].toUpperCase();
  text(monthString, 200, 75);

  textAlign(LEFT);
  textFont(fb, 40);
  
  float sl=monthString.length();
  text(year, 210, 75);
  }
  
  else {
    textAlign(LEFT);
    textFont(fb, 40);
    text(yr1+" / "+yr2, 35, 75);
    
  }

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
  }
  textAlign(CENTER);
  drawSediments();
}



/*************************************
 *
 * KEY PRESSED - actions on keypress 
 * for debug
 *
 **************************************/

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

/*************************************
 *
 * RESTORE TRASP - end function of 
 * fading animations. Calls new graph
 *
 **************************************/

void restoreTrasp(Ani theAni) {
  count=0;
  Ani.to(this, 0.1, "trasp", 1f, Ani.SINE_IN);
  //newGraph();
}

void itsStarted() {
  //println("diameterAni started");
}



/*************************************
 *
 * QUERY DB - create new nodes for the
 * selected month
 *
 **************************************/


void querydb(String month, String year) {

  yr1=0;
  yr2=0;
  db.connect(); 
  db.query( "SELECT * FROM links where year=\""+year+"\" AND month=\""+month+"\""); 

  ArrayList<Node> currNodes = new ArrayList<Node>();
  links = new ArrayList<String>();
  nclust.put(1, 0);
  while (db.next ())
  {

    links.add(db.getString("source")+"#"+db.getString("target")+"#"+db.getString("value"));



    int clu= db.getInt("cluster")+1;
    if (nclust.get(clu)!=null) nclust.put(clu, nclust.get(clu)+1);
    else nclust.put(clu, 1);
    //find sources
    boolean sfound=false;
    for (Node n : currNodes) {
      if (db.getString("source").equalsIgnoreCase(n.name)) {
        sfound=true;
        n.siz++;
        break;
      }
    }
    if (!sfound) {
      currNodes.add(new Node(random(-80, 80), db.getString("source"), 1, db.getInt("cluster")));
    }


    //find targets
    boolean tfound=false;
    for (Node n : currNodes) {
      if (db.getString("target").equalsIgnoreCase(n.name)) {
        tfound=true;
        n.siz++;
        break;
      }
    }
    if (!tfound) {
      currNodes.add(new Node(random(-100, 100), db.getString("target"), 1, db.getInt("cluster")));
    }
  }
  findType(currNodes);   
  clusters.add(new Cluster(currNodes, links)); 
  updateSediments(currNodes);
}


/*************************************
 *
 * FIND TYPE - assign types to nodes
 *
 **************************************/

void findType(ArrayList<Node> nod) {

  for (Node n : nod) {
    db.query( "SELECT * FROM entities where name=\""+n.name+"\""); 

    while (db.next ())
    {
      if (n.name.equalsIgnoreCase(relevant)) {
        n.vip=1;
        vvip=(VerletParticle2D) n;
      }
      
      n.group=db.getInt("type")+1;
      if(n.group==1 && !orgs) n.disp=false;
      else if(n.group==2 && !people) n.disp=false;
      else if(n.group==3 && !places) n.disp=false;
    }
  }
}


/*************************************
 *
 * NEXT MONTH - finds the next month
 *
 **************************************/

void nextMonth() {

  if (month<12) month++;
  if (month==12) {
    month=1;
    if (year==2013) year=1992;
    else year++;
  }
  if(month==9 && year==2013) {
  month=1;
  year=1992;
  relCompany.clear();
  relPlaces.clear();
  relPeople.clear();
  }
}

/*************************************
 *
 * UPDATE SEDIMENTS - update accumulation
 * of entities
 *
 **************************************/

void updateSediments(ArrayList<Node> currNodes) {

  println("updating sediments");
  //remove past elements 
  Iterator<Sediment> i = sediments.iterator();
  while (i.hasNext ()) {
    Sediment s = i.next(); 
    s.update();
    if (s.ct>=1000) {
      if (s.type==1) relCompany.sub(s.name, s.value);
      else if (s.type==2) relPeople.sub(s.name, s.value);
      else if (s.type==3) relPlaces.sub(s.name, s.value);
      i.remove();
    }
  }

  //add new elements
  for (Node n : currNodes) {
    Sediment s = new Sediment(n.name, int(n.siz), n.group);
    sediments.add(s);

    if (s.type==1) {
      if (relCompany.hasKey(s.name)) relCompany.add(s.name, s.value);
      else relCompany.set(s.name, s.value);
    }

    else if (s.type==2) {
      if (relPeople.hasKey(s.name)) relPeople.add(s.name, s.value);
      else relPeople.set(s.name, s.value);
    }

    else if (s.type==3) {
      if (relPlaces.hasKey(s.name)) relPlaces.add(s.name, s.value);
      else relPlaces.set(s.name, s.value);
    }
  }

  relCompany.sortValuesReverse();
  relPeople.sortValuesReverse();
  relPlaces.sortValuesReverse();
}



/*************************************
 *
 * DRAW SEDIMENTS - draws the sedimentation
 *
 **************************************/

void drawSediments() {
  hint(DISABLE_DEPTH_TEST);

  fill(0);
  rect(-100, height-70, width+100, 120);

  textSize(14);

  for (float i = 0; i<8; i++) {

    if (relCompany.size()>i+1) {

      String kc=relCompany.keyArray()[int(i)];
      Integer vc = relCompany.get(kc);
      fill(#F73A10);
      ellipse(sedSiz*i+sedSiz, height-50, sqrt(float(vc)/PI)*6, sqrt(float(vc)/PI)*6);
      fill(255);
     
      
      text(kc, sedSiz*i+sedSiz/2, height-20,sedSiz, 20);
     
    }
    if (relPeople.size()>i+1) {

      String kp=relPeople.keyArray()[int(i)];
      Integer vp = relPeople.get(kp);
      fill(#66BAA6);
      ellipse(width/3+sedSiz*i+sedSiz, height-50, sqrt(float(vp)/PI)*6, sqrt(float(vp)/PI)*6);
      fill(255);
      pushMatrix();
      text(kp, width/3+sedSiz*i+sedSiz/2, height-20, sedSiz, 40);
      popMatrix();
    }
    if (relPlaces.size()>i+1) { 

      String kpl=relPlaces.keyArray()[int(i)];
      Integer vpl = relPlaces.get(kpl);
      fill(#0D5C19);
      ellipse(2*width/3+sedSiz*i+sedSiz, height-50, sqrt(float(vpl)/PI)*6, sqrt(float(vpl)/PI)*6);
      fill(255);
      pushMatrix();
      text(kpl, 2*width/3+sedSiz*i+sedSiz/2, height-20, sedSiz, 40);
      popMatrix();
    }
  }
  hint(ENABLE_DEPTH_TEST);
}

/*************************************
 *
 * INTERVAL - select a time interval
 * in years
 *
 **************************************/


void interval(String y1, String y2) {
  
  yr1=int(y1);
  yr2=int(y2);
  
  int diff=int(y2)-int(y1)+1;

  db.connect(); 
  db.query( "SELECT x.f1 FROM (SELECT source As F1 FROM links WHERE year BETWEEN \""+y1+"\" AND \""+y2+"\"  UNION ALL SELECT target As F1 FROM links WHERE year BETWEEN \""+y1+"\" AND \""+y2+"\") x GROUP BY x.f1 ORDER BY Count(x.f1) DESC LIMIT 60");
  ArrayList <String> selection = new ArrayList<String>();
  while (db.next ())
  {
    selection.add(db.getString("F1"));
  }

  ArrayList<Node> currNodes = new ArrayList<Node>();
  links = new ArrayList<String>();
  nclust.put(1, 0);

  db.query( "SELECT * FROM links where year BETWEEN \""+y1+"\" AND \""+y2+"\"");

  while (db.next ()) {
    if (selection.contains(db.getString("source")) && selection.contains(db.getString("target")) ) {
      links.add(db.getString("source")+"#"+db.getString("target")+"#"+db.getString("value"));



      int clu= db.getInt("cluster")+1;
      if (nclust.get(clu)!=null) nclust.put(clu, nclust.get(clu)+1);
      else nclust.put(clu, 1);
      //find sources
      boolean sfound=false;
      for (Node n : currNodes) {
        if (db.getString("source").equalsIgnoreCase(n.name)) {
          sfound=true;
          n.siz+=1/float(10+diff);
          break;
        }
      }
      if (!sfound) {
        currNodes.add(new Node(random(-80, 80), db.getString("source"), 1, db.getInt("cluster")));
      }

      //find targets
      boolean tfound=false;
      for (Node n : currNodes) {
        if (db.getString("target").equalsIgnoreCase(n.name)) {
          tfound=true;
          n.siz+=1/float(10+diff);
          break;
        }
      }
      if (!tfound) {
        currNodes.add(new Node(random(-100, 100), db.getString("target"), 1, db.getInt("cluster")));
      }
    }
  }
  findType(currNodes);   
  clusters.add(new Cluster(currNodes, links)); 
  updateSediments(currNodes);
  count=0;
}


void checkFilters() {
  
//  for (Node k : currNodes) {
//   
//   if(k.group==1 && !orgs) k.disp=false;
//   else if(k.group==2 && !people) k.disp=false;
//   else if(k.group==3 && !places) k.disp=false;
//    
//  }
  
  
}

