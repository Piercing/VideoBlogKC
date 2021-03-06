//
//  ViewPostController.swift
//  VideoBlogKC
//
//  Created by MacBook Pro on 21/2/16.
//  Copyright © 2016 weblogmerlos.com. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewPostController: UIViewController {
    
    @IBOutlet weak var saveInAzureButton : UIButton!
    @IBOutlet weak var titleText : UITextField!
    @IBOutlet weak var validatorLabel : UILabel!
    
    // Variable para almacenar el binario del vídeo a subir
    var bufferVideo : NSData?
    // Variable para  almacenar el  nombre del blob a subir
    var myBlobName : String?
    
    // Variable para almacenar los datos del cliente  Azure
    var client : MSClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Nuevo Post"
        
        let plusButton = UIBarButtonItem(
            barButtonSystemItem: .Camera,
            target: self,
            action: "capturaVideo:")
        self.navigationItem.rightBarButtonItem = plusButton
        
        // Al  texField, le decimos que el  ViewController
        // será  delegado  de él mismo  para  controlar la
        // longitud de la cadena, y hacer que la  etiqueta
        // de validación cambie si es mayor de 10 caracter.
        titleText.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources  that can be recreated.
    }
    
    @IBAction func saveAzureAction(sender: AnyObject) {
        
        // Hacemos referencia a la tabla de los vídeos
        let tablaVideos = client?.tableWithName("videoblogs")
        
        // NOTA: ¿por qué hacemos esto de guardar el nombre  del blog y el contendor? Porque cuando impomente//
        // la funcionalidad para visualizar  cualquiera  de estos blobs necesito  tener la URL  al 'endpoint'//
        // del recurso. Y además tenemos que  asignarle una 'URL SaaS',  una especie de  firma  que nos va a //
        // permitir acceder al mismo y también,  si utilizo algún día un 'CDN', nos servirán así estos datos //
        
        // Partimos de la base de tener el vídeo y en primer lugar  guardamos  en la base de  datos de Azure.//
        
        // Inserto datos en la tabla que acabo d referenciar. Como título el texto    capturado en el textField
        // Aprovecho  para Asignar  el nombre  del 'blogName' y  darle  un nombre  al 'container' que he creado
        // Cuando se haya guardado, se llama al closure  por  si hay error o bien para subir el vídeo  a  Azure
        
        tablaVideos?.insert(["titulo" : titleText.text!, "blobName" : myBlobName!, "containername" : "pruebas"], completion: {
            (inserted: [NSObject : AnyObject]!, error : NSError?) -> Void in
            if error != nil{
                print("Huston we have a problem saving your video")
            }else{
                // Llegados a  este punto el vídeo  tiene que estar  capturado. Le paso la propiedad que
                // tiene la clase para retener los NSData del vídeo capturado y el  nombre del 'blobname'
                print("Houston, overtaken first part. Right!! (Ya tenemos el registro en la BBDD, ahora toca blob)")
                // le paso los 'NSdata' del vídeo y el nombre para persistir el blob en Storage de Azure
                self.uploadToStorage(self.bufferVideo!, blobName: self.myBlobName!)
            }
        })
    }
    
    func capturarVideo (sender : AnyObject){
        
        startCaptureVideoBlobFromViewController(self, withDelegate: self)
    }
    
    // MARK: - Métodos para la Captura de Vídeo
    
    func startCaptureVideoBlobFromViewController(ViewController: UIViewController,
        withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool {
            
            // Comprobamos si podemos utilizar o  acceder a la cámara
            if (UIImagePickerController.isSourceTypeAvailable(.Camera) == false) {
                // Si no podemos nos salimos de aquí si provocar error
                return false
            }
            // Declaro  una  variable de  tipo == > 'UIImagePickerController' para
            // poder  definir  las  funciones que  podemos  realizar con la cámara
            
            // Indicamos desde que fuente que vamos a capturar,en este caso cámara
            let cameraController = UIImagePickerController()
            cameraController.sourceType = .Camera
            // Indicamos  el  tipo  de contenido  que  esperamos  utilizar
            // Importo un módulo para 'KUTTypeMovie' =>'MobileCoreServices'
            cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
            // No  permito  la  edición del vídeo
            cameraController.allowsEditing = false
            // Asigno  el  delegate  que   recibo
            cameraController.delegate = delegate
            // Por último presentar el controller
            presentViewController(cameraController, animated: true, completion: nil)
            
            // Como es una función booleana, si todo ha ido bien hasta aquí
            return true
    }
    
    
    /// Método para guardar localmente un NSData
    func saveInDocuments(data : NSData) {
        
        // Constante con la cual doy nombre con un 'UUIDString' ya creado y con la extensión 'mov'
        let blobNameUUID = "/video-\(NSUUID().UUIDString).mov"
        // Obtenemos el 'path' del directorio donde voy  guardar y  ponerle un nombre  al fichero
        // El primer parámetro le paso el directorio del documento y el 2º el dominio del usuario
        // Como esto nos devuelve un array le decimos que nos devuelva el primer elemento => '[0]'
        // como una cadena. Con esto ya tengo el 'path' del directorio mi documents, de mi'Sanbox'
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0] as String
        // Ahora le agrego a documents  un nombre de fichero al vídeo  a guardar que he capturado
        // A este fichero le doy un nombre con un 'UUIDString' ya creado y con  la extensión 'mov'.
        let filePath = documents.stringByAppendingString(blobNameUUID) // le  añado la  extensión
        // Ya tenemos el nombre del fichero, pero el fichero  aún no existe, o creo que no existe.
        // Para ello compruebo con un 'if' si existe o no el fichero. Con 'contentsOfFile' obtngo
        // todas las coincidencias que encuentra en el'filePath' que le paso, metidas en un array
        let array = NSArray(contentsOfFile: filePath) as? [String]// si lo puede desempaquetar...
        // Pregunto si el array  está vacio, es decir, no ha encontrado coincidencias en el Path,
        // ya que si encuentra  coincidencias, es  que el fichero ya existe y se sobreescribiría.
        // Puedo preguntar si es nil, es un opcional, y compruebo si está a nil, para persistirlo
        // ya que, al comprobar  que no es nil, es  que no existe, por tanto  podemos persistirlo.
        if (array == nil) {
            // voy  a persistir  el fichero  localmente  y una vez haya guardado  lo subo a Azure.
            data.writeToFile(filePath, atomically: true)
            
            // Guardo los datos binarios del vídeo y el nombre que se le dará al blob que subamos.
            bufferVideo = data
            myBlobName = "/video-\(NSUUID().UUIDString).mov"
            // Para  subirlo  a  Azure, llamo a  la  función que  he  creado ==> 'uploadToStorage'
            // pasándole el NSData => el vídeo y el nombre NSUUID ya creado con la extensión'.mov'
            //uploadToStorage(data, blobName: blobNameUUID)
        }
    }
    
    /// Metodo para subir al Storage de Azure el vídeo, foto.. que he capturado
    /// Recibe el NSData  del archivo que he  capturado y el nombre del recurso
    func uploadToStorage(data : NSData, blobName : String){
        
        
        // Voy a invoke la  api 'urlsasblobandcontainer' y obtener
        // una URL y poder subir el blob a Mobile Service de Azure
        
        //********************* 1º **********************
        // Invocar la Api mediante el 'client'
        client?.invokeAPI("urlsasblobandcontainer",
            body: nil,
            HTTPMethod: "GET",
            // como  parámetros  el nombre  del contenedor y del blob
            parameters: ["blobName" : myBlobName!, "ContainerName" : "pruebas" ],
            headers: nil,
            // El primer parámetro devuelve el diccionario con la URL
            // que hemos  generado para poder  subir un  blob a Azure
            // El segundo, es la  respuesta, por si queremos analizar
            // el tipo de respuesta como por ejemplo que nos devuelva
            // un '205' u  otra  respuesta  y por  último el 'NSError'
            completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error : NSError?) -> Void in
                
                // Si no hay error
                if error == nil {
                    
                    // ********************* 2º **********************
                    // es  que en el 'result' recibo un diccionario con
                    // una clave  que se llamará ==> 'sasURL' que tiene
                    // un valor, que es el  que a nosotros nos interesa
                    // Con esta sólo tenemos la ruta del container/blob
                    let sasURL = result!["sasUrl"] as? String
                    
                    // ********************* 3º **********************
                    // En  vez de  crear el  container  desde Azure, lo
                    // vamos  a  hacer  desde  aquí, partiendo  de esta
                    // 'sasURL'. Con esto tenemos la 'firma' de la URL,
                    // pero tenemos que poner también el recurso al que
                    // queremos acceder,tenemos que ponerle el endpoint
                    // Hay que poner el 'endpoint 'del 'Storage' no del
                    // Mobile Service.
                    var endPoint = "https://videoblogappkc.blob.core.windows.net"
                    
                    // Ya  tenemos  la 'sasURL' y el 'endPoint'. Lo que
                    // hacemos ahora es sumar las dos cadenas,  unirlas,
                    // para tener la URL completa y poder subir o bajar
                    // el recurso queremos acceder. En este caso  subir.
                    
                    // Sumamos  las cadenas == > 'endPoint'  y  'sasURl'
                    endPoint += sasURL!
                    
                    // ********************** 4º ***********************
                    //     APUNTANDO AL CONTAINER DE AZURE STORAGE
                    // Ya podemos hacer  referencia a nuestro  container
                    // para  poder  subir. Hasta ahora  usábamos el  que
                    // tenía el blobClient y ahora usaremos directamente
                    // una URL, que no es ni más ni menos  que 'endPoint'
                    let container = AZSCloudBlobContainer(url: NSURL(string: endPoint)!)
                    
                    // ********************** 5º ***********************
                    //           CREANDO NUESTRO BLOB LOCAL
                    // Como no me permite subir un fichero, sino un blob
                    // he de convertir el fichero a un tipo de dato blob
                    // Desde el container tomo la referencia del  nombre
                    // del  'blob', pasándole  el 'blobName' que  recibo
                    let blobLocal = container.blockBlobReferenceFromName(blobName)
                    
                    // ********************** 6º ***********************
                    // HACEMOS EL UPLOAD DE NUESTRO BLOB LOCAL * EL DATA
                    //
                    blobLocal.uploadFromData(data, completionHandler: {
                        (error : NSError?) -> Void in
                        
                        // Aquí se supone  que  hemos controlado el éxito
                        // Recordar también, que tenemos un button, en el
                        // storyBoard del viewController, el cual  estaba
                        // desactivado para poder subir los datos a Azure
                        
                        // Si no hay error
                        if error != nil {
                            // Deshabilito el botón. Como las clase de AZS
                            // trabajan en 2º plano, tenemos que volver al
                            // hilo principale para poder llevarlo a  cabo
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // Deshabilito el botón
                                self.saveInAzureButton.enabled = false
                            })
                        } else{
                            print("Houston we have a problem: Error!! -> \(error)")
                        }
                        
                        // NOTA: CON ESTO HEMOS  TERMINADO TODO EL PROCESO DE
                        // ASOCIAR EL ELEMENTO EN UNA TABLA DE MOBILE SERVICE
                        // Y  DE  SUBIR  EL  'BLOB'  AL  STORAGE   DE  'AZURE'
                    })
                }
        })
    }
}



