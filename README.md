# Image Recognition through CoreML and ReactNative

## Set your project up to use Swift
If your project isn't yet setup to use Swift, there are a few final steps you need to go through:

1. In XCode, right click on your project, then on New File...
2. Choose a Swift file, click next
3. You'll then be asked if you want to create a bridging header - click yes to this
4. The module is written in Swift 4, so if you get errors compiling, go to your project's Build Settings in XCode, find Swift Language Version and make sure it is set to Swift 4.0

## Add a CoreML Model to your project
Next, you need to add a CoreML Model to your project.
Apple provides a number of open source models here - https://developer.apple.com/machine-learning/

We're in the process of writing a tutorial on how to create your own model using TuriCreate. Stay tuned for that.

Once you've downloaded, or created, a CoreML Model, rename it from .mlmodel to .mlmodelc and drop it into your XCode project (ensure that you add it to your main project target if offered the choice).

Go to the Build Phases tab of your project in XCode, and check that the model file you added is listed under the Copy Bundle Resources section. If not, add it.

## Using the component in your app
Using the component in your app is simple. First import the module:

```javascript
import CoreMLImage from "react-native-core-ml";
```

... then, add the component wherever you want it...

```javascript
    <CoreMLImage
        imageFile={pathToImage}
        modelFile="MyModelFile"
        onClassification={(evt) => this.onClassification(evt)}/>
```

You must provide a modelFile. This should be the name of the model file you added to your project without any suffix. E.g. if your model file was called MyModelFile.mlmodelc then you should set modelFile as MyModelFile.

Remember - the model file must have the file ending .mlmodelc to work.
