//
//  ViewController.swift
//  CustomCamera
//
//  Created by Timothy Obeisun on 8/11/22.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    //Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    //Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    // SHutter Button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 100,
                                            height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(previewLayer)
        
        checkCameraPermission()
        
        setupShutterButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width / 2,
                                       y: view.frame.size.height - 100)
    }
}


private extension ViewController {
    
    func setupShutterButton() {
        view.addSubview(shutterButton)
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
    }
    
    @objc func shutterButtonTapped() {
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }
    
    func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.startRunning()
                self.session = session
            } catch {
                debugPrint(error)
            }
        }
    }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: data)
        session?.stopRunning()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}
