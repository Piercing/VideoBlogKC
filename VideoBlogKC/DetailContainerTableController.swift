//
//  DeatilContainerTableController.swift
//  VideoBlogKC
//
//  Created by MacBook Pro on 17/2/16.
//  Copyright © 2016 weblogmerlos.com. All rights reserved.
//

import UIKit

class DetailContainerTableController: UITableViewController {
    
    
    // Necesito recibir un contenedor
    var currentContainer : AZSCloudBlobContainer?
    
    // Como en el controlador de la tabla  containers,  mediante el segue,
    // ya nos viene la propiedad con el contenedor que se ha seleccionado
    // en la tabla, podemos preguntarle  a este container para obtener la
    // lista de blobs que están contenidos dentro del mismo.
    
    // Creo  una  variable  de  tipo array, que contendrá en este caso blobs, en vez
    // de containers ya que es lo que queremos mostrar en la nueva tabla de detalles
    var model : [AZSCloudBlob]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateModel()// función para rellenar el array con los blobs recibidos
        fakeUpload()
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
        currentContainer?.listBlobsSegmentedWithContinuationToken(nil, // Nil, para obtener todo el contenido que hay
            prefix: nil,// Aquí  puedo filtrar, p.ejemplo,  dame todos los vídeos que  empiecen con la  palabra vídeo
            useFlatBlobListing: true,// devuelve  una representación  en plano, sin  formato  en la  salida del texto
            blobListingDetails: AZSBlobListingDetails.All,// por si  quiero sacar a parte del  contenido  propiedades
            maxResults: -1,// si lo pongo a -1, devuelve  todos los  elementos que cumplen con el parámetro  anterior
            accessCondition: nil,
            requestOptions: nil,
            operationContext: nil,
            // error y result son tipo  opcionales, puede que no venga nada dentro
            completionHandler: { (error : NSError?, resultSegment: AZSBlobResultSegment?) -> Void in
                // Espero recibir un array de tipo 'AZSCloudBlob' ==> que es model
                // Compruebo que no hay error
                if (error == nil){ //  Si es igual  a nil, es que no tengo errores
                    // Saco la lista de  elementos y  se los asigno al array model
                    self.model = resultSegment!.blobs as? [AZSCloudBlob]
                    // Actualizo la tabla en la cola principal
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
        })
    }
    
    func fakeUpload(){
        
        // La mecánica es casi  siempre la misma, tengo el contenedor y lo que
        // voy a hace es crear un blob local, persistirlo localmente y una vez
        // creado tengo que  subirlo, hacerle el upload  del mismo a la cuenta.
        
        // Blob  local, generamos un  bloque local con un nombre  diferenciado
        // Esto me crea un blob local, con un  nombre exclusivo, como  prefijo
        //  =>'blob' le podemos pasar un ID  de usuario  si lo tuviéramos  con
        // lo que no vulnera y con un NSUUID convertido todo esto a un  String
        // Éste genera un número aleatorio después del 'blob-' que se asignará
        // a la imagen que se va a subir, cada vez que se suba crea  uno nuevo
        let blobLocal = currentContainer?.blockBlobReferenceFromName("blob-\(NSUUID().UUIDString)")
        
        // Tengo que convertir la imagen en NSData
        var data : NSData?
        // Para generar el NSData de la imagen que quiero
        // subir y que  acabo  de  incoporar al  proyecto
        data = UIImageJPEGRepresentation(UIImage(named: "FONDOS_PANTALLA_024.jpg")!, 0.8)
        // Mediante este bloque local ya podemos subir con alguno de sus  métodos
        // Recibe un  NSData, un  elemento  binario  comprimido, y  un bloque  de
        // finalización, un closure que recibe un error en caso de que lo hubiera.
        blobLocal?.uploadFromData(data! , completionHandler: { (error : NSError?) -> Void in
            // Si hay error, lo muestro por consola mismamente
            if (error != nil){
                print("Error -> \(error)")
            }
        })
    }
    // MARK: - IBActions
    
    // Botón para subir contenido a nuestro container en Azure
    @IBAction func uploadContenido(sender: AnyObject) {
        
        
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
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
