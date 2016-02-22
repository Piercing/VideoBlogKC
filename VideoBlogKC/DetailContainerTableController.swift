//
//  DeatilContainerTableController.swift
//  VideoBlogKC
//
//  Created by MacBook Pro on 17/2/16.
//  Copyright © 2016 weblogmerlos.com. All rights reserved.
//

import UIKit
import MobileCoreServices

class DetailContainerTableController: UITableViewController {
    
    
    // Necesito recibir un contenedor
    var currentContainer : AZSCloudBlobContainer?
    
    // Como en el controlador de la tabla  containers,  mediante el segue,
    // ya nos viene la propiedad con el contenedor que se ha seleccionado
    // en la tabla, podemos preguntarle  a este container para obtener la
    // lista de  blobs que  están contenidos  dentro del mismo (container).
    
    // Creo una variable modelo de tipo array, que contendrá en este caso blobs, en vez
    // de containers  ya que  es  lo que queremos mostrar en la nueva tabla de detalles
    var model : [AZSCloudBlob]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LLamo al método que pide los elementos del contenedor en
        // cuestión, para rellenar el array con los blobs recibidos
        populateModel()
        // sincronizo
        self.title = currentContainer?.name
        // creo botón para captura con  la cámara y la subida, a la
        // action le paso  el 'IBAction uploadContenido' que éste a
        // su vez llama al método 'fakeUpload'.
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "uploadContenido:")
        // Lo situo a la derecha
        self.navigationItem.rightBarButtonItem = plusButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Azure Blobs lists
    
    // Con el container que hemos seleccionado, podemos sacar
    // los  elementos de contenidos  dentro de ese contenedor
    func populateModel() {
        
        // Hago una  navegación jerárquica  a través de
        // los blobs que contiene mi container en Azure
        // Con este método obtengo información
        currentContainer?.listBlobsSegmentedWithContinuationToken(nil, // Nil, para obtener todo el contenido que hay
            prefix: nil,// Aquí  puedo filtrar, p.ejemplo,  dame todos los vídeos que  empiecen con el ID del usuario
            useFlatBlobListing: true,// devuelve  una representación  en plano, sin  formato  en la  salida del texto
            blobListingDetails: AZSBlobListingDetails.All,// le  indico que  me de el  resultado con el mayor detalle
            maxResults: -1,//si lo pongo a -1, devuelve todos los elementos que cumplen con los parámetros anteriores
            accessCondition: nil,
            requestOptions: nil,
            operationContext: nil, // tracear lo  que  se  está haciendo  con el SDK
            // Último bloque, una clausura con un error y el resultado de la llamada
            // error y result son tipo  opcionales, puede  que no  venga nada dentro
            completionHandler: { (error : NSError?, resultSegment: AZSBlobResultSegment?) -> Void in
                // Espero  recibir un array  de tipo 'AZSCloudBlob' ==> que es model
                // Compruebo que no hay error
                if (error == nil){ //  Si es igual  a  nil, es que  no tengo errores
                    // Saco  la  lista de  blobs  y  se los  asigno  al array  model
                    self.model = resultSegment!.blobs as? [AZSCloudBlob]
                    // Actualizo la tabla en la cola principal
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
        })
    }
    
    // Metodo para subir al Storage de Azure el vídeo, foto.. que he capturado
    // Recibe el NSData  del archivo que he  capturado y el nombre del recurso
    func uploadToStorage(data : NSData, blobName : String){
        
        // La mecánica es casi  siempre la misma, tengo el contenedor y lo que
        // voy a hace es crear un blob local, persistirlo localmente y una vez
        // creado tengo que  subirlo, hacerle el upload  del mismo a la cuenta.
        
        // Blob  local, generamos un  bloque local con un nombre  diferenciado
        // Esto me crea un blob local, con un  nombre exclusivo, como  prefijo
        //  =>'blob' le podemos pasar un ID  de usuario  si lo tuviéramos  con
        // lo que no vulnera y con un NSUUID convertido todo esto a un  String
        // Éste genera un número aleatorio después del 'blob-' que se asignará
        // a la imagen que se va a subir, cada vez que se suba crea  uno nuevo
        let blobLocal = currentContainer?.blockBlobReferenceFromName(blobName)
        
        // Tengo   que  convertir  la  imagen  en  NSData
        // var data : NSData?
        // Para generar el NSData de la imagen que quiero
        // subir y que  acabo  de  incoporar al  proyecto
        // data = UIImageJPEGRepresentation(UIImage(named: "FONDOS_PANTALLA_024.jpg")!, 0.8)
        // Mediante este bloque local ya podemos subir con alguno de sus  métodos
        // Recibe un  NSData, un  elemento  binario  comprimido, y  un bloque  de
        // finalización, un closure que recibe un error en caso de que lo hubiera.
        blobLocal?.uploadFromData(data , completionHandler: { (error : NSError?) -> Void in
            // Si hay error, lo muestro por consola mismamente
            if (error != nil){
                print("Error -> \(error)")
            }
        })
    }
    // MARK: - IBActions
    
    // Activo el 'Regresh Control' en el 'inspector de propiedades'
    // y creo este'IBAction' para poder refrescar la tabla-cambios
    @IBAction func refreshTable(sender: AnyObject) {
        
        // Aquí  tengo que  actualizar la tabla, el modelo, etc, etc
        // Cuando sólo se elimina una fila del modelo-table, hacemos
        // una  actualización sólo  para las filas de la tabla  y no
        // un  reloadData de  toda la tabla, a no  ser que haya  que
        // actualizar toda la tabla en concreto, es decir, el modelo.
        tableView.reloadData()
        
        // Por último, termino el  'Refresh Control'  de la  tabla.
        sender.endRefreshing()
    }
    
    // Botón para s ubir contenido  a nuestro  container  en Azure
    @IBAction func uploadContenido(sender: AnyObject) {
        
        // 1º parámetro, el viewController, yo mismo, 2º parámetro
        // el delegado,  seré de nuevo yo  mismo, este controlador.
        // Lanza el controlador del 'UImagePickerController'
        startCaptureVideoBlobFromViewController(self, withDelegate: self)
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        // si  hay  algo  dentro  de  model  y  lo  puedo
        // desempaquetar y guardarlo en la variable model
        if let model = model{
            // entonces  las  filas  serán  igual al
            // número de blobs que haya en mi modelo
            rows = model.count
        }
        // Devuelvo las filas
        return rows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("blobsIdentifier", forIndexPath: indexPath)
        
        // Saco el elemento que está en esa posición, el elemento seleccionado
        let item = model![indexPath.row]//Desempaqueto seguro,ya que arriba he
        // comprobado si hay filas, aquí sólo  obtengo el indexPath de la fila
        
        // sincronizo modelo => vista
        // Asigno con la propiedad blobName de ese blob el nombre para la celda
        cell.textLabel?.text = item.blobName
        // Devuelvo la celda
        return cell
    }
    
    // Lógica   para  la   eliminación  de  un  elemento  en  la  tabla
    // A este  método  puedo preguntar si  estilo es de  eliminación  y
    // nos mete  todo el  soporte del  swipe, eliminación  de  la celda
    // Tengo que obtener el indexPath del elemento a eliminar, borrarlo
    // de nuestro modelo local y  borrarlo también  del Storgade  Azure
    override func tableView(
        
        tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
        // Para otener el indexPah, puedo definir una property a  nivel
        // de  clase o hacer un método  como el que hago a continuación
        
        // Compruebo  que  el  estilo  es  de borrado del archivo-vídeo
        if(editingStyle == .Delete){
            // Actualizo-borro, el objeto con el indexPath que  le paso
            // de la celda que hemos marcado para su  eliminación-tabla
            updateLocalModelWithIndexpath(indexPath)
        }
    }
    
    /// Método para  update-delete el objeto del indexPath recibido
    func updateLocalModelWithIndexpath(index: NSIndexPath){
        
        // Antes  de  actualizar la tabla ===> 'beginUpdates'
        tableView.beginUpdates()
        
        // Una, la quito de la vista, no compruebo  si es nil
        // Espera recibir un array  indexPath, sólo tengo uno
        tableView.deleteRowsAtIndexPaths([index],
            withRowAnimation: .Automatic)
    
        // Segundo, elimino  el fichero  del Storage  de Azure
        // Me creo un método nuevo  para no tenerlo  todo aquí
        // Le pasamos el elemento que vamos a eliminar Storage
        deleteBlob(model![index.row])
        
        // Último la quito de local, que  es  nuestro modelo
        // Le paso al modelo la fila-row  que quiero eliminar
        model?.removeAtIndex(index.row)
        
        // Terminados los cambios, actualizo la table de nuevo
        // Después  de  actualizar  la  tabla ===> 'endUpdates'
        tableView.endUpdates()
    }
    
    func deleteBlob(blob : AZSCloudBlob){
        
        blob.deleteWithCompletionHandler { (error : NSError?) -> Void in
            // Si es distinto de nil tenemos un error
            if(error != nil){
                print("Error -> \(error)")
            }else{
                print("Blob borrado con éxito")
            }
        }
    }
    
    // MARK: - Métodos para la Captura de Vídeo
    
    // Creo  una función que al  pulsar el botón de la cámara
    // la lance, ponga el modo de captura  de vídeo, etc, etc
    // Lo ideal es  poner este  método  en una  clase a parte
    // Recibe un viewController y un  protocolo como delegate
    // que conforme el 'UIImagePickerControllerDelegate' y el
    // 'UIImagePickerControllerDelegate' obligar a extenderlo
    func startCaptureVideoBlobFromViewController(ViewController: UIViewController,
        withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool {
            
            // Comprobamos si podemos utilizar o  acceder a la cámara
            if (UIImagePickerController.isSourceTypeAvailable(.Camera) == false) {
                // Si no podemos nos salimos de aquí si provocar error
                return false
            }
            // Declaro  una  variable de tipo  UIImagePickerController
            // para poder  definir las  funciones que podemos realizar
            // con la cámara
            
            // Indicamos desde que fuente que vamos a capturar, en este
            // caso la cámara
            let cameraController = UIImagePickerController()
            cameraController.sourceType = .Camera
            // Indicamos  el  tipo  de contenido  que  esperamos  utilizar
            // Importo un módulo para 'KUTTypeMovie' =>'MobileCoreServices'
            cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
            // No permito la edición del vídeo
            cameraController.allowsEditing = false
            // Asigno el delegate
            cameraController.delegate = delegate
            // Por último presentarlo
            presentViewController(cameraController, animated: true, completion: nil)
            
            // Como es una función booleana, si todo ha ido bien hasta aquí
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
            // Para  subirlo  a  Azure, llamo a  la  función que  he  creado ==> 'uploadToStorage'
            // pasándole el NSData => el vídeo y el nombre NSUUID ya creado con la extensión'.mov'
            uploadToStorage(data, blobName: blobNameUUID)
        }
    }
    
}

