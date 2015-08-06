import Foundation
import Alamofire
import SwiftyJSON
typealias JsonServiceResponse = (AnyObject?, NSError?, Int) -> Void

class RestManager {
    
    static let sharedInstance = RestManager()
    
    private var manager:Manager;
    private let devApiUrl = "https://ec2-52-28-16-59.eu-central-1.compute.amazonaws.com:4433" //ec2-52-28-16-59.eu-central-1.compute.amazonaws.com/
    
    init(){
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "ec2-52-28-16-59.eu-central-1.compute.amazonaws.com": .PinCertificates(
                certificates: ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
        manager = Manager(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
    
    func makeJsonGetRequest(resource: String, params: [String : String]?, onCompletion : JsonServiceResponse) {
        manager.request(.GET, devApiUrl+resource, parameters: params)
            .responseJSON { (req, res, json, error) in
                Debug.instance.log("GET: \(self.devApiUrl+resource) JSONAnswer: \(json) StatusCode: \(res!.statusCode)");
                onCompletion(json, error,res!.statusCode);
                
        }
    }
    
    func makeGetRequest(resource: String, params: [String : String]?, onCompletion : JsonServiceResponse) {
        manager.request(.GET, devApiUrl+resource, parameters: params)
            .responseString { (req, res, answer, error) in
                Debug.instance.log("GET: \(self.devApiUrl+resource) Answer: \(answer) StatusCode: \(res!.statusCode)");
                onCompletion(answer, error,res!.statusCode);
                
        }
    }
    
    func makeJsonPostRequest(resource: String, params: NSDictionary?, onCompletion : JsonServiceResponse) {
        manager.request(.POST, devApiUrl+resource, parameters: params as? [String : AnyObject], encoding: .JSON)
            .responseJSON { (req, res, json, error) in
                Debug.instance.log("POST: \(self.devApiUrl+resource) JSONAnswer: \(json) StatusCode: \(res!.statusCode)");
                onCompletion(json, error, res!.statusCode)
        }
        
        //Can be used to debug the request...
        //        Alamofire.request(.POST, "http://httpbin.org/post", parameters: params as? [String : AnyObject], encoding: .JSON)
        //            .responseJSON {(request, response, JSON, error) in
        //                println(JSON)
        //        }
    }
    
}
