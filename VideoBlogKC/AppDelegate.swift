//
//  AppDelegate.swift
//  VideoBlogKC
//
//  Created by MacBook Pro on 16/2/16.
//  Copyright © 2016 weblogmerlos.com. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var account: AZSCloudStorageAccount?
    
    let client = MSClient(
        applicationURLString:"https://videoblobkc.azure-mobile.net/",
        applicationKey:"gVXPSHNQtGWuVRqQYxrLCHQUpbCvEi35"
    )
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Código  de prueba proporcionado por 'Azure Mobile Services'
        // paraprobar a crear una nueva tabla e insertar datos nuevos
        let item = ["Name" : "Awesome item", "edad" : "18", "sexo" : "masculino"]
        
        // Obteniendo  la tabla 'elementos'  para insertar  registros
        let table = client.tableWithName("elementos")
        
        // Insertando en la tabla
        table.insert(item) {
            // Recibe un 'AnyObject' y un 'NSError'
            (insertedItem, error: NSError?) -> Void in
            if (error != nil) {
                print("Error" + error!.description);
            } else {
                print("Item inserted, id:  \(insertedItem["id"])")
            }
        }
        
        // Creando  el  predicado, buscando   edad < 18 años
        let predicate = NSPredicate(format: "edad < 19", [])
        // Leyendo datos de tabla filtrando por un predicado
        table.readWithPredicate(predicate) {
            
            // Closure que recibe un resultado opcional ==>?
            // y un 'NSError' ==> 'error' y no devuelve nada
            (result : MSQueryResult?, error : NSError?) -> Void in
            
            // Si es distinto de nil tenemos un error
            if (error != nil) {
                print("Error" + error!.description)
                // Si no es que hemos insertado 'item'
            }else {
                print("Eliminados los menores de 17 años")
                // Borramos   todos  los  que  sean  mayores de  17  años
                // El id que vamos a  eliminar, está 'results' nos  llega
                // un array de elementos y cojo el de la primera posición.
                let misRegistros : MSQueryResult = result!
                table.delete(misRegistros.items[0] as! [NSObject : AnyObject], completion: {
                    // Le doy el nombre que yo quiera, ya que me crea una 
                    // constante 'let' implicitamente  para el  resultado
                    (resultado: AnyObject?, error : NSError?) -> Void in
                    // Si es igual a nil, error al canto
                    if (error != nil){
                        print("Error" + error!.description)
                    }else{
                        print("Elemento eliminado -> \(resultado)")
                    }
                })
            }
        }
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

