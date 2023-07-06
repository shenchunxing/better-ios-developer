### CALayer如何添加点击事件？
通过 touchesBegan: withEvent 方法,监听屏幕点击事件,在这个方法中通过 convertPoint 找到点击位置,进行判断,如果点击了 layer 视图内坐标,就触发点击事件
通过 hitTest方法找到包含坐标系的 layer 视图

  - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  // 方法一,通过 convertPoint 转为为 layer 坐标系进行判断
  CGPoint point = [[touches anyObject] locationInView:self.view];
  CGPoint redPoint = [self.redLayer convertPoint:point fromLayer:self.view.layer];
  if ([self.redLayer containsPoint:redPoint]) {
     NSLog(@"点击了calayer");
  }
 // 方法二 通过 hitTest 返回包含坐标系的 layer 视图
  CGPoint point1 = [[touches anyObject] locationInView:self.view];
  CALayer *layer = [self.view.layer hitTest:point1];
  if (layer == self.redLayer) {
      NSLog(@"点击了calayer");`
    }
  }


### 什么是响应者链?
响应者链是用于确定事件响应的一种机制, 事件主要是指触摸事件(touch Event),该机制与UIKIT中的UIResponder类密切相关,响应触摸事件的必须是继承自UIResponder的类,比如UIView 和UIViewController
一个事件响应者的完成主要分为2个过程: hitTest方法命中视图和响应者链确定响应者; hitTest的调用顺序是从UIWindow开始，对视图的每个子视图依次调用，也可以说是从显示最上面到最下面,直到找命中者; 然后命中者视图沿着响应者链往上传递寻找真正的响应者.
事件传递过程

当我们触控手机屏幕时系统便会将这一操作封装成一个UIEvent放到事件队列里面，然后Application从事件队列取出这个事件，接着需要找到命中者, 所以开始的第一步应该是找到命中者, 那么又是如何找到的呢？那就不得不引出UIView的2个方法：

markdown复制代码1.  `// 返回能够相应该事件的视图`
2.  `-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event`
3.  `// 查看点击的位置是否在这个视图上`
4.  `-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event`


寻找事件的命中视图是通过对视图调用hitTest和pointInside完成的 hitTest的调用顺序是从UIWindow开始，对视图的每个子视图依次调用，也可以说是从显示最上面到最下面 遍历直到找到命中视图;

响应链传递

找到命中者,任务并未完成,因为命中者不一定是事件的响应者,所谓响应就是开发中为事件绑定一个触发函数,事件发生后,执行响应函数里的代码
找到命中视图后事件会从此视图开始沿着响应链nextResponder传递，直到找到处理事件的响应视图,如果没有处理的事件会被丢弃。
如果视图有父视图则nextResponder指向父视图，如果是根视图则指向控制器，最终指向AppDelegate, 他们都是通过重写nextResponder来实现。
自下往上查找

无法响应的事件情况

Alpha=0、
子视图超出父视图的情况、
userInteractionEnabled=NO、
hidden=YES

### UIScrollView 原理

UIScrollView继承自UIView，内部有一个 UIPanGestureRecongnizer手势。 frame 是相对父视图坐标系来决定自己的位置和大小，而bounds是相对于自身坐标系的位置和尺寸的。改视图 bounds 的 origin 视图本身没有发生变化，但是它的子视图的位置却发生了变化，因为 bounds 的 origin 值是基于自身的坐标系，当自身坐标系的位置被改变了，里面的子视图肯定得变化， bounds 和 panGestureRecognize 是实现 UIScrollView 滑动效果的关键技术点。

###  layoutIfNeeded , layoutSubViews和 setNeedsLayout区别?

layoutIfNeeded 方法一点被调用,主线程会立即强制重新布局,它会从当前视图开始,一直到完成所有子视图的布局
layoutSubViews 用来自定义视图尺寸,他是系统自动调用的,开发者不能手动调用,可以重写改方法,让系统在调整布局时候按照我们希望的方式进行布局.这个方法在旋转屏幕,滑动或者触摸屏幕,修改子视图时候被触发.
setNeedsLayout 和 layoutIfNeeded相似,唯一不同的是他不会立即强制视图重新布局,而是在下一个布局周期才会触发更新.他主要用于多个视图布局先后更新的场景;
