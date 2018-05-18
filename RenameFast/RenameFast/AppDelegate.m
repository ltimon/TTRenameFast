//
//  AppDelegate.m
//  RenameFast
//
//  Created by 李曈 on 2018/5/17.
//  Copyright © 2018年 lt. All rights reserved.
//

#import "AppDelegate.h"
#import "RootView.h"

@interface AppDelegate ()
{
    NSFileManager *_fileManager;
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet RootView *mainView;
@property (weak) IBOutlet NSButton *selectBtn;
@property (weak) IBOutlet NSTextField *originFiled;
@property (weak) IBOutlet NSTextField *targetFiled;
@property (copy) NSString *filePath;
@property (copy) NSString *originStr;
@property (copy) NSString *targetStr;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _fileManager = [NSFileManager defaultManager];
}

- (IBAction)OpenFile:(id)sender {
    
    
}
- (IBAction)selectFile:(NSButton *)sender {
    [_originFiled resignFirstResponder];
    [_targetFiled resignFirstResponder];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    NSInteger finded = [panel runModal];
    
    if (finded == NSModalResponseOK) {
        if ([panel URLs].count > 0)
        {
            NSURL *fileUrl = [[panel URLs] firstObject];
            _filePath = [[fileUrl absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSString *newString = [_filePath stringByRemovingPercentEncoding];
            _filePath = newString;
            self.selectBtn.title = _filePath;
            NSLog(@"%@",newString);
        }
    }
    
}

- (void)createMainMenu
{
    
}
- (IBAction)startReplace:(id)sender {
    [self.window endEditingFor:_originFiled];
    [self.window endEditingFor:_targetFiled];
    _originStr = [_originFiled stringValue];
    _targetStr = [_targetFiled stringValue];
    if (_originStr.length == 0 || _targetStr.length == 0)
    {
        return;
    }
    [self readTargetFiles:_filePath];
}


- (void)readTargetFiles:(NSString *)filePath
{
    BOOL isDirectory = NO;
    BOOL isExist = [_fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isExist)
    {
        if (isDirectory)
        {
            NSArray *subs = [_fileManager contentsOfDirectoryAtPath:filePath error:nil];
            for (NSString *sub in subs)
            {
                NSString *subFilePath = [filePath stringByAppendingPathComponent:sub];
                [self readTargetFiles:subFilePath];
            }
        }
        else
        {
            if ([filePath hasSuffix:@".m"] || [filePath hasSuffix:@".h"])
            {
                NSString *filename = [[filePath componentsSeparatedByString:@"/"] lastObject];
                [self renameFile:filePath fileName:filename];
            }
        }
    }
}

- (void)renameFile:(NSString *)filePath fileName:(NSString *)fileName
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([fileName hasPrefix:_originStr])
    {
        NSString *newFileName = [fileName stringByReplacingCharactersInRange:NSMakeRange(0, _originStr.length) withString:_targetStr];
        NSRange range = [filePath rangeOfString:fileName];
        NSString *newFilePath = [filePath stringByReplacingCharactersInRange:range withString:newFileName];
        [_fileManager moveItemAtPath:filePath toPath:newFilePath error:nil];
    }
    [self performSelector:@selector(openAlertPanel) withObject:nil afterDelay:1.0];
}

- (void)openAlertPanel{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"修改完成"];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse returnCode){
                  }
     ];
}
#pragma mark - text filed



@end
