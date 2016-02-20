//
//  ContainersTableController.swift
//  VideoBlogKC
//
//  Created by MacBook Pro on 17/2/16.
//  Copyright © 2016 weblogmerlos.com. All rights reserved.
//

import UIKit

// Necesito dos cosas, o bien una URL SaaS para poder acceder al servicio
// y  el endpoint  del mismo  o la  API key del  servicio y  su  endpoint

class ContainersTableController: UITableViewController {
    
    // Incluyo   una  cuenta  de   Azure  para  los   contenedores  en  Cloud
    // Tomo la PRIMARY CONNECTION STRING de la consola de Azure y se  la paso
    // Esta no es la mejor manera de acceder al servicio, de momento nos vale
    // NOTA: no utilizar  esta account  para desarrollo, exponemos  la cuenta
    let account = AZSCloudStorageAccount(fromConnectionString:
        "DefaultEndpointsProtocol=https;AccountName=videoblogappkc;" +
        "AccountKey=0ZJDg5L3FEN88kHOC63f3sK7asPiz1BLhRWG7PlDvxwiIwRHKvK6a9G5K+" +
        "jvi+WRcJa7ygajC8MTdj6pWbTMKQ==")
    
    // Creo  un  array para  poder  pasárselo  a  la tabla con el
    // contenido  del contenedor  que he creado en  Azure Storage
    // Voy  a  almacenar  objetos  que  representen  contenedores
    // La clase que representa esa representación de contenedores
    // => AZSCloudBlobContainer
    var model : [AZSCloudBlobContainer]?// opcional, no sé si cotendrá algo,por tanto opcional al canto
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateModel()// rellenar modelo
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Azure Storage Containers Model
    
    // Creo  un método  para llamar al storage para  que me de
    // la lista de contenedores que tengo actulamente en Azure
    func populateModel(){
        
        // Navego  jerarquicamente por la cuenta de  Azure, obteniendo  los blobs containers
        // Permite acceder tanto a los  blobs como a lo  containers  ==> 'AZSCloudBlobClient'
        // Le paso la cuenta de cliente, la access key Azure, para acceder a lo que contiene
        // mediant el BlobClient, que nos permite listar, obtener los contenedores, etc, etc
        let blobClient : AZSCloudBlobClient = account.getBlobClient()
        // Con esta variable que creo invoco a un método que me lista los blobs y containers
        // Como  primer  parámetro  le paso 'nil' para  que me devuelva todos los contenidos
        // Como se segundo le paso un error, y el tercero los resultados ==> 'resultsSegment'
        blobClient.listContainersSegmentedWithContinuationToken(nil) {
            (error:NSError?, resultSegment : AZSContainerResultSegment?) -> Void in
            
            // Si no tenemos errores, es decir, es igual a nil
            if(error == nil){
                
                // Si no vhay errores, le asignov a mi array  'model' el resultado
                // Dependiendo vdel tipo de llamada vque hagamos nos devolverá  un
                // array con vblobs, con vparámetros, con  metadatos, u otro  tipo.
                // Opcional 'resultSegment', ya vque no sév si obtendré resultados
                // y le hagov un casting de tipo  'AZSCloudBlobContainer' vtambién
                // opcional, ya  que no  sé tampoco  si vlo podré vcastear al tipo.
                // Ya tengo el vmodelo vcasteado a un array 'AZSCloudBlobContainer'
                // Dependiendo del tipo de llamada, podrá cambiar el tipo de clase.
                self.model = resultSegment?.results as? [AZSCloudBlobContainer]
                // Necesito utilizar GCD, para  que actualice la  table en el hilo
                // principal, ya  que no se está  realizando en el hilo  principal.
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    // Sincronizo modelo => vista, refresco para ello la 'tableView'
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Filas del modelo
        var rows = 0
        // Compruebo cuantos  elementos tiene mi modelo con un 'if let' ya
        // que 'model' es opcional y no sé si contendrá o no datos =>blobs
        if let model = model{
            // Si el  modelo tiene  algo, se lo asigno a rows
            rows = model.count
        }
        // Devuelvo tantas filas como datos contenga mi modelo
        return rows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("celdaContainer", forIndexPath: indexPath)
        
        // Configuro la celda
        // El contenedor tiene que ser de tipo 'AZSCloudBlobContainer' para blobs
        // Le  asigno el modelo y le asigno la  posición de la celda seleccionada.
        // Con esto extraigo el  elemento de  la posción que  se  ha seleccionado.
        let container : AZSCloudBlobContainer = model![indexPath.row] // Aquí desempaqueto el modelo ya que he comprobado en el método anterior
        // Actulizo modelo => vista
        // Asigno como text del'textLabel' de la celda seleccionada
        // la   propiedad  'name'  que  tiene  todo  'BlobContainer'
        cell.textLabel?.text = container.name // textLabel por defecto es nil, por tanto opcional, y devolverá algo si 'container.name' contiene algo, sino 'nil'
        
        return cell
    }
    
    // Necesito el 'didSelectRowAtIndexPath' para hacer un  select a los  contenedores en  Azure para
    // saber el índice de la celda seleccionada y hacer la búsqueda de lo  que contiene ésta en Azure
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Consigo la posición del elemento seleccionado y después lanzo la escena a través del nuevo
        // segue ==> 'containerDetail',  pasándole  el 'indexPath' de la celda que se ha seleccionado.
        performSegueWithIdentifier("containerDetail", sender: indexPath)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pregunto cual es la escena que ha sido seleccionada
        if(segue.identifier == "containerDetail"){
            
            // Esto abre una vista tipo 'DetailContainerTableController', que es el controlador destino que le he indicado
            let vc : DetailContainerTableController = (segue.destinationViewController as? DetailContainerTableController)!
            
            // Con  esto  le pasamos  al controlador de detalle, la propiedad con el  contenedor
            // Como recibo  como  sender  cualquier  objeto, AnyObject, lo casteo a  NSIndexPath
            let index = sender as! NSIndexPath
            // el vc.currentContainer  será igual a la  posición del modelo que viene dentro del
            // sender que es el  indexPath  del método anterior  y que  recibe éste en el sender
            // Le pasamos el blob que hemos seleccionado en la celda de la tabla de su container
            vc.currentContainer = model![index.row]
        }
    }
}