// MARK: Delegate textField
extension ViewPostController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Cogemos al cadena que  hemos metido en el 'textField'
        let currentString = textField.text! as NSString
        
        // Si la  cadena  es mayor a 10  este título  mola mogollón
        // Le damos un color verde cuando supere  los 10 caracteres
        // y  habilitamos el botón upload para subir el vídeo Azure
        if (currentString.length > 10) {
            validatorLabel.text = "Este título mola mogollón"
            validatorLabel.textColor = UIColor.greenColor()
            saveInAzureButton.enabled = true
        }
        
        return true
    }
}

extension ViewPostController: UINavigationControllerDelegate {
    
}

extension ViewPostController: UIImagePickerControllerDelegate{
    
    // Aquí  si  que  implemento  el  método  ===>  didFinishPickingMediaWithInfo',
    // es  la  respuesta  de la  clase  Picker, del  protocolo, que lo  que  hace,
    // que  cuando se  termina de capturar el vídeo, el  usuario le da a utilizar
    // la cámara y termina la captura de éste, el control nos viene a este método
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // Recojo  lo  que  he recibido, el parámetro 'info' tiene  una key que se
        // va  a poder  tener acceso a  lo que hemos capturado, lo casteo a cadena
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        // Ejecuto el 'dismiss' para cerrar el Picker y salir de la vista del vídeo
        dismissViewControllerAnimated(true, completion: nil)
        
