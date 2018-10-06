//
//  ScannerViewController.swift
//
//  Created by Vikram Hegde on 5/16/18.
//  Copyright © 2018 Vikram Hegde. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var first = true
    
    var isbn : String = ""
    
    //MARK: Properties
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice?
    var captureLayer:AVCaptureVideoPreviewLayer?
    
    //MARK: View lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("Loaded")
        self.setupCaptureSession()
        
    }
    
    //MARK: Session Startup
    private func setupCaptureSession()
    {
        print("Begin Setup")
        self.captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do{
            let deviceInput = try AVCaptureDeviceInput(device: self.captureDevice!)
            
            //Add the input feed to the session and start it
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            if captureSession.inputs.isEmpty {
                self.captureSession.addInput(deviceInput)
                print("Adding Input")
            }
            self.setupPreviewLayer(completion: {
                self.captureSession.startRunning()
                self.addMetaDataCaptureOutToSession()
                print("Setup 1 complete")
            })
        }
        catch
        {
            self.showError(error: error.localizedDescription)
        }
        
    }
    
    private func setupPreviewLayer(completion:() -> ())
    {
        self.captureLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        if let capLayer = self.captureLayer
        {
            capLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            capLayer.frame = self.view.frame
            self.view.layer.addSublayer(capLayer)
            completion()
            print("Setup 2 complete")
        }
        else
        {
            self.showError(error: "An error occured beginning video capture.")
        }
    }
    
    //MARK: Metadata capture
    private func addMetaDataCaptureOutToSession()
    {
        print("Capturing Metadata")
        let metadata = AVCaptureMetadataOutput()
        self.captureSession.addOutput(metadata)
        metadata.metadataObjectTypes = metadata.availableMetadataObjectTypes
        metadata.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        print("Metadata Added")
    }
    
    //MARK: Delegate Methods
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metaData in metadataObjects
        {
            if let decodedData:AVMetadataMachineReadableCodeObject = metaData as? AVMetadataMachineReadableCodeObject{
                isbn = decodedData.stringValue!
            }
        }
        if first{
            self.performSegue(withIdentifier: "foundCode", sender: nil)
            first = false
        }
    }
    
    //MARK: Utility Functions
    private func showError(error:String)
    {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let dismiss:UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler:{(alert:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(dismiss)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bookDetails = segue.destination as? BookViewController {
            bookDetails.isbn = isbn
        }
    }
}