/// Función vídeo: muestra una alerta cuando el vídeo se ha guardado  correctamente + contexInfo?
//  El método 'UISaveVideoAtPathToSavedPhotosAlbum'  llamodo en la función 'imagePickerController'
//  me o bliga a i mplementar un 'selector' como  parámetro al guardar el  vídeo, y le  paso éste
//@available(iOS 8.0, *)
func video(videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
    
    var title = "Ok"
    var message = "Video grabado correctamente"
    
    // Compruebo si hay error al guardar el vídeo
    if let _ = error{
        // Pongo título
        title = "Fail"
        // Muestro el mensaje de error
        message = "El vídeo no se ha grabado"
    }
    // Si no hay error, creo una alerta para avisar al usuario de que el vídeo se grabó 'Ok'
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
    alert.presentViewController(alert, animated: true, completion: nil)
}




// Implemento  los métodos de  protocolos, al menos cuando termino de capturar el vídeo, para
// q  nos permita obtener ese vídeo capturado. Para ello implemteo las siguientes extensiones

// Añado el UINavigationViewController para tener navegación y el del UIImagePickerController
// ¿De que hago la extensión?, pues de la clase que estoy ==> 'DetailContainerTableController'
extension DetailContainerTableController: UINavigationControllerDelegate{
    
    // Este se queda vacío, lo implemento siempre fuera de la clase
}

extension DetailContainerTableController: UIImagePickerControllerDelegate{
    
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

