        // Comprobamos  que  hemos  capturado, si  es  un  vídeo ==> 'kUTTypeMovie'
        if(mediaType == kUTTypeMovie as String) {
            
            // Lo persisitimos  en local, para ello contruyo un  path, aunque no es
            // necesario  persistrilo en local, por contra  si en la nube ==> Azure
            // Obtengo de la clave 'info', preguntando donde se ha almacenado tempo/
            // el vídeo que acabamos de capturar, obteniendo el 'path'(casteo a URL)
            let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path
            
            // Tenemos  que  persistir  en local - solo  por aprender
            // Creo  el  siguiente método, que  lo que  va a  recibir
            // es,  por un  lado el  buffer NSData que tiene el vídeo
            // y por otro lado el path donde está almacenado el vídeo
            saveInDocuments(NSData(contentsOfURL: NSURL(fileURLWithPath: path!))!)
            
            // Una  vez que  se ha  capturado, hacemos  una acción  de usuario
            // sacando el típido alert informando  al  usuario de  lo sucedido
            // De  momento  lo  dejo  guardado  en  el  carrete. El método del
            // selector   que   creamos   tendrá  un  parámetro   'contextInfo',
            // por  si  quesiéramos  pasarle  el  contexInfo del UIImagePicker.
            // Le  pasamos  también el 'path' donde tenemos  guardado el vídeo.
            // El target seremos  nosotros mismos, este  controlador ==> 'self'
            // El 'contextInfo' último parámetro  a nil, no le paso nigún dato.
            // Éste método se invoca desde la extensión del UIImagePickerContr
            //
            UISaveVideoAtPathToSavedPhotosAlbum(path!, self, "video:didFinishSavingWithError:contextInfo:", nil)
        }
    }
}
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/
