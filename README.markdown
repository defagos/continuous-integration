### What is continuous-integration?

continuous-integration is a shell script (and a companion command-line tool xcodeproj-info) meant to be used for continuous integration of iOS projects using Jenkins (http://jenkins-ci.org/). Simply set up a Jenkins job so that after its workspace has been checked out a script build phase runs continuous-integration.sh (from the directory where project files have been checked out):

* the script automatically detects the project to compile if there is only one project in the directory it is run from. If several projects have been checked out in the same directory, use the -p parameter to explicitly select the one to consider
* the script then extracts the list of the targets to build. If only some of the targets make sense, use the -t parameter
* the script then finds all configurations to build for each target (using the iOS SDK set for it)
* finally, the script builds all those configurations, in two flavors:
  * simulator binaries. A static analyzer check is performed
  * device binaries, using a code signing identity and a provisioning profile which have to be provided

Compilation logs are saved separately for each build run. The output of the script contains URLs pointing to the full compilation logs, as well as a log excerpt in case of build failure. You usually want to configure your Jenkins job so that this output is sent to your engineering team (most probably by email) for further investigation.

### How should I use continuous-integration?

On your Jenkins continuous integration server, install the continuous-integration.sh and xcodeproj-info tools to some location in the PATH. Ensure that the two following environment variables are properly set (how this is achieved depends on how you start the Jenkins process):

* CODE_SIGN_IDENTITY: The code signing identity to use (certificate)
* PROVISIONING_PROFILE: The identifier of the provisioning profile to use

Then configure your Jenkins jobs to call continuous-integration.sh from the worskpace directory where the projects to build are located. This is made by adding an "Execute shell" build step to each job configuration.

Note that all device binaries are built using the same identity and provisioning profile. If you need to automatically deploy binaries using other code signing parameters, you can use my sign-ipa tool (https://github.com/defagos/sign-ipa) to re-sign the binaries without building them again.

### xcodeproj-info

xcodeproj-info is a command-line tool for basic extraction of project information. This tool is currently fairly basic and will most probably replaced as better tools appear (see for example https://github.com/0xced/xcodeproj by Cédric Lüthi). Binaries for MacOS X 10.6 and above are available in the bin directory. The source code is available in the xcodeproj-info directory if needed.

### Working on continuous-integration.sh

During development, it is useful not to have to copy the script to your continuous integration server just for testing purposes. In the test directory, I wrote a small test.sh script with which you can easily test changes made to continuous-integration.sh without requiring a Jenkins installation.

### Release notes

#### Version 1.0
Initial release

### Contact
Feel free to contact me if you have any questions or suggestions:

* mail: defagos ((at)) gmail ((dot)) com
* Twitter: @defagos

Thanks for your feedback!

### Licence

Copyright (c) 2012 hortis le studio, Samuel Défago

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
