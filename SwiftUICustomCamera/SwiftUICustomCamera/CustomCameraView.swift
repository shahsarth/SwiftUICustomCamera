//
//  CustomCameraView.swift
//  SwiftUICustomCamera
//
//  Created by Sarth Shah on 2/18/22.
//

import SwiftUI
import AVFoundation
 
public var screenWidth = UIScreen.main.bounds.width
public var screenHeight = UIScreen.main.bounds.height

struct CustomCameraPhotoView: View {
    @State private var image: Image?
    @State private var showingCustomCamera = false
    @State private var inputImage: UIImage?
    @State var didTapCapture: Bool = false
    
    
    var body: some View {
        
        // If picture is taken, show full screen picture with x and top left corner and Add to bottom right corner (add to bottom right corner is a nav view to modal that shows picture and then your activity journeys
        // If picture is not taken show full screen camera view . Have capture button superimposed. Have flash button on left and rotate camera button on right
        NavigationView {
            VStack {
                                    
                if inputImage != nil
                {
                    ZStack {
                        Image(uiImage: inputImage!)
                            .resizable()
                            //.frame(width: screenWidth, height: screenHeight, alignment: .top)
                            .aspectRatio(contentMode: .fill)
                            .edgesIgnoringSafeArea(.top)
                            .cornerRadius(10)
                            //.layoutPriority(-1)
                        VStack {
                            HStack {
                                Button(action: {
                                    self.inputImage = nil
                                    print("pressing button")
                                        
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .padding(20)
//                                        .border(.pink)
                                }
                                Spacer()
                            }
//                            .border(.white)
                            Spacer()
                            HStack {
                                Spacer()
                                //Button Add to (which navs to new screen)
                                NavigationLink(destination: Text("Do whatever Image Processing/Saving/Sending here")){
                                    ButtonView()
                                }
                                
                            }
                        }
                        //.frame(width: screenWidth, height: screenHeight, alignment: .center)
                            //.edgesIgnoringSafeArea([.top])
//                            .border(.green)
                    }
//                    .border(.orange)
                    //.frame(width: screenWidth, height: screenHeight)
                    
                }
                    
                else
                {
                    VStack{
                        CustomCameraView(image: $inputImage, didTapCapture: didTapCapture)
                            //.frame(width: screenWidth, height: screenHeight - 160)
                            .edgesIgnoringSafeArea([.top])
                            .cornerRadius(10)
                            //.padding(.bottom, 100)
                    }
                }
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct ButtonView: View {
    var body: some View {
        ZStack{
            Capsule()
                .fill(Color.orange)
                
            HStack{
                Text("Send to")
                    .font(.body)
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.body)
            }.foregroundColor(.white)
        }.frame(width: 120, height: 40)
            .padding()
       
    }
    
}

struct CustomCameraView: View {
    
    @Binding var image: UIImage?
    @State var didTapCapture: Bool = false
    @State var didTapSwitch: Bool = false
    var body: some View {
        VStack {
            GeometryReader { (geometry) in
                            
                ZStack(alignment: .bottom) {
                    
                    CustomCameraRepresentable(image: self.$image, didTapCapture: $didTapCapture, didTapSwitch: $didTapSwitch, framesize: CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height))
                    HStack{
                        CaptureButtonView().onTapGesture {
                            self.didTapCapture = true
                        }
//                        Image(systemName: "arrow.triangle.2.circlepath.camera").onTapGesture {
//                            self.didTapSwitch = true
//                            print("variable is changed")
//                        }
                    }
                    
                }.padding(.bottom, 20)
            }
        }
    }
    
}


struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    //@Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    @Binding var didTapSwitch: Bool
    var framesize : CGRect
    //var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        
        return controller
    }
    
    // from SwiftUI to UIKit
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        
        if(self.didTapCapture) {
            cameraViewController.didTapRecord()
        }
        
        if(self.didTapSwitch) {
            cameraViewController.didTapSwitch()
        }
        
        
        //self.cameraPreviewLayer = cameraViewController.cameraPreviewLayer
    }
    // from UIKit to SwiftUI
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, framesize: self.framesize)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CustomCameraRepresentable
        var framesize : CGRect
        
        init(_ parent: CustomCameraRepresentable, framesize: CGRect) {
            self.parent = parent
            self.framesize = framesize
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
            parent.didTapCapture = false
            
            if let imageData = photo.fileDataRepresentation() {
                parent.image = UIImage(data: imageData)
                
               
                
            }
            
        }
    }
}

class CustomCameraController: UIViewController {
    
    var image: UIImage?
    
    // Capture Session
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    //Photo Output
    var photoOutput: AVCapturePhotoOutput?
    
    //Video Preview
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //DELEGATE
    var delegate: AVCapturePhotoCaptureDelegate?
    
    func didTapRecord() {
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
        
    }
    
    func didTapSwitch() {
        print("i'm in did tap switch")
        if self.currentCamera == self.backCamera {
            self.currentCamera = self.frontCamera
        } else {
            self.currentCamera = self.backCamera
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: AVCaptureDevice.Position.unspecified)
        for device in deviceDiscoverySession.devices {
            
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        
        self.currentCamera = self.backCamera
    }
    
    
    func setupInputOutput() {
        do {
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
        
    }
    

    
    func setupPreviewLayer()
    {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        //Currently I hardcoded height to a smaller amount because before it was
//        self.cameraPreviewLayer?.frame = self.view.frame
        // However, this was taking up the full screen and even taking over the tab bar and making it dissapear. So the 80 padding is the space for tab bar
         self.cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 80)
//        self.cameraPreviewLayer?.frame = self.view.bounds
        //self.cameraPreviewLayer?.anchorPoint = videoLayer.bounds.origin
        //self.cameraPreviewLayer?.frame = CGRect(x: videoLayer.bounds.origin.x, y: videoLayer.bounds.origin.y, width: videoLayer.frame.size.width, height: videoLayer.frame.size.height)
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
}


struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 65, height: 65)
            Circle()
                .stroke(Color.white)
                .frame(width: 75, height: 75)
        }
    }
}
