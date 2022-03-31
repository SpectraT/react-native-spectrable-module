# react-native-spectrable-module

ble

## Installation

```sh
npm install react-native-spectrable-module
```

## Usage: Steps to install this module and to run iOS Project:

1. Run the command in the main project directory to install the spectra react native npm into your project:
        npm i react-native-spectrable-module

2. Post installing this package, update the pods in the project by running this command in the main project directory to install the required dependencies : 
        npx pod-install ios

3. Once this pods get installed, do run the iOS project in Xcode by opening the “.xcworkspace” file

4. While running the project if you get errors like: “SpectraBLE/SpectraBLE-Swift.h' file not found” then you have to perform the following steps to solve this error:
        
        Choose Pods target
        Go to Development Pods folder
        Check for “react-native-spectrable-module”
        Select “SpectraBLE.xcframework” and open it in finder
        Select Pods target
        Choose “react-native-spectrable-module” target there
        Choose Build Phases tab from top and drag and drop “SpectraBLE.xcxcframework”  to Link Binary with Libraries

    Error should be gone.

5. Again build the project and if you face the swift-interface files errors then you have to follow below steps:

        Choose Pods target
        Go to Development Pods folder
        Choose react-native-spectrable-module
        Check for  “SpectraBLE.xcframework” and go to this directory in terminal and run below command: 
            
            find . -name "*.swiftinterface" -exec sed -i -e 's/SpectraBLE\.//g' {} \;

    Swift-Interface errors should be gone.

8. import { SpectrableModule } from 'react-native-spectrable-module' to the file where you want to use the methods of this module.



## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
