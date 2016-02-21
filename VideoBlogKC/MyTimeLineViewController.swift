//
//  MyTimeLineTableViewController.swift
//  VideoBlogKC
//
//  Created by MacBook Pro on 20/2/16.
//  Copyright © 2016 weblogmerlos.com. All rights reserved.
//

import UIKit

class MyTimeLineViewController: UITableViewController {
    
    // Doy de alta un cliente, pasándole la URL del Mobile Service y la key
    let client = MSClient(applicationURL : NSURL(string: "https://videoblogpiercingkc.azure-mobile.net/"),
        applicationKey : "tDHJgBktBPUszMHkFFVPMzfNfhzVIh35")
    
    var model : [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración botones tabla y título
        self.title = "Mis vídeos blogs"
        let plusBUtton = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: "addNewVideoPost:")
        self.navigationItem.rightBarButtonItem = plusBUtton
        
        // Modelo publicar, le  pedimos a AMS que nos
        // de todos los elmentos que estén publicados
        populateModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if model != nil{
            // Si  el  modelo  tiene datos, me los cuentas y los desempaquetas
            rows = (model?.count)!
        }
        
        return rows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videos", forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Popular el modelo
    func populateModel(){
        
        // Para  popular  el modelo  necesito  saber de
        // que tabla tirar para  obtener la información
        // Y por experimentar con el 'MSQuery' traernos
        // los datos en modo ascendente, por fecha, etc
        
        // Obtengo la tabla  de un  método  del  client
        let tablaVideos = client?.tableWithName("videoblogs")
        
        // Prueba 1:obtener datos via 'MSTable', obtengo
        // todos los datos en result y un posible  error
        tablaVideos?.readWithCompletion({ (result:MSQueryResult?, error: NSError?) -> Void in
            // Si no hay error, es igual a nil
            if error == nil {
                // El modelo es igual a los items que me devuelve result
                self.model = result?.items
                // Aprovecho  para sincronizar la  tabla  actualizándola
                self.tableView.reloadData()
            }
        })
        
        // prueba 2:     Obtener    datos   via    MSQuery
        // Necesito un objeto MSTable para crear una query
        //        let query = MSQuery(table: tablaVideos)
        //
        //        // Incluyo predicados, constrains para filtrar,
        //        // para limitar el número de filas o delimitar
        //        // el número de columnas.
        //        query.orderByAscending("titulo")
        //        // En MSQuery se ejecuta de la siguiente manera
        //        query.readWithCompletion { (result : MSQueryResult?, error : NSError?) -> Void in
        //            if error == nil{ // Que no hay errores
        //                self.model = result?.items
        //                self.tableView.reloadData()
        //            }
        //        }
        
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // Style para borrar una celda seleccionada mediante '.Fade'
            model!.removeAtIndex(indexPath.row)
            
            tableView.endUpdates()
        }
    }
    
    
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
    
    // MARK: - Añadir un nuevo post
    func addNewVideoPost(sender: AnyObject){
        // Cambiamos a la escena 'addNewItem' al pulsar el botón'+'
        // y  enviámos  el  objecto,  'AnyObject',  que  recibimos.
        performSegueWithIdentifier("addNewItem", sender: sender)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Si el  identificador  del segue  es el  controlador
        // de nombre ==> 'addNewItem'  creo un  controlador de
        // ese tipo para pasarle datos de aquí, como el client
        if segue.identifier == "addNewItem"{
            
            // Controlador al que se le envían datos desde aquí
            let vc = segue.destinationViewController as! ViewPostController
            // Desde  aquí  podemos  pasar  alguna  property
            // Le  paso el MSClient, para  poder  utilizarlo
            // El  primer  'vs.client'  es el que defino  en
            // 'ViewPostController', y el segundo el de aquí
            vc.client = client
        }
    }
}









