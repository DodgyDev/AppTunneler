//
//  ATBrowserViewController.m
//  App Tunneler
//
//  Created by Lucas Chen on 4/3/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ATBrowserViewController.h"
#import "ATProxyViewController.h"
#import "ATGeneralSettingsViewController.h"
#import "ATSettingsManager.h"
#import "ATFavoritesViewController.h"
#import <Security/SecTrust.h>
#import <AWSDK/AWCommandManager.h>
#import "ATCertificateHandler.h"

@interface ATBrowserViewController (){
    NSMutableData *webdata;
    BOOL _authed;
    NSTimer *timer;
    NSURLConnection *currentConnection;
    CGRect originalTextFrame;
    ATProxyViewController *proxyController;
    ATGeneralSettingsViewController *generalSettingsController;
    UITableView *favoritesView;
    ATFavoritesViewController *favoritesController;
}

@end

@implementation ATBrowserViewController
@synthesize Txt_Address, WebView, Btn_Settings, Act_Loading, Btn_Home, Btn_Back, Btn_Forward, Btn_Favorites, Btn_Refresh;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Initializations
        _authed = NO;   //Set auth to start as no, tracks if we've authenticated to an auth required website yet
        favoritesController = [[ATFavoritesViewController alloc] init];
    }
    return self;
}

#pragma mark General Delegates

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    proxyController = [[ATProxyViewController alloc] init];
    generalSettingsController = [[ATGeneralSettingsViewController alloc] init];
    
    [self InitializeUI];
    [self Home];
    
}

-(void)viewWillAppear:(BOOL)animated{
    originalTextFrame = Txt_Address.frame;
    [self InitializeUIFrameSensitive];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    _Address = Txt_Address.text;
    _authed = NO;
    [self LoadURL];
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGRect frameRect = Txt_Address.frame;
    
    frameRect.size.width = self.view.window.frame.origin.x + self.view.window.frame.size.width-20;
    frameRect.origin.x = self.view.window.frame.origin.x+10;
    
    [Btn_Back setHidden:YES];
    [Btn_Forward setHidden:YES];
    [Btn_Refresh setHidden:YES];
    Txt_Address.frame = frameRect;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [Txt_Address setFrame:originalTextFrame];
    
    [Btn_Back setHidden:NO];
    [Btn_Forward setHidden:NO];
    [Btn_Refresh setHidden:NO];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark Web Delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSLog(@"Did start loading: %@ auth:%d", [[request URL] absoluteString], _authed);
    
    if (!_authed) { //If not authenticated
        _authed = NO;
        currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    
    NSLog(@"got auth challenge: %@", [challenge.protectionSpace.authenticationMethod description]);
    
    
    if(challenge.failureResponse){
        NSLog(@"%@", [challenge failureResponse]);
    }
    
    if(challenge.previousFailureCount==0) {
        
        //Client cert challenge received. Handle it.
        if(challenge.protectionSpace.authenticationMethod==NSURLAuthenticationMethodClientCertificate){
            
            //Check if we are using SDK, otherwise we don't have a cert to present.
            if([[ATSettingsManager sharedInstance] GetSDKStatus]){
                
                NSData *certData = [[ATCertificateHandler sharedInstance] readCertificateFromFile];
                NSString* certPass = [[ATCertificateHandler sharedInstance] GetCertificatePassword];
                
                SecIdentityRef identity = [[ATCertificateHandler sharedInstance] certificateInformationFromCertificate:certData password:certPass];
                
                SecCertificateRef certificate = NULL;
                SecIdentityCopyCertificate(identity, &certificate);
                
                const void *certs[] = {certificate};
                CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);

                NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            
                return;

            }else{
                [challenge.sender rejectProtectionSpaceAndContinueWithChallenge:challenge];
            }
            
        }else if(challenge.protectionSpace.authenticationMethod==NSURLAuthenticationMethodServerTrust){
            
            //ignore server trust, we'll take whatever for now
            [challenge.sender useCredential:[NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust] forAuthenticationChallenge: challenge];
            return;
            
        }
    }else{
        [challenge.sender useCredential:[self HandleCredentials:[[[[connection currentRequest] URL] host] description]] forAuthenticationChallenge:challenge];
        _authed = YES;
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }

    if ([challenge previousFailureCount] == 0) {
        
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
            _authed = YES;
        }else{

        }
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Auth Failed" message:@"Authentication Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] show];
        _authed = NO;
        [Act_Loading setHidden:YES];
    }*/
    
}


