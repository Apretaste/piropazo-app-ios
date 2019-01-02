//
//  ServicesVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 10/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit
import JavaScriptCore

class ServicesVC: UIViewController {

     lazy var webView: UIWebView = {
       
        let webView = UIWebView(frame: .zero)
        return webView
    }()
    
    
    let command:String?
    var urlHtml:URL?
    
    var jsContext: JSContext!
    var selectComponents:[String] = []
    var textField: UITextField!

    var uploadCommand = ""
    

    //MARK: - Constructor
    
    init(urlHtml: URL){
        self.urlHtml = urlHtml
        self.command = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(command:String){
        self.command = command
        self.urlHtml = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // config webView //
        
        self.webView.delegate = self
        
        // call setups //
        self.setupView()
        self.loadWebView()
        self.handlerJavaScript()
        
    }
    
    //MARK: - setups
    
    func setupView(){
     
        // add webView
        self.view.addSubview(self.webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
       self.webView.backgroundColor = .white
     
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        

    }
    
     func loadWebView(){
        
        if let command = command{
            
            self.startAnimating(message:" ")
            
            ConnectionManager.shared.request(withCaching: false, command: command) { (error, urlHtml) in
                self.stopAnimating()
                if error != nil{
                    //TODO: no se pudo cargar el comando manejar mensaje de error
                    return
                }
                                
                let formatHTML = self.procesingHtmlContent(htmlPath: urlHtml!)
                self.webView.loadHTMLString(formatHTML, baseURL:urlHtml!)
                
            }
        }
        
        if let htmlPath = urlHtml{
            
            let formatHTML = self.procesingHtmlContent(htmlPath: htmlPath)
            self.webView.loadHTMLString(formatHTML, baseURL:self.urlHtml)
        }
        
        


    }
    
    //MARK: - funcs
    
    
    @objc func refreshButtonTapped(){
        
//        self.startAnimating(message:"Refrescando")
//
//        ConnectionManager.shared.request(withCaching:false,command: self.command) { (error, url) in
//
//            self.stopAnimating()
//
//            if error != nil{
//
//                let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
//                let action = UIAlertAction(title: "OK", style: .cancel)
//                alert.addAction(action)
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//
//            let serviceVC = ServicesVC(urlHtml: url!)
//            self.navigationController?.pushViewController(serviceVC, animated: true)
//
//        }
//
        
    }
    
    private func procesingHtmlContent(htmlPath:URL) -> String{
        
        let contentFile = try! String.init(contentsOf: htmlPath)
        let stringError = "<h4>Existe un problema con este servicio. Intente más tarde.</h4>"
        
      
       
        
        let cleanContentFile = contentFile.replacingOccurrences(of: "return false;", with: "")
        
        if let cssSourcePath = Bundle.main.path(forResource: "styles", ofType: "css") {
            
            let importCss = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssSourcePath)\" />"
            
              return "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\"/> \(importCss)</head><body> \(cleanContentFile) </body></html>"           
        }
        
      
        return stringError
        
    }
    
    func handlerJavaScript(){
    
        self.jsContext =  self.webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext

        if let jsSourcePath = Bundle.main.path(forResource: "resource", ofType: "js") {
            do {
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                
                self.jsContext.evaluateScript(jsSourceContents)
            }
            catch {
                print(error.localizedDescription)
            }
        }

    }
    public func reloadServices (){
        self.jsContext = nil
        self.webView.removeFromSuperview()
        self.webView =  UIWebView(frame: .zero)
        self.webView.delegate = self
        self.setupView()
        self.loadWebView()
        self.handlerJavaScript()
        
    }
    
    func createCustomTextField(_ textField: UITextField,message:String) {
        
        textField.placeholder = self.extractMessage(message: message)
        
        if message.hasPrefix("n:"){
            textField.keyboardType = .numberPad
        }
        
        if message.hasPrefix("m:"){
            
            // delete prefix //
            var newMessage = message
            
            newMessage.removeFirst()
            newMessage.removeFirst()
            
            var tempItems = newMessage.components(separatedBy: "[").last!
            tempItems.removeLast()
            
            let items = tempItems.components(separatedBy: ",")

            self.selectComponents = items
            self.textField = textField
            
            let picker = UIPickerView()
            
            picker.dataSource = self
            picker.delegate = self
            
            textField.text = items.first!
            textField.inputView = picker

            
        }
        
        if message.hasPrefix("d:"){
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            
            self.textField = textField
            
            datePicker.addTarget(self, action: #selector(self.changeDataPicker(_:)), for: .valueChanged)
            
        }

    }
    
    @objc func changeDataPicker(_ datePicker: UIDatePicker){
        
        let dateString = UtilitesMethods.formatDateToPrettyDateString(date: datePicker.date, format: "dd/MM/YYYY")
        
        self.textField.text = dateString
    }
    
    func extractMessage(message:String) -> String{
        
        if message.hasPrefix("m:"){
            
            // delete prefix //
            var newMessage = message
            newMessage.removeFirst()
            newMessage.removeFirst()
            
            let message = newMessage.components(separatedBy: "[").first!
            
            return message
            
        }
        
        if message.hasPrefix("d:") || message.hasPrefix("n:") || message.hasPrefix("a:"){
            
            // delete prefix //
            var newMessage = message
            newMessage.removeFirst()
            newMessage.removeFirst()
            return newMessage
            
        }
        
        
        return message
    }
    
    func captureOnClicked() {
        
        if let capture = self.jsContext.objectForKeyedSubscript("apretaste") {
            guard let data = capture.toDictionary() else{
                return
            }
            
            let urlKey = AnyHashable.init("url")
            let popupKey = AnyHashable.init("popup")
            let waitKey = AnyHashable.init("wait")
            let messageKey = AnyHashable.init("message")
            let url = data[urlKey] as! String
            let popup =  data[popupKey] as! Bool
            let wait =  data[waitKey] as! Bool
            let message =  data[messageKey] as! String
            

            self.handlerOnClicked(command: url, popup: popup, message: message,wait: wait)
        }
    }
    
    func handlerOnClicked(command:String, popup:Bool,message:String, wait: Bool){
        
        if !wait{
            
            if popup{
                
                let userMessage = "Ingrese los datos solicitados"
                
                // validating upload image //
                
                if message.hasPrefix("u:"){
                    
                    let pickerVC = UIImagePickerController()
                    pickerVC.sourceType = .photoLibrary
                    pickerVC.delegate = self
                    self.uploadCommand = command
                    self.present(pickerVC, animated: true, completion: nil)
                    return
                    
                }
                
                var alertText = UIAlertController(title: self.title, message: userMessage, preferredStyle: .alert)
                
                let messagesTextFields = message.split(separator: "|")
                
                for messageTextField in messagesTextFields{
                    
                    let message = String(messageTextField)
                    let titleMessage = String(message
                        .replacingOccurrences(of: "m:", with: "")
                        .replacingOccurrences(of: "t:O", with: "")
                        .replacingOccurrences(of: "u:", with: "")
                        .replacingOccurrences(of: "n:", with: "")
                        .replacingOccurrences(of: "d:", with: "")
                        .split(separator: "[")[0])
                    
                    alertText = UIAlertController(title: self.title, message: titleMessage, preferredStyle: .alert)
                    alertText.addTextField { (textfield) in
                        
                        self.createCustomTextField(textfield, message: message)
                    }
                }
                
                
                let done = UIAlertAction(title: "Aceptar", style: .default, handler: { (_) in
                    
                    var searchString = ""
                    
                    for textField in alertText.textFields ?? []{
                        
                        searchString = searchString + " " + textField.text!
                        
                    }
                    
                    self.startAnimating(message:"")
                    
                    let newCommand = "\(command) \(searchString)"
                    
                    ConnectionManager.shared.requestAwait(command: newCommand) { (success) in
                        
                        self.stopAnimating()
                      
                        let message = "Operación realizada exitosamente"
                        let title = "Éxito" 
                        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
                        let actionButton = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(actionButton)
                        self.present(alert, animated: true)
                        
                    }
                    
                })
                
                let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
                
                alertText.addAction(cancel)
                alertText.addAction(done)
                self.present(alertText, animated: true)
                
                return
                
            }
            
            self.startAnimating(message:"")
            
            ConnectionManager.shared.requestAwait(command: command) { (success) in
                
                self.stopAnimating()
                
                let message = success ? "Operación realizada exitosamente" : "Ocurrió un error"
                let title = success ? "Éxito" : "Error"
                let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
                let actionButton = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(actionButton)
                self.present(alert, animated: true)
            }
            
            return
        }
        
        if popup{
            
            let userMessage = "Ingrese los datos solicitados"
            
            let alertText = UIAlertController(title: self.title, message: userMessage, preferredStyle: .alert)
            
            let messagesTextFields = message.split(separator: "|")
            
            for messageTextField in messagesTextFields{
                
                let message = String(messageTextField)
                
                alertText.addTextField { (textfield) in
                    
                    self.createCustomTextField(textfield, message: message)
                }
            }
            
            let done = UIAlertAction(title: "Aceptar", style: .default, handler: { (_) in
                
                var searchString = ""
                
                for textField in alertText.textFields ?? []{
                    
                    searchString = searchString + " " + textField.text!

                }
                
                self.startAnimating(message:"")
                
                let newCommand = "\(command) \(searchString)"
                
                ConnectionManager.shared.request(withCaching: false, command: newCommand) { (error,html) in
                    
                    self.stopAnimating()
                    // validate error //
                    if error != nil{
                        
                        let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    
                    let servicesVC = ServicesVC(urlHtml: html!)
                    servicesVC.title = String(command.split(separator: " ").first!)
                    TEMPManager.shared.saveVisitedServices()
                    self.navigationController?.pushViewController(servicesVC, animated: true)
                   
                }

            })
            
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
            
            alertText.addAction(cancel)
            alertText.addAction(done)
            self.present(alertText, animated: true)
            
            return
        }
        
        // open new Link //
        self.startAnimating(message:"")
        
        ConnectionManager.shared.request(withCaching: false, command: command) { (error,html) in
            
            self.stopAnimating()
            // validate error //
            if error != nil{
                
                let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let servicesVC = ServicesVC(urlHtml: html!)
            TEMPManager.shared.saveVisitedServices()
            self.navigationController?.pushViewController(servicesVC, animated: true)
           
        }
        
    }
}

//MARK: - WebView Delegate //

extension ServicesVC: UIWebViewDelegate{

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        if navigationType == .linkClicked{
            
            self.captureOnClicked()
            return false
        }
        return true
    }
}

//MARK: - implement picker delegate

extension ServicesVC: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return self.selectComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.selectComponents[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = self.selectComponents[row]
        
    }
}

extension ServicesVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        navigationController.navigationBar.isTranslucent = false
        
        let backgroundImage = UIImage.imageWithColor(color: UIColor.greenApp)
        navigationController.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        
        navigationController.navigationBar.barTintColor = .white
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        var url: URL!
//
        if #available(iOS 11.0, *) {
            if let tempURL = info[UIImagePickerControllerImageURL] as? URL{
                url = tempURL
            }
        } else {
            if let tempURL = info[UIImagePickerControllerReferenceURL] as? NSURL{
                
                let imageName = tempURL.lastPathComponent
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let photoURL = NSURL(fileURLWithPath: documentDirectory)
                
                url = photoURL.appendingPathComponent(imageName!)
                
                let image             = info[UIImagePickerControllerOriginalImage]as! UIImage
                let data              = UIImagePNGRepresentation(image)
                
                do
                {
                    try data?.write(to: url!, options: Data.WritingOptions.atomic)
                }
                catch
                {
                    //TODO: Catch exception here and act accordingly
                }
                
            }
        }
        
        let imageName = url.lastPathComponent
        let command = "\(uploadCommand) \(imageName)"
        
        self.startAnimating(message:"Subiendo foto...")
        
        ConnectionManager.shared.requestAwait(command: command, withImage: url) { (success) in
            
            self.stopAnimating()
            
            let message = success ? "Operación realizada exitosamente" : "Ocurrió un error, verifique su conexión a internet o su configuración de conexión."
            let title = success ? "Éxito" : "Error"
            let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
            let actionButton = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(actionButton)
            self.present(alert, animated: true)
        }
    }
}
