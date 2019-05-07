
@import CoreText;

@interface TFNAttributedTextModel: NSObject
@property (nonatomic, strong) NSAttributedString *attributedString;
@end

@interface TFNAttributedTextView: UIView

@property (nonatomic, strong) TFNAttributedTextModel *textModel;

- (void)setTextModel:(TFNAttributedTextModel *)model;
@end

@interface T1StatusBodyTextView : UIView  {
	TFNAttributedTextView *_bodyTextView;
}
@end

@interface T1URTTimelineStatusItemViewModel : NSObject
@property(nonatomic, readonly) NSString *text;
@property(nonatomic, readonly) NSString *fromUserName;
@property(nonatomic, readonly) long long fromUserID;
@end

@interface TFNTwitterAccount : NSObject
@end

@interface TFNTwitterUser : NSObject
@property(readonly) NSString *username;
@end

@interface T1StandardStatusView: UIView
@property(readonly, nonatomic) TFNTwitterAccount *account;
@property(readonly, nonatomic) T1StatusBodyTextView *visibleBodyTextView;
@property(readonly, nonatomic) id visibleConversationContextView;
@property(readonly, nonatomic) id visibleAvatarView;
@end

@interface TFNTwitterStatus : NSObject
@property(retain) TFNTwitterUser *fromUser;
@property(readonly) TFNTwitterStatus *representedStatus;
@property(readonly) NSString *textWithExpandedURLs;
@end

%hook T1StandardStatusView

- (void)setViewModel:(id)model options:(unsigned long long)arg2 account:(TFNTwitterAccount *)account {
	%orig;

	NSString *expandedText = @"";
	NSString *username = @"";

	if([model isKindOfClass:%c(TFNTwitterStatus)]) {
		expandedText = ((TFNTwitterStatus *) model).textWithExpandedURLs;
		username = ((TFNTwitterStatus *) model).fromUser.username;
	} else if ([model isKindOfClass:%c(T1URTTimelineStatusItemViewModel)]) {
		expandedText = ((T1URTTimelineStatusItemViewModel *) model).text;
		username = ((T1URTTimelineStatusItemViewModel *) model).fromUserName;	
	}

	if(self.visibleBodyTextView) {
		if([username containsString:@"realDonaldTrump"]){
			TFNAttributedTextView *textView = [self.visibleBodyTextView valueForKey:@"_bodyTextView"];
			TFNAttributedTextModel *textModel = textView.textModel;

			NSMutableAttributedString  *attrString = [[NSMutableAttributedString alloc] initWithString:expandedText];
			[attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DK Crayon Crumble" size:18] range:NSMakeRange(0, expandedText.length)];
			[attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.929 green:0.0392 blue:0.247 alpha:1] range:NSMakeRange(0, expandedText.length)]; 
			textModel.attributedString = attrString;
			[textView setTextModel:textModel];
		}
	}
	
}

%end

%ctor {
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([@"/Library/Application Support/drumpf/CrayonCrumble.ttf" UTF8String]);
		CGFontRef font = CGFontCreateWithDataProvider(dataProvider);
		CGDataProviderRelease(dataProvider);
		CTFontManagerRegisterGraphicsFont(font, nil);
		CGFontRelease(font);
	});
}