//
//  MNRequestOperation.m
//  MMNNetwork
//
//  Created by MOMO on 2019/7/18.
//

#import "MNRequestOperation.h"

typedef NS_ENUM(NSInteger, MNRequestOperationState) {
    MNRequestOperationStateExecuting,
    MNRequestOperationStateSuspended,
    MNRequestOperationStateFinished,
};

@interface MNRequestOperation ()

@property (nullable, nonatomic, strong) NSString *keyPathForObserveSessionTask;
@property (nullable, nonatomic, strong) NSProgress *progress;

@property (nonatomic, assign) MNRequestOperationState operationState;

@end

@implementation MNRequestOperation

- (BOOL)isReady {
    return YES;
}

- (BOOL)isFinished {
    return _operationState == MNRequestOperationStateFinished;
}

- (BOOL)isExecuting {
    return _operationState == MNRequestOperationStateExecuting;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.completionBlock = ^{
        };
    }
    return self;
}

- (void)dealloc {
    if (_sessionTask) {
        [_sessionTask removeObserver:self forKeyPath:@"state"];
        if (_keyPathForObserveSessionTask) {
            [_sessionTask removeObserver:self forKeyPath:_keyPathForObserveSessionTask];
        }
    }
}

- (void)main {
    if (!self.sessionTask) {
        self.operationState = MNRequestOperationStateFinished;
        return;
    }
    [self.sessionTask resume];
}

- (void)cancel {
    [self.sessionTask cancel];
}

- (void)setOperationState:(MNRequestOperationState)operationState {
    switch (operationState) {
        case MNRequestOperationStateExecuting:
        case MNRequestOperationStateSuspended:
            [self willChangeValueForKey:@"isExecuting"];
            _operationState = operationState;
            [self didChangeValueForKey:@"isExecuting"];
            return;
        case MNRequestOperationStateFinished:
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            _operationState = operationState;
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
            return;
    }
}

- (void)setSessionTask:(NSURLSessionTask *)sessionTask {
    if (_sessionTask) {
        [_sessionTask removeObserver:self forKeyPath:@"state"];
        if (_keyPathForObserveSessionTask) {
            [_sessionTask removeObserver:self forKeyPath:_keyPathForObserveSessionTask];
        }
    }
    _sessionTask = sessionTask;
    if (_sessionTask) {
        [_sessionTask addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        NSString *keyPath = nil;
        if ([_sessionTask isKindOfClass:[NSURLSessionDownloadTask class]]) {
            keyPath = NSStringFromSelector(@selector(countOfBytesReceived));
        } else {
            keyPath = NSStringFromSelector(@selector(countOfBytesSent));
        }
        [sessionTask addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
        self.keyPathForObserveSessionTask = keyPath;
        __weak typeof(sessionTask) weakTask = sessionTask;
        self.progress = [[NSProgress alloc] init];
        self.progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        self.progress.cancellable = YES;
        self.progress.cancellationHandler = ^{
            [weakTask cancel];
        };
        self.progress.pausable = YES;
        self.progress.pausingHandler = ^{
            [weakTask suspend];
        };
        if (@available(iOS 9, macOS 10.11, *))
        {
            self.progress.resumingHandler = ^{
                [weakTask resume];
            };
        }
    }
}

- (void)sessionTaskStateDidChanged {
    switch (self.sessionTask.state) {
        case NSURLSessionTaskStateRunning:
            self.operationState = MNRequestOperationStateExecuting;
            break;
        case NSURLSessionTaskStateSuspended:
            self.operationState = MNRequestOperationStateSuspended;
            break;
        case NSURLSessionTaskStateCanceling:
            [super cancel];
            self.operationState = MNRequestOperationStateFinished;
            break;
        case NSURLSessionTaskStateCompleted:
            self.operationState = MNRequestOperationStateFinished;
            break;
        default:
            break;
    }
}

- (void)sessionTaskProgressDidChanged {
    if (self.downloadProgressBlock) {
        if (self.sessionTask.countOfBytesExpectedToReceive <= 0) return;
        self.progress.totalUnitCount = self.sessionTask.countOfBytesExpectedToReceive;
        self.progress.completedUnitCount = self.sessionTask.countOfBytesReceived;
        self.downloadProgressBlock(self.progress);
    } else {
        if (self.sessionTask.countOfBytesExpectedToSend <= 0) return;
        self.progress.totalUnitCount = self.sessionTask.countOfBytesExpectedToSend;
        self.progress.completedUnitCount = self.sessionTask.countOfBytesSent;
        self.uploadProgressBlock ? self.uploadProgressBlock(self.progress) : nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        [self sessionTaskStateDidChanged];
        return;
    }
    
    if ([keyPath isEqualToString:self.keyPathForObserveSessionTask]) {
        [self sessionTaskProgressDidChanged];
    }
}


@end
