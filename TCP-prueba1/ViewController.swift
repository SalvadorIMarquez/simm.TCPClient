//
//  ViewController.swift
//  TCP-prueba1
//
//  Created by Salvador Marquez on 5/14/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var btnEnviar: UIButton!
    @IBOutlet weak var texto: UITextField!
    @IBOutlet weak var lblRespuesta: UILabel!
    var conectado = false
    @IBOutlet weak var btnConectar: UIButton!
    let conexionTCP = TCPConnection()
    var utils: Utils!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conexionTCP.delegate = self
        btnEnviar.isEnabled = false
        texto.isEnabled = false
        utils = Utils.sharedInstance
        //self.dismissKey()
        let gestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(ViewController.descarteTeclado))
        self.view.addGestureRecognizer(gestureRecognizer)
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(ViewController.descarteTeclado)))
    }
    
    @objc func descarteTeclado(){
        self.view.endEditing(true)
        
    }
    
    @IBAction func EnviarMensaje(_ sender: Any) {
        var info = ""
        info = texto.text!
        if info != nil {
            conexionTCP.sendData(data: info)
            
        }

    }
    @IBAction func guardaTeclado(_ sender: Any) {
        self.view.endEditing(true)
        var info = ""
        info = texto.text!
        conexionTCP.sendData(data: info)
        
        
    }
    
    @IBAction func estableceConexion(_ sender: Any) {
        if conectado == false {
            let conexionEstablecida = conexionTCP.setupTCPCommunication()
            if conexionEstablecida == 1 {
                btnEnviar.isEnabled = true
                texto.isEnabled = true
                conectado = true
                btnConectar.setTitle("Desconectar", for: UIControl.State.normal)
            }else {
                utils.info(message: "ERROR DE CONEXION. \n Asegurese de estar conectado a Wi-Fi y al puerto correcto", ui: self, cbOK: {})
            }
        } else{
            conexionTCP.stopConection()
            btnEnviar.isEnabled = false
            texto.isEnabled = false
            conectado = false
            btnConectar.setTitle("Conectar", for: UIControl.State.normal)
        }

    }
    
    
    
}

extension ViewController: TCPConnectionDelegate{
    func receivedData(message: String) {
        lblRespuesta.text = "Recibido: " + message
    }
}
extension UIViewController {
    func dismissKey()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
