//

#import "QuizController.h"
@import AudioToolbox;

@implementation QuizController

@synthesize delegate,
            loadingQuizData,
            quizQuestion,
            quizStarted,
            quizData,
            quizWordList,
            hitWordList,
            quizTimer,
            quizTimerSecondsLimit,
            quizTimerMinutes,
            quizTimerSeconds,
            quizTimerSecondsClipped;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        quizStarted = NO;
        loadingQuizData = NO;
        
        hitWordList = [NSMutableArray new];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        quizTimerSecondsLimit = (int)[[infoDictionary objectForKey:@"QuizSecondsLimit"] integerValue];
        
        quizTimerSeconds = quizTimerSecondsLimit;
        quizTimerMinutes = quizTimerSeconds / 60;
        quizTimerSecondsClipped = quizTimerSeconds % 60;

    }
    
    return self;
}

- (void)loadQuizData {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *quizUrlString = [infoDictionary objectForKey:@"QuizURL"];
    
    NSURL *quizUrl = [NSURL URLWithString:quizUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:quizUrl];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
        
          self.loadingQuizData = NO;
                                      
          @try {
            if(error == nil) {
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSError *jsonError;
                    
                    self.quizData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    
                    if (jsonError != nil) {
                        // RETRY
                        NSException* exception = [NSException
                                                    exceptionWithName:@"Error"
                                                    reason:@"Error parsing json data!"
                                                    userInfo:nil];
                        @throw exception;
                    }
                    else {
                        NSString *question = [self.quizData objectForKey:@"question"];
                        NSArray *answer = [self.quizData objectForKey:@"answer"];
                        
                        if(question != nil && answer != nil) {
                            self.quizQuestion = [self.quizData objectForKey:@"question"];
                            self.quizWordList = answer;
                        }
                        else {
                            // RETRY
                            NSException* exception = [NSException
                                                      exceptionWithName:@"Error"
                                                      reason:@"Invalid data received!"
                                                      userInfo:nil];
                            @throw exception;
                        }
                        
                        
                        [self.delegate quizDataLoaded];
                        [self.delegate refreshUI];
                        
                    }
                }
                
                [self.delegate showLoading:NO];
            }
            else {
                // RETRY
                NSException* exception = [NSException
                                          exceptionWithName:@"Error"
                                          reason:@"Could not connect to server!"
                                          userInfo:nil];
                @throw exception;
            }
        }
        @catch(NSException *exception) {
            [self.delegate showLoading:NO];
            
            [self.delegate showEndMsg:exception.name message:exception.reason buttonMessage:@"Try Again"];
        }
                                      
        
    }];
    
    loadingQuizData = YES;
    [delegate showLoading:YES];

    [task resume];
}

- (void)startResetQuiz {
    // TRY RELOAD DATA LIST IN CASE OF AN
    // EXCEPTION THROWN BY loadQuizData METHOD
    if(self.quizWordList == nil) {
        [self loadQuizData];
        return;
    }

    quizStarted = !quizStarted;
    [hitWordList removeAllObjects];

    if(quizStarted) {
        quizTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimer:) userInfo:nil repeats:YES];
        
        [self countdownTimer:nil];
        
    }
    else {
        [quizTimer invalidate];

        quizTimerSeconds = quizTimerSecondsLimit;
        quizTimerMinutes = quizTimerSeconds / 60;
        quizTimerSecondsClipped = quizTimerSeconds % 60;

    }
    
    [delegate refreshUI];
    
}

- (void)countdownTimer:(NSTimer *)timer {
    quizTimerSeconds --;
    
    quizTimerMinutes = quizTimerSeconds / 60;
    quizTimerSecondsClipped = quizTimerSeconds % 60;
    
    [delegate updateUIValues];

    if(quizTimerSeconds == 0) {
        
        //
        [self loseGame];
        
    }
    
}

- (void)checkWord:(NSString*)word {
    for(id validWord in quizWordList) {
        NSString *wordString = validWord;
        NSString *wordCapitalized = [word capitalizedString];
        
        if([wordString isEqualToString:[word lowercaseString]]) {
            if(![self.hitWordList containsObject:wordCapitalized]) {
                
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

                [self.hitWordList addObject:wordCapitalized];
                
                [self.delegate clearTextField];
                [self.delegate valueInserted];
                [self.delegate updateUIValues];

                if(self.hitWordList.count == self.quizWordList.count) {
                    
                    //
                    [self winGame];
                    
                }
            }
        }
    }
    
}

- (void)loseGame {
    [quizTimer invalidate];
    
    NSString *endString = [NSString stringWithFormat:@"Sorry, time is up! You got %i out of %02i answers.", (int)self.hitWordList.count, (int)self.quizWordList.count];
    
    [self.delegate showEndMsg:@"Time finished" message:endString buttonMessage:@"Try Again"];
}

- (void)winGame {
    [quizTimer invalidate];
    
    [self.delegate showEndMsg:@"Congratulations" message:@"Good job! You found all the answers on time. Keep up with the great work." buttonMessage:@"Play Again"];
    
}

@end
