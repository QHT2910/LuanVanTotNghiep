import android.os.SystemClock;
import android.view.InputDevice;
import android.view.InputEvent;
import android.view.MotionEvent;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.reflect.Method;

/** Bounded shell-only inspection: retain the real shoot owner while tapping views. */
public final class HeldInspectionTouch {
  static Object manager;
  static Method inject;
  static long down;
  static boolean active;
  static final MotionEvent.PointerProperties[] props = {
    new MotionEvent.PointerProperties(), new MotionEvent.PointerProperties()};
  static final MotionEvent.PointerCoords[] coords = {
    new MotionEvent.PointerCoords(), new MotionEvent.PointerCoords()};
  static void send(int action, int count) throws Exception {
    MotionEvent e = MotionEvent.obtain(down, SystemClock.uptimeMillis(), action,
      count, props, coords, 0, 0, 1, 1, 0, 0, InputDevice.SOURCE_TOUCHSCREEN, 0);
    try {
      if (!Boolean.TRUE.equals(inject.invoke(manager, e, 2)))
        throw new IllegalStateException("Input rejected");
    } finally { e.recycle(); }
  }
  static void tap(float x, float y) throws Exception {
    coords[1].x=x; coords[1].y=y;
    send(MotionEvent.ACTION_POINTER_DOWN | (1<<8), 2);
    Thread.sleep(35);
    send(MotionEvent.ACTION_POINTER_UP | (1<<8), 2);
  }
  public static void main(String[] args) throws Exception {
    if(args.length!=7&&args.length!=8) throw new IllegalArgumentException("shootX shootY freezeX freezeY delay jumpX jumpY [recharge]");
    long delay=Long.parseLong(args[4]);
    if(delay<0||delay>1800) throw new IllegalArgumentException("delay");
    Class<?> c=Class.forName("android.hardware.input.InputManagerGlobal");
    manager=c.getMethod("getInstance").invoke(null);
    inject=c.getMethod("injectInputEvent",InputEvent.class,int.class);
    for(int i=0;i<2;i++){
      props[i].id=i; props[i].toolType=MotionEvent.TOOL_TYPE_FINGER;
      coords[i].pressure=1; coords[i].size=1;
    }
    coords[0].x=Float.parseFloat(args[0]); coords[0].y=Float.parseFloat(args[1]);
    down=SystemClock.uptimeMillis();
    try {
      send(MotionEvent.ACTION_DOWN,1); active=true;
      if(args.length==8&&args[7].equals("recharge")){
        Thread.sleep(60);
        send(MotionEvent.ACTION_CANCEL,1);active=false;
        Thread.sleep(20);
        down=SystemClock.uptimeMillis();send(MotionEvent.ACTION_DOWN,1);active=true;
        System.out.println("CANCEL_RECHARGE");System.out.flush();
      }
      float jumpX=Float.parseFloat(args[5]),jumpY=Float.parseFloat(args[6]);
      if(jumpX>=0) tap(jumpX,jumpY);
      Thread.sleep(delay);
      tap(Float.parseFloat(args[2]),Float.parseFloat(args[3]));
      System.out.println("FREEZE_TAPPED_OWNER_HELD"); System.out.flush();
      BufferedReader reader=new BufferedReader(new InputStreamReader(System.in));
      long deadline=SystemClock.uptimeMillis()+45000;
      while(SystemClock.uptimeMillis()<deadline){
        if(!reader.ready()){Thread.sleep(20);continue;}
        String line=reader.readLine(); if(line==null)break;
        String[] command=line.trim().split(" +");
        if(command[0].equals("tap")&&command.length==3){
          tap(Float.parseFloat(command[1]),Float.parseFloat(command[2]));
          System.out.println("VIEW_TAPPED"); System.out.flush();
        } else if(command[0].equals("release")){
          send(MotionEvent.ACTION_UP,1);active=false;return;
        } else if(command[0].equals("cancel")){break;}
        else throw new IllegalArgumentException("Unknown command");
      }
    } finally {if(active)send(MotionEvent.ACTION_CANCEL,1);}
  }
}
