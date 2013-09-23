class Cluster {

  // A cluster is a grouping of nodes
  ArrayList<Node> nodes;

  float diameter;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(int n, float d, Vec2D center) {

    // Initialize the ArrayList
    nodes = new ArrayList();

    // Set the diameter
    diameter = d;

    // Create the nodes
    for (int i = 0; i < n; i++) {
      // We can't put them right on top of each other
      nodes.add(new Node(center.add(Vec2D.randomVector())));
    }

    // Connect all the nodes with a Spring
    for (int i = 1; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = 0; j < i; j++) {
        VerletParticle2D pj = (VerletParticle2D) nodes.get(j);
        // A Spring needs two particles, a resting length, and a strength
        physics.addSpring(new VerletSpring2D(pi,pj,random(700,1200),0.001));
      }
    }
  }

  Cluster(ArrayList<Node> n, ArrayList<String> ls) {
    
    ArrayList<Vec2D> centers= new ArrayList<Vec2D>();
    
    for (int i = 0; i<nclust.keySet().size(); i++) {
     
     centers.add(new Vec2D(random(300,width-300),random(300,height-300))); 
      
    }
    
    nodes=n;
    VerletParticle2D n1=null;
    VerletParticle2D n2=null;
     int card=0;
    for(String c : ls) {
      
      String[] spc = c.split("-");
      
      for (Node no : nodes) {
        
        if(no.name.equalsIgnoreCase(spc[0])) {
         n1=(VerletParticle2D) no;
         
        break; 
        }
        
      }
    
    for (Node no : nodes) {
        
        no.x=centers.get(no.clust-1).x+random(-50,50);
        no.y=centers.get(no.clust-1).y+random(-50,50);
      
        if(no.name.equalsIgnoreCase(spc[1])) {
         n2=(VerletParticle2D) no;
         
         card=nclust.get(no.clust);
        break; 
        }
        
      }
     
      float near=constrain(100+card*2-float(spc[2])*40,20,600);
      println("near: "+near);
      physics.addSpring(new VerletSpring2D(n1,n2,near,0.001));
      
    
    }
    
  }
  
  
  void display() {
    // Show all the nodes
    for (int i = 0; i < nodes.size(); i++) {
      Node n = (Node) nodes.get(i);
      n.display();
    }
  }

  // This functons connects one cluster to another
  // Each point of one cluster connects to each point of the other cluster
  // The connection is a "VerletMinDistanceSpring"
  // A VerletMinDistanceSpring is a string which only enforces its rest length if the 
  // current distance is less than its rest length. This is handy if you just want to
  // ensure objects are at least a certain distance from each other, but don't
  // care if it's bigger than the enforced minimum.
  void connect(Cluster other) {
    ArrayList otherNodes = other.getNodes();
    for (int i = 0; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = 0; j < otherNodes.size(); j++) {
        VerletParticle2D pj = (VerletParticle2D) otherNodes.get(j);
        // Create the spring
        physics.addSpring(new VerletMinDistanceSpring2D(pi,pj,(diameter+other.diameter)*0.4,0.5));
      }
    }
  }


  // Draw all the internal connections
  void showConnections() {
    
    for(VerletSpring2D s : physics.springs) {
      //float val=(200-s.getRestLength())/40;
      
      stroke(100,100*trasp);
      line(s.a.x,s.a.y,s.b.x,s.b.y);
    
    }
  }

  // Draw all the connections between this Cluster and another Cluster
  void showConnections(Cluster other) {
    stroke(255,50*trasp);
    strokeWeight(2);
    ArrayList otherNodes = other.getNodes();
    for (int i = 0; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = 0; j < otherNodes.size(); j++) {
        VerletParticle2D pj = (VerletParticle2D) otherNodes.get(j);
        line(pi.x,pi.y,pj.x,pj.y);
      }
    }
  }

  ArrayList getNodes() {
    return nodes;
  }

}
