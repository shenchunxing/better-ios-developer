//
//  YCHudDefine.h
//  YCAPIHUDPresenter
//
//  Created by 刘成 on 2019/4/15.
//

#ifndef YCHudDefine_h
#define YCHudDefine_h

#import "YCAlertHUDPresnter.h"
#import "UIView+Toast.h"
#import "YCMBHUDPresenter.h"



//显示类似ANDROID的TOAST提示文本
#define toast_dismiss_time 1.5
#define showTopToast(view, message)                                           \
{                                                                         \
[view makeToast:message duration:toast_dismiss_time position:@"CSToastPositionTop"]; \
}
#define showCenterToast(view, message)                                           \
{                                                                            \
[view makeToast:message duration:toast_dismiss_time position:@"CSToastPositionCenter"]; \
}
#define showBottomToast(view, message)                                           \
{                                                                            \
[view makeToast:message duration:toast_dismiss_time position:@"CSToastPositionBottom"]; \
}
#define dismissToast(view)   \
{                        \
[view dismissToast]; \
}

#endif /* YCHudDefine_h */