- (OSStatus)extractIdentity:(CFDataRef)inP12Data :(SecIdentityRef*)identity {
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = CFSTR("MyCertificatePassword");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _authed = YES;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_Address] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    [WebView loadRequest:request];
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] show];
    [Act_Loading setHidden:YES];
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    if((protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate)||(protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM)||(protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault)){
     
        return YES;
        
    }
    
    return NO;
    
    /*
    NSLog(@"Presenting protect space: %@", [protectionSpace.authenticationMethod description]);
    
    return NO;
    
    BOOL ret = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] | [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]| [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM];
    return ret;*/
}

-(BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    // webView connected
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
    [Act_Loading setHidden:NO];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [timer invalidate];
    
    if([WebView canGoBack]){
        [Btn_Back setEnabled:YES];
    }else{
        [Btn_Back setEnabled:NO];
    }
    
    if([WebView canGoForward]){
        [Btn_Forward setEnabled:YES];
    }else{
        [Btn_Forward setEnabled:NO];
    }
    
    Txt_Address.text = WebView.request.URL.absoluteString;
    [Act_Loading setHidden:YES];
    
}

#pragma mark Button Events
- (IBAction)Btn_Refresh:(id)sender {
    [WebView reload];
}

- (IBAction)Btn_Forward:(id)sender {
    if([WebView canGoForward]){
        [WebView goForward];
    }
}

- (IBAction)Btn_Home:(id)sender {
    [[AWCommandManager sharedManager] loadCommands];
    //[self Home];
}

- (IBAction)Btn_Settings:(id)sender {
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.tabBar.layer.borderColor = [UIColor darkGrayColor].CGColor;
    tabController.tabBar.layer.borderWidth = 2.0;
    
    NSArray *tabViews = @[generalSettingsController, proxyController];
    [tabController setViewControllers:tabViews];
    [tabController setSelectedIndex:0];
    
    [self presentViewController:tabController animated:YES completion:^{
        generalSettingsController.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
        generalSettingsController.view.layer.borderWidth = 2.0;
        proxyController.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
        proxyController.view.layer.borderWidth = 2.0;
    }];
}

- (IBAction)Btn_Back:(id)sender {
    if([WebView canGoBack]){
        [WebView goBack];
    }
}

- (IBAction)Btn_Favorites:(id)sender {
    
    //If favorites menu is already open, close it.
    if(WebView.frame.origin.x!=0){
        self.WebView.userInteractionEnabled = YES;
        CGRect frame = WebView.frame;
        frame.origin.x = 0;
        favoritesView.hidden = YES;
        [WebView setFrame:frame];
        Btn_Favorites.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }else{
        self.WebView.userInteractionEnabled = NO;
        Btn_Favorites.layer.backgroundColor = [UIColor yellowColor].CGColor;
        favoritesView.hidden = NO;
        CGRect frame = WebView.frame;
        frame.origin.x+= frame.size.width*3/4;
        [WebView setFrame:frame];
    }
    
}

- (IBAction)Btn_Go:(id)sender {
    _Address = Txt_Address.text;
    _authed = NO;
    [self LoadURL];
    [self.view endEditing:YES];
}

#pragma mark Web Navigation

//Go home
-(void)Home{
    _Address = [[ATSettingsManager sharedInstance] GetHomeAddress];
    
    if(!_Address || [_Address isEqualToString:@""]){
        _Address = @"http://www.google.com";
    }
    
    Txt_Address.text = _Address;
    [self LoadURL];
}

//Load URL with current address instance variable
-(void)LoadURL{
    
    if(![_Address isEqualToString:@""]){
        [Act_Loading setHidden:NO];
        
        NSString *formattedURL;
        if(![[_Address lowercaseString] hasPrefix:@"http://"]&&![[_Address lowercaseString] hasPrefix:@"https://"]){
            formattedURL = [NSString stringWithFormat:@"http://%@", _Address];
            _Address = formattedURL;
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_Address]];
        [WebView loadRequest:request];
    }
}

