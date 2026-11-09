import android.os.SystemClock;
import android.view.InputDevice;
import android.view.InputEvent;
import android.view.MotionEvent;
import java.lang.reflect.Method;

/** Shell-only AVD harness. No APK permissions, installation, or app changes. */
public final class JoystickTouch {
  private static Object manager;
  private static Method inject;
  private static long down;
  private static final MotionEvent.PointerProperties[] properties = {
    new MotionEvent.PointerProperties(), new MotionEvent.PointerProperties()
  };
  private static final MotionEvent.PointerCoords[] coords = {
    new MotionEvent.PointerCoords(), new MotionEvent.PointerCoords()
  };
  private static void send(int action, int count) throws Exception {
    MotionEvent event = MotionEvent.obtain(down, SystemClock.uptimeMillis(),
      action, count, properties, coords, 0, 0, 1, 1, 0, 0,
      InputDevice.SOURCE_TOUCHSCREEN, 0);
    try {
      if (!Boolean.TRUE.equals(inject.invoke(manager, event, 2)))
        throw new IllegalStateException("Input injection was not accepted");
    } finally { event.recycle(); }
  }
  private static void waitMoving(int count, long millis) throws Exception {
    long end = SystemClock.uptimeMillis() + millis;
    while (SystemClock.uptimeMillis() < end) {
      Thread.sleep(Math.min(20, Math.max(1, end-SystemClock.uptimeMillis())));
      send(MotionEvent.ACTION_MOVE, count);
    }
  }
  public static void main(String[] args) throws Exception {
    if (args.length != 8 && args.length != 9) throw new IllegalArgumentException(
      "centerX centerY targetX targetY shootX shootY holdMillis mode");
    Class<?> type = Class.forName("android.hardware.input.InputManagerGlobal");
    manager = type.getMethod("getInstance").invoke(null);
    inject = type.getMethod("injectInputEvent", InputEvent.class, int.class);
    for(int i=0;i<2;i++){
      properties[i].id=i; properties[i].toolType=MotionEvent.TOOL_TYPE_FINGER;
      coords[i].pressure=1;coords[i].size=1;
    }
    coords[0].x=Float.parseFloat(args[0]);coords[0].y=Float.parseFloat(args[1]);
    coords[1].x=Float.parseFloat(args[4]);coords[1].y=Float.parseFloat(args[5]);
    long hold=Long.parseLong(args[6]);String mode=args[7];
    long leadIn=args.length==9?Long.parseLong(args[8]):300;
    if(leadIn<0||leadIn>500)throw new IllegalArgumentException("Invalid lead-in");
    if(hold<0||hold>2000||!(mode.equals("shoot")||mode.equals("cancel")))
      throw new IllegalArgumentException("Invalid hold/mode");
    down=SystemClock.uptimeMillis();boolean active=false;
    try {
      send(MotionEvent.ACTION_DOWN,1);active=true;
      coords[0].x=Float.parseFloat(args[2]);coords[0].y=Float.parseFloat(args[3]);
      waitMoving(1,leadIn);
      send(MotionEvent.ACTION_POINTER_DOWN | (1<<MotionEvent.ACTION_POINTER_INDEX_SHIFT),2);
      System.out.println("BOTH_DOWN pointer0=joystick pointer1=shoot");System.out.flush();
      waitMoving(2,hold);
      if(mode.equals("cancel")){
        send(MotionEvent.ACTION_CANCEL,2);active=false;
        System.out.println("BOTH_CANCELLED");
      }else{
        send(MotionEvent.ACTION_POINTER_UP | (1<<MotionEvent.ACTION_POINTER_INDEX_SHIFT),2);
        System.out.println("SHOOT_UP_JOYSTICK_STILL_DOWN");System.out.flush();
        waitMoving(1,400);
        send(MotionEvent.ACTION_UP,1);active=false;
        System.out.println("JOYSTICK_UP");
      }
    } finally {if(active)send(MotionEvent.ACTION_CANCEL,2);}
  }
}
