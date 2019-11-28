# MMJusticeCenter

## INTRODUCE

挺供图片检测功能，包括鉴黄、涉政、二维码检测等功能。

## 接入环境

iOS版本：9.0+

## 使用说明

### 设置AppId

请务必在使用SDK前加入如下代码，这会将AppId注册进SDK

```
#import <MMJusticeCenter/MMJusticeCenter.h>

    [MMJusticeCenter configureAppId:<YourAPPId>];
```

### 环境预加载

可以在业务使用前调用此方法预加载SDK资源

```
    [MMJusticeCenter prepareAllSupportedScenesWithCompletion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {

    }];
```

### 创建检测器

异步构建检测器，即使没有预加载SDK资源，此接口内部也会同步更新资源

```
    [MMJusticeCenter asyncMakeJusticeWithSceneId:@"live" completion:^(Justice * _Nullable justice) {

    }];
```

## Author

zhu.xi, zhu.xi@immomo.com

## License

MMJusticeCenter is available under the MIT license. See the LICENSE file for more info.
