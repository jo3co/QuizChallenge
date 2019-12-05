//

#import <UIKit/UIKit.h>

@class QuizController;
@protocol QuizControllerDelegate;

@interface QuizChallengeView : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) QuizController *quizController;

@property (nonatomic, assign) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (nonatomic, assign) IBOutlet UIView *quizLoadingView;
@property (nonatomic, assign) IBOutlet UIButton *quizStartResetButton;
@property (nonatomic, assign) IBOutlet UITextField *quizWordTextField;
@property (nonatomic, assign) IBOutlet UITableView *quizWordsTableView;
@property (nonatomic, assign) IBOutlet UILabel *quizQuestion;
@property (nonatomic, assign) IBOutlet UILabel *labelWordsCounter;
@property (nonatomic, assign) IBOutlet UILabel *labelTimerCounter;

- (IBAction)startResetQuiz:(id)sender;

@end

