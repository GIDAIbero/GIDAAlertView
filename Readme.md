# Description

The GIDAAlertView class (very similar to the MBProgressHUD) is used to display a short message and show an icon (usually related to the message that's been displayed) to the user. The layout is very similar to what Mac OS X uses to show the "volume up" and the "volume down" notifications. As an option you can create a GIDAAlertView displaying a spinner and a message, the thread management is already done for you.

Currently supports iPhone, iPod and iPad hardware starting with iOS 5.

# Screenshots

![GIDAAlertView Custom]( http://cloud.github.com/downloads/ElDeveloper/GIDAAlertView/custom.png  )
![GIDAAlertView Spinner]( http://cloud.github.com/downloads/ElDeveloper/GIDAAlertView/spinner.png  )

# Usage

	//Just initalize the object
	GIDAAlertView *alertView;
	alertView=[[GIDAAlertView alloc] initAlertWithSpinnerAndMessage:@"GIDAAlertView Spinner"];
	alertView presetnAlertWithSpinner];

	//Later in your code
	[alertView hideAlertWithSpinner];

# Contact

If you have a question, suggestion or you just want to let me know about your project, reach me on my twitter: http://www.twitter.com/yosmark

# License

Copyright (c) 2012 Yoshiki Vázquez Baeza, http://yoshikee.tumblr.com/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.