//Load URL with address parameter, will set _address to input parameter
-(void)LoadURLWithAddress:(NSString *)url{
    [self.WebView setUserInteractionEnabled:YES];
    _Address = url;
    _authed = 0;
    [self LoadURL];
    if(WebView.frame.origin.x!=0){
        CGRect frame = WebView.frame;
        frame.origin.x = 0;
        favoritesView.hidden = YES;
        [WebView setFrame:frame];
        Btn_Favorites.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }else{
        Btn_Favorites.layer.backgroundColor = [UIColor yellowColor].CGColor;
        favoritesView.hidden = NO;
        CGRect frame = WebView.frame;
        frame.origin.x+= frame.size.width*3/4;
        [WebView setFrame:frame];
    }
    
}

#pragma mark Helpers
//UI Initializations
-(void)InitializeUI{
    
    [Btn_Back setEnabled:NO];
    [Btn_Forward setEnabled:NO];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.view.layer.borderWidth = 2.0;
    
    WebView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    WebView.layer.borderWidth = 2.0;
    WebView.layer.cornerRadius = 2.0;
    WebView.delegate = self;
    
    Txt_Address.delegate = self;
    Txt_Address.layer.borderWidth = 2.0;
    Txt_Address.layer.borderColor = [UIColor darkGrayColor].CGColor;
    Txt_Address.layer.cornerRadius = 2.0;
    Txt_Address.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [Btn_Favorites setTitle:@"\u2606" forState:UIControlStateNormal];
    Btn_Favorites.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Favorites.layer.cornerRadius = 10.0;
    Btn_Favorites.layer.borderWidth = 2.0;
    Btn_Favorites.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Favorites setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [Btn_Home setTitle:@"\u2302" forState:UIControlStateNormal];
    Btn_Home.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Home.layer.cornerRadius = 10.0;
    Btn_Home.layer.borderWidth = 2.0;
    Btn_Home.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Home setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [Btn_Back setTitle:@"\u276c" forState:UIControlStateNormal];
    Btn_Back.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Back.layer.cornerRadius = 10.0;
    Btn_Back.layer.borderWidth = 2.0;
    Btn_Back.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Back setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [Btn_Forward setTitle:@"\u276f" forState:UIControlStateNormal];
    Btn_Forward.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Forward.layer.cornerRadius = 10.0;
    Btn_Forward.layer.borderWidth = 2.0;
    Btn_Forward.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Forward setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    Btn_Settings.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Settings.layer.cornerRadius = 10.0;
    Btn_Settings.layer.borderWidth = 2.0;
    Btn_Settings.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Settings setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [Btn_Settings setTitle:@"\u2699" forState:UIControlStateNormal];
    
    Btn_Refresh.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Refresh.layer.cornerRadius = 10.0;
    Btn_Refresh.layer.borderWidth = 2.0;
    Btn_Refresh.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Refresh setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [Btn_Refresh setTitle:@"\u21bb" forState:UIControlStateNormal];
    
    [Act_Loading setHidden:YES];
    [Act_Loading startAnimating];
}

//UI Initializations for elements that rely on frame settings, frame settings are unreliable when called during ViewDidLoad
-(void)InitializeUIFrameSensitive{
    favoritesView = [[UITableView alloc] init];
    favoritesView.delegate = favoritesController;
    favoritesView.dataSource = favoritesController;
    favoritesView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    favoritesView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    favoritesView.layer.borderWidth = 2.0;
    favoritesController.browser = self;
    CGRect favoritesFrame = WebView.frame;
    favoritesFrame.size.width = WebView.frame.size.width*3/4+2;
    [favoritesView setFrame:favoritesFrame];
    [self.view addSubview:favoritesView];
    favoritesView.hidden = YES;
}

//Helper method for throwing up credentials during 401 auth challenge
-(NSURLCredential*)HandleCredentials:(NSString*)url{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Required" message:url delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    NSDate *d;
    while ([alert isVisible]) {
        d = [[NSDate alloc] init];
        [rl runUntilDate:d];
    }
    
    NSString *username = [[alert textFieldAtIndex:0] text];
    NSString *password = [[alert textFieldAtIndex:1] text];
    
    return [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
}

//Called when request times out
-(void)cancelWeb{
    //TODO: Needs to handle timeouts
}

@end
