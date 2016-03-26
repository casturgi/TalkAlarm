//
//  MathSnooze.m
//  TalkAlarm
//
//  Created by cory Sturgis on 3/10/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "MathSnooze.h"
#import "SnoozeRoutingViewController.h"

@implementation MathSnooze 

-(void)awakeFromNib{
    [super awakeFromNib];

    [self generateRandomMathProblem];

}

-(void)willMoveToSuperview:(UIView *)newSuperview{

    self.numberOfCorrectProblems = 0;

    self.numberOfCorrectProblemsLabel.text = [NSString stringWithFormat:@"%d/%d Complete", self.numberOfCorrectProblems, self.numberOfProblems];

}



//set it to just +, -, x operators no division so that the answer will always be a whole number
-(void)generateRandomMathProblem{
    self.num1 = arc4random_uniform(11);
    self.num2 = arc4random_uniform(11);
    self.num3 = arc4random_uniform(11);
    self.op1 = arc4random_uniform(3);
    self.op2 = arc4random_uniform(3);
    NSString *op1 = [NSString new];
    NSString *op2 = [NSString new];

    if (self.op1 == 0) {
        op1 = [NSString stringWithFormat:@"+"];
    } else if (self.op1 == 1){
        op1 = [NSString stringWithFormat:@"-"];
    } else if (self.op1 == 2){
        op1 = [NSString stringWithFormat:@"x"];
    }

    if (self.op2 == 0) {
        op2 = [NSString stringWithFormat:@"+"];
    } else if (self.op2 == 1){
        op2 = [NSString stringWithFormat:@"-"];
    } else if (self.op2 == 2){
        op2 = [NSString stringWithFormat:@"x"];
    }

    self.randomMathProblemLabel.text = [NSString stringWithFormat:@"%d %@ %d %@ %d", self.num1, op1, self.num2, op2, self.num3];

    if (self.op1 == 0 && self.op2 == 0) {
        self.solution = self.num1 + self.num2 + self.num3;
    } else if (self.op1 == 0 && self.op2 == 1){
        self.solution = self.num1 + self.num2 - self.num3;
    } else if (self.op1 == 0 && self.op2 == 2){
        self.solution = self.num1 + (self.num2 * self.num3);
    }
    else if (self.op1 == 1 && self.op2 == 0){
        self.solution = self.num1 - self.num2 + self.num3;
    } else if (self.op1 == 1 && self.op2 == 1){
        self.solution = self.num1 - self.num2 - self.num3;
    } else if (self.op1 == 1 && self.op2 == 2){
        self.solution = self.num1 - (self.num2 * self.num3);
    }
    else if (self.op1 == 2 && self.op2 == 0){
        self.solution = (self.num1 * self.num2) + self.num3;
    } else if (self.op1 == 2 && self.op2 == 1){
        self.solution = (self.num1 * self.num2) - self.num3;
    } else if (self.op1 == 2 && self.op2 == 2){
        self.solution = self.num1 * self.num2 * self.num3;
    }

    self.answerAssigner = arc4random_uniform(2);

    if (self.answerAssigner == 0) {
        [self.answerOneButton setTitle:[NSString stringWithFormat:@"%d", self.solution] forState:UIControlStateNormal];
        [self.answerTwoButton setTitle:[NSString stringWithFormat:@"%d", self.solution + 1] forState:UIControlStateNormal];
        [self.answerThreeButton setTitle:[NSString stringWithFormat:@"%d", self.solution - 5] forState:UIControlStateNormal];
    } else if (self.answerAssigner == 1){
        [self.answerOneButton setTitle:[NSString stringWithFormat:@"%d", self.solution -3] forState:UIControlStateNormal];
        [self.answerTwoButton setTitle:[NSString stringWithFormat:@"%d", self.solution] forState:UIControlStateNormal];
        [self.answerThreeButton setTitle:[NSString stringWithFormat:@"%d", self.solution -1] forState:UIControlStateNormal];
    } else if (self.answerAssigner == 2){
        [self.answerOneButton setTitle:[NSString stringWithFormat:@"%d", self.solution - 1] forState:UIControlStateNormal];
        [self.answerTwoButton setTitle:[NSString stringWithFormat:@"%d", self.solution + 2] forState:UIControlStateNormal];
        [self.answerThreeButton setTitle:[NSString stringWithFormat:@"%d", self.solution] forState:UIControlStateNormal];
    }
}

- (IBAction)onAnswerOnePressed:(UIButton *)sender {

    NSLog(@"passed number: %d", self.numberOfProblems);

    NSString *answer = [NSString stringWithFormat:@"%d", self.solution];
    NSString *btnTitle = [NSString stringWithFormat:@"%@", sender.titleLabel.text];

    if ([answer isEqualToString:btnTitle]) {
        //check to see if they have answered the required number of problems correctly and dismiss if true
        if ((self.numberOfProblems - 1) == self.numberOfCorrectProblems) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
            self.window.rootViewController = viewController;
            [self.window makeKeyAndVisible];
        } else {
            //add one to number of correct problems and generate an new math problem
            self.numberOfCorrectProblems++;
            self.numberOfCorrectProblemsLabel.text = [NSString stringWithFormat:@"%d/%d Complete", self.numberOfCorrectProblems, self.numberOfProblems];
            [self generateRandomMathProblem];
        }

    } else {
        // generate a new math problem
        [self generateRandomMathProblem];
    }
}
- (IBAction)onAnswerTwoPressed:(UIButton *)sender {
    NSString *answer = [NSString stringWithFormat:@"%d", self.solution];
    NSString *btnTitle = [NSString stringWithFormat:@"%@", sender.titleLabel.text];

    if ([answer isEqualToString:btnTitle]) {
        //check to see if they have answered the required number of problems correctly and dismiss if true
        if ((self.numberOfProblems - 1) == self.numberOfCorrectProblems) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
            self.window.rootViewController = viewController;
            [self.window makeKeyAndVisible];
        } else {
            //add one to number of correct problems and generate an new math problem
            self.numberOfCorrectProblems++;
            self.numberOfCorrectProblemsLabel.text = [NSString stringWithFormat:@"%d/%d Complete", self.numberOfCorrectProblems, self.numberOfProblems];
            [self generateRandomMathProblem];
        }

    } else {
        // generate a new math problem
        [self generateRandomMathProblem];
    }
}
- (IBAction)onAnswerThreePressed:(UIButton *)sender {
    NSString *answer = [NSString stringWithFormat:@"%d", self.solution];
    NSString *btnTitle = [NSString stringWithFormat:@"%@", sender.titleLabel.text];

    if ([answer isEqualToString:btnTitle]) {
        //check to see if they have answered the required number of problems correctly and dismiss if true
        if ((self.numberOfProblems - 1) == self.numberOfCorrectProblems) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
            self.window.rootViewController = viewController;
            [self.window makeKeyAndVisible];
        } else {
            //add one to number of correct problems and generate an new math problem
            self.numberOfCorrectProblems++;
            self.numberOfCorrectProblemsLabel.text = [NSString stringWithFormat:@"%d/%d Complete", self.numberOfCorrectProblems, self.numberOfProblems];
            [self generateRandomMathProblem];
        }

    } else {
        // generate a new math problem
        [self generateRandomMathProblem];
    }
}



-(void)returnToInitialViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}



@end
