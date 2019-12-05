//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QuizControllerDelegate <NSObject>
@optional
- (void)showLoading:(BOOL)show;
- (void)quizDataLoaded;

- (void)refreshUI;
- (void)updateUIValues;
- (void)valueInserted;

- (void)showEndMsg:(NSString *)title message:(NSString *)message buttonMessage:(NSString*)buttonMessage;
- (void)clearTextField;
@end

@interface QuizController : NSObject  {
    BOOL loadingQuizData;
    BOOL quizStarted;
    
    NSDictionary *quizWords;
    
    NSTimer *quizTimer;
    int quizTimerSecondsLimit;
    int quizTimerMinutes;
    int quizTimerSeconds;
    int quizTimerSecondsClipped;
}

@property (nonatomic, weak) id <QuizControllerDelegate> delegate;

@property (nonatomic, assign) NSString *quizQuestion;

@property (nonatomic, assign) BOOL loadingQuizData;
@property (nonatomic, assign) BOOL quizStarted;

@property (nonatomic, retain) NSDictionary *quizData;
@property (nonatomic, retain) NSArray *quizWordList;
@property (nonatomic, retain) NSMutableArray *hitWordList;

@property (nonatomic, retain) NSTimer *quizTimer;
@property (nonatomic, assign) int quizTimerSecondsLimit;
@property (nonatomic, assign) int quizTimerMinutes;
@property (nonatomic, assign) int quizTimerSeconds;
@property (nonatomic, assign) int quizTimerSecondsClipped;

- (instancetype)init;

- (void)loadQuizData;
- (void)startResetQuiz;
- (void)checkWord:(NSString*)word;

@end

NS_ASSUME_NONNULL_END
