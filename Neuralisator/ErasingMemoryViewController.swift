//
//  ErasingMemoryViewController.swift
//  Neuralisator
//
//  Created by Danny Lin on 2016/5/12.
//  Copyright © 2016年 DL. All rights reserved.
//

import UIKit
import AVFoundation

class ErasingMemoryViewController: UIViewController {

    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var livePreview: UIView!

    var backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var timer = Timer()

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    var neuralyzerSound = URL(fileURLWithPath: Bundle.main.path(forResource: "mib_neuralyzer", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()


    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewDidLoad")

        initialize()
    }

    func initialize() {
        restoreButton.isHidden = true

        setupLivePreview()
        setupSounds()
    }

    func setupLivePreview() {
        // Input session: 用來暫存照片
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)

            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)

                // Output photo
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

                if captureSession!.canAddOutput(stillImageOutput) {
                    captureSession!.addOutput(stillImageOutput)

                    // Live preview
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer!.videoGravity = AVLayerVideoGravityResize
                    previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    livePreview.layer.addSublayer(previewLayer!)

                    captureSession!.startRunning()
                    previewLayer!.frame = livePreview.bounds
                }
            }
            
        } catch {
            print("Error in setupLivePreview()")
        }
    }

    func setupSounds() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: neuralyzerSound)
            audioPlayer.prepareToPlay()

        } catch {
            print("Error in setupSounds()")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("viewWillAppear")

        setupCamera()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ErasingMemoryViewController.eraseMemory), userInfo: nil, repeats: false)
    }

    func setupCamera() {
        setAutoFocus()
        setFlashOn(true)
        setTorchOn(true)
    }

    func setAutoFocus() {
        do {
            // lock your device for configuration
            try backCamera?.lockForConfiguration()
            backCamera?.focusMode = AVCaptureFocusMode.autoFocus

        } catch {
            print("Error in lockForConfiguration()")
        }

        backCamera?.unlockForConfiguration()
    }

    func setFlashOn(_ isFlashOn: Bool) {
        if !(backCamera?.hasFlash)! {
            return
        }

        do {
            // lock your device for configuration
            try backCamera?.lockForConfiguration()

        } catch {
            print("Error in lockForConfiguration()")
        }

        if isFlashOn {
            backCamera?.flashMode = AVCaptureFlashMode.on

        } else {
            backCamera?.flashMode = AVCaptureFlashMode.off
        }
        
        // unlock your device
        backCamera?.unlockForConfiguration()
    }

    func setTorchOn(_ isTorchOn: Bool) {
        // check if the device has torch
        if (backCamera?.hasTorch)! {
            do {
                // lock your device for configuration
                try backCamera?.lockForConfiguration()

            } catch {
                print("Error in lockForConfiguration()")
            }

            // check if your torchMode is on or off. If on turns it off otherwise turns it on
            if isTorchOn {
                // sets the torch intensity to 100%
                backCamera?.torchMode = AVCaptureTorchMode.on

                do {
                    try backCamera?.setTorchModeOnWithLevel(1.0)

                } catch {
                    print("Error in setTorchModeOnWithLevel()")
                }

            } else {
                backCamera?.torchMode = AVCaptureTorchMode.off
            }

            // unlock your device
            backCamera?.unlockForConfiguration()
        }
    }

    func eraseMemory() {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            self.audioPlayer.play()

            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait

            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    //let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    //let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    //let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    //let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)

                    self.timer.invalidate()
                    self.captureSession!.stopRunning()
                    self.setFlashOn(false)
                    self.setTorchOn(false)
                    self.restoreButton.isHidden = false
                }
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("viewDidAppear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "neuralisator" {
             audioPlayer.stop()
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
