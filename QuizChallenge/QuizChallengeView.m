//

#import "QuizChallengeView.h"
#import "QuizController.h"

@interface QuizChallengeView () <QuizControllerDelegate>

@end

@implementation QuizChallengeView

@synthesize quizController,
            quizLoadingView,
            bottomLayoutConstraint,
            quizQuestion,
            quizWordTextField,
            quizWordsTableView,
            labelWordsCounter,
            labelTimerCounter,
            quizStartResetButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerEvents];
    
    //
    quizWordsTableView.delegate = self;
    quizWordsTableView.dataSource = self;
    
    //
    quizController = [QuizController new];
    quizController.delegate = self;
    
    [quizController loadQuizData];

}

-(void)viewWillDisappear:(BOOL)animated {
    [self removeKeyboardEvents];
    
}

- (void)registerEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowCallback:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideCallback:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [quizWordTextField setDelegate:self];
    
    [quizWordTextField addTarget:self
                  action:@selector(quizWordTextFieldChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [quizWordsTableView addGestureRecognizer:singleTap];
    
}

- (void)removeKeyboardEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)keyboardDidShowCallback:(NSNotification*)notification {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if(UIDeviceOrientationIsFlat(deviceOrientation) || UIDeviceOrientationIsPortrait(deviceOrientation)) {
        NSDictionary *userInfo = notification.userInfo;
        
        CGSize keyboardSize = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        bottomLayoutConstraint.constant = -keyboardSize.height;
    }
    
}

- (void)keyboardWillHideCallback:(NSNotification*)notification {
    bottomLayoutConstraint.constant = 0;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [quizWordTextField resignFirstResponder];
    
    return YES;
    
}

- (BOOL)quizWordTextFieldChange:(id)sender {
    //
    [quizController checkWord:quizWordTextField.text];
    
    return YES;
    
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    [self.quizWordTextField resignFirstResponder];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (int)quizController.hitWordList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *hitWordListTableItem = @"HitWordTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hitWordListTableItem];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hitWordListTableItem];
    }
    
    cell.textLabel.text = [quizController.hitWordList objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (IBAction)startResetQuiz:(id)sender {
    [quizController startResetQuiz];
    
}

- (void)showEndMsg:(NSString *)title message:(NSString *)message buttonMessage:(NSString*)buttonMessage {
    
    // CLEAR TEXT FIELD FIRST
    [self.quizWordTextField setEnabled:NO];
    [self.quizWordTextField resignFirstResponder];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionButton = [UIAlertAction
                          actionWithTitle:buttonMessage
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self.quizController startResetQuiz];
                          }];
    
    [alert addAction:actionButton];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

- (void)quizDataLoaded {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.quizQuestion setText:self.quizController.quizQuestion];
    });
    
}

- (void)showLoading:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.quizLoadingView setHidden:!show];
    });
    
}

- (void)refreshUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.quizController.loadingQuizData) {
            [self.quizLoadingView setHidden:NO];
        }
        else {
            [self.quizLoadingView setHidden:YES];
        }
        
        if(self.quizController.quizStarted) {
            [self.quizWordTextField setEnabled:YES];
            [self.quizWordTextField setPlaceholder:@"Insert Word"];
            [self.quizWordTextField becomeFirstResponder];
            
            [self.quizStartResetButton setTitle:@"Reset" forState:UIControlStateNormal];
        }
        else {
            [self.quizWordTextField setEnabled:NO];
            [self.quizWordTextField setPlaceholder:@"Press Start"];
            [self.quizWordTextField setText:@""];
            [self.quizWordTextField resignFirstResponder];
            
            [self.quizStartResetButton setTitle:@"Start" forState:UIControlStateNormal];
            
            [self.quizWordsTableView reloadData];
        }
        
        [self updateUIValues];
    });
}

- (void)updateUIValues {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *wordCount = [NSString stringWithFormat:@"%02d", (int)self.quizController.quizWordList.count];
        NSString *hitWordCount = [NSString stringWithFormat:@"%02d", (int)self.quizController.hitWordList.count];
        
        // HITS
        [self.labelWordsCounter setText:[NSString stringWithFormat:@"%@/%@", hitWordCount, wordCount]];
        
        // TIMER
        [self.labelTimerCounter setText:[NSString stringWithFormat:@"%02i:%02i", (int) self.quizController.quizTimerMinutes, (int) self.quizController.quizTimerSecondsClipped]];
        
        [self.quizWordsTableView reloadData];
        
        
    });
    
}

- (void)valueInserted {
    
    [self.quizWordsTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];

}

- (void)clearTextField {
    [self.quizWordTextField setText:@""];
    
}

@end
