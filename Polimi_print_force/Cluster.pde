class Cluster {

  // A cluster is a grouping of nodes
  ArrayList<Node> nodes;

  float diameter;

  Cluster(ArrayList<Node> n, ArrayList<String> ls) {

    println(nclust.keySet().size());
    
    ArrayList<Vec2D> centers= new ArrayList<Vec2D>();

    if (nclust.keySet().size()==1) {
      centers.add(new Vec2D(width/2, height/2));
      centers.add(new Vec2D(width/2, height/2));
    }
    else {
      for (int i = 0; i<nclust.keySet().size(); i++) {
        centers.add(new Vec2D(random(300, width-300), random(400, height-400)));
      }
    }
    nodes=n;
    Node n1=null;
    Node n2=null;
    int card=0;
    for (String c : ls) {

      String[] spc = c.split("#");

      for (Node no : nodes) {

        if (no.name.equalsIgnoreCase(spc[0])) {
          n1= no;

          break;
        }
      }

      for (Node no : nodes) {

        no.x=centers.get(no.clust-1).x+random(-50,50);
        no.y=centers.get(no.clust-1).y+random(-50,50);

        if (no.name.equalsIgnoreCase(spc[1])) {
          n2= no;

          card=nclust.get(no.clust);
          break;
        }
      }
      
      if(n1.vip==1) n2.vip=2;
      if(n2.vip==1) n1.vip=2;

      float near=constrain(100+card*2-float(spc[2])*40, 10, 400);
      println("near: "+near);
      physics.addSpring(new VerletSpring2D((VerletParticle2D)n1, (VerletParticle2D)n2, near, 0.001));
    }
  }


  void display() {
    // Show all the nodes
    for (int i = 0; i < nodes.size(); i++) {
      Node n = (Node) nodes.get(i);
      n.display();
    }
  }



  // Draw all the internal connections
  void showConnections() {

    for (VerletSpring2D s : physics.springs) {
      //float val=(200-s.getRestLength())/40;
      if(vvip!=null && (s.a.equals(vvip) || s.b.equals(vvip))) stroke(255,200*trasp);
      else stroke(100, 100*trasp);
      
      line(s.a.x, s.a.y, s.b.x, s.b.y);
    }
  }


  ArrayList getNodes() {
    return nodes;
  }
}

