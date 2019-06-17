/*:
 RunLoop 有五种运行模式，其中常见的有1.2两种
 1. kCFRunLoopDefaultMode：App的默认Mode，通常主线程是在这个Mode下运行
 2. UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
 3. UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用，会切换到kCFRunLoopDefaultMode
 4. GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到
 5. kCFRunLoopCommonModes: 这是一个占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode
 
 RunLoop事件类型
 - Source0: 触摸事件，PerformSelectors
 - Source1: 基于Port的线程间通信
 */